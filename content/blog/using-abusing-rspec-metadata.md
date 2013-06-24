---
title: Using and abusing RSpec metadata
tags:
  - ruby
  - rspec
  - testing
created_at: 2013-06-24 19:00
kind: article
---
[RSpec][] allows us to define custom metadata for individual examples or
entire example groups. This data can then be used for filtering or altering the
affected examples' behaviour.
{: .leader }

One may define custom metadata by passing a hash as a second argument to `it`,
`context` and `describe`:

{: .language-ruby }
    it 'cannot be destroyed', current: true do
      expect { user.destroy! }.to raise_error
    end

This pattern is used, for example, by [Capybara][] to trigger its javascript
driver to run integration tests; and by [VCR][] to configure its recording and
playback settings for HTTP requests.

There are three ways you can use custom metadata in your own workflow: to filter
examples to run, altering how tests are run, and altering context (which I
consider an anti-pattern).

## Filtering examples

The simplest use case of custom metadata is to "tag" certain examples with
keywords, and then tell RSpec to decide whether to run examples based on that
keyword.

For example, you might focus your next test run on only those examples you are
currently developing by using a "current" keyword:

{: .language-ruby }
    describe Post
      describe '#to_param', focus: true do
        it 'returns the slug attribute'
      end
    end

To run only the examples tagged with `focus`, use RSpec's filtering
configuration:

{: .language-ruby }
    RSpec.configure do |c|
      c.filter_run_including focus: true
      c.run_all_when_everything_filtered = true
    end

RSpec will now only run examples tagged with `focus`. When no examples are
tagged, it will run everything. Alternatively, you could filter examples from
the command line:

    $ rspec --tag focus:true

If you think declaring "tags" as hash keys with value `true` is ugly, you are
not the only one. RSpec 3.0 will also accept symbols as metadata, and you can
trigger that behaviour today:

{: .language-ruby }
    RSpec.configure do |c|
      c.treat_symbols_as_metadata_keys_with_true_values = true
    end

This will allow you to write tags like so:

{: .language-ruby }
    describe Post
      describe '#to_param', :focus do
        it 'returns the slug attribute'
      end
    end

## Altering how examples are run

[ResqueSpec][] is a nice library to fake running background jobs with Resque. It
will queue jobs in a simple in-memory hash, which allows you to easily set
expectations on what gets queued:

{: .language-ruby }
    it 'mails a PDF form to the user' do
      User.create! email: 'foo@example.com'
      expect(PdfMailerJob).to have_queue_size_of(1)
    end

ResqueSpec will not run any jobs until you explicitly tell it to. You can either
tell it to run all jobs in a queue with `ResqueSpec.perform_all(:emails)`, or
wrap your code in a `with_resque` block:

{: .language-ruby }
    it 'mails a PDF from to the user' do
      with_resque do
        expect {
          User.create! email: 'foo@example.com'
        }.to send_emails(1)
      end
    end

Using RSpec's `around` filter can make this spec a little easier to read:

{: .language-ruby }
    # in spec/models/user.rb
    it 'mails a PDF form to the user', :resque do
      expect {
        User.create! email: 'foo@example.com'
      }.to send_emails(1)
    end

    # in spec/spec_helper.rb
    RSpec.configure do |c|
      c.treat_symbols_as_metadata_keys_with_true_values = true

      c.around do |example|
        return unless example.metadata[:resque]
        with_resque do
          example.run
        end
      end
    end

Here we see how global hooks (i.e. `before`, `after` and `around`) can
automatically filter by metadata. This is a neat way of reducing boilerplate in
your examples.

Other uses of this pattern might include:

* temporarily enabling and disabling of verbose logging;
* temporarily redirecting log output to STDOUT;
* using database transactions for regular tests and truncation for integration tests.

## Altering example context

When your application has authentication, most of your integration tests will
want to sign in as some kind of user as their first step. This is commonly done
using a before hook:

{: .language-ruby }
    describe 'Edit profile' do
      before do
        User.create! username: 'test', password: 'secret'
        visit '/login'
        fill_in 'Username', with: 'test'
        fill_in 'Password', with: 'secret'
        click_button 'Log in'
      end

      it 'stores a new name' do
        visit '/profile'
        fill_in 'Name', with: 'Foo'
        click_button 'Update Profile'
        expect(page).to have_content('Name: Foo')
      end
    end

This gets tedious to repeat in all your spec files, so you might be tempted to
use metadata and global hooks to trigger authentication as a particular user:

{: .language-ruby }
    RSpec.configure do |c|
      c.before :each, signed_in: true do
        User.create! username: 'test', password: 'secret'
        visit '/login'
        fill_in 'Username', with: 'test'
        fill_in 'Password', with: 'secret'
        click_button 'Log in'
      end
    end

Or, with some refactoring to helper methods, you might even consider using
metadata to select what user to authenticate with:

{: .language-ruby }
    RSpec.configure do |c|
      c.before do
        factory_name = example.metadata[:signed_in_as]
        return unless factory_name
        user = FactoryGirl.create(factory_name)
        sign_in_as(user)
      end
    end

Now, you could write your examples like this:

{: .language-ruby }
    describe 'Editing my profile' do
      it 'changes my username', signed_in_as: :jack do
        # ...
      end

      it 'shows me an error message' do
        # ...
      end
    end

The examples read very nicely, which is good. But we are now using metadata to
alter to flow of our examples, which is bad. To avoid repeating the same hooks
all over your test suite, you would do better to create a custom `context`
method that would make the altered context of the example explicit:

{: .language-ruby }
    describe 'Editing my profile' do
      def self.when_signed_in_as(factory_name)
        context "when signed in as #{factory_name}" do
          let(:current_user) { create(factory_name) }

          before do
            sign_in_as(current_user)
          end

          yield
        end
      end

      when_signed_in_as :jack do
        it 'changes my username', signed_in_as: :jack do
          # ...
        end
      end

      when_signed_out do
        it 'shows me an error message' do
          # ...
        end
      end
    end

When deciding between using metadata to trigger some kind of behaviour in your
test suite, do think about if you are trying to alter _how_ your tests are run,
or _what_ the test should do. Feel free to use metadata for the former, but use
other tools for the latter. Your team mates and future self will thank you for
it.

[ResqueSpec]: https://github.com/leshill/resque_spec
[RSpec]:      https://github.com/rspec/rspec
[VCR]:        https://github.com/vcr/vcr
[Capybara]:   https://github.com/jnicklas/capybara
