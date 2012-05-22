---
title: Testing Rails 3 routing constraints objects
kind: article
created_at: 2011-11-03 12:00
tags: [rails, ruby, rspec]
tldr: Testing Rails custom constraints objects has a few gotchas with dummy requests and params caching.
---
I recently had to create some Rails routes with advanced constraints. Rails 3 lets you [use a custom object as a constraints matcher][guide], so you can separate and test the its logic. It was _not_ a smooth ride.
{: .leader }

## An example: routing a file browser

Here's a simplified example for routes matching an arbitrary level of nested directories and (optionally) a filename:

    # in config/routes.rb
    get '/*directories/:file' => 'browser#show',
      constraints: ExistingFilesConstraint.new
    get '/*directories' => 'browser#show',
      constraints: ExistingFilesConstraint.new
{: lang="ruby" }

The constraints object would look like this, returning a boolean value from the `#matches?` method:

    # in lib/existing_file_constraint.rb
    class ExistingFilesConstraint
      def matches?(request)
        all_directories_exist?(request.params[:directories]) and
          (
            !request.params.has_key?(:file) or
            file_exists?(request.params[:file])
          )
      end
    
    private
      
      def all_directories_exist?(dirs)
        # ...
      end

      def file_exists?(file)
        # ...
      end
    end
{: lang="ruby" }

Here's my first attempt at testing these routes using simple [Rspec routing matchers][routing], leaving the constraints logic as an implementation detail:

    describe 'GET /foo' do
      it 'should match an existing directory' do
        Factory.create :directory, name: 'foo'
         { get: '/foo' }.should route_to(
           controller: 'browser',
           action: 'show',
           directories: 'foo'
         )
      end
    end
{: lang="ruby" }

## A little too dummy

When you try to run these tests, however, they will fail. There is [a bug][issue2781] — or _missing feature_, if you will — in Rails that causes the dummy request object passed to constraint objects in tests to be a little _too_ dumb: they don’t have any parsed parameters, so `#params` will _always_ be an empty hash. Sure, you've got `request#path`, but you don't to mess around with regular expressions and string parsing yourself…

This is a problem, as it makes it hard to test the actual routing. There is no obvious workaround for this (although it is [a known issue][issue2781]), so I stuck to testing my routes with integration tests (slow, but it works) and unit-testing my constraints object. 

## Parameter caching

Here I encountered a second bug in the way the request object works. I had tested my constraint object thoroughly, but for some reason my integration tests kept failing: the second route in the example just wouldn't match. 

It was not an implementation thing, as taking the first route out would pass the test. It appeared to be a priority thing, but I couldn't figure out why Rails would insist on using **and not matching** my first route, while _ignoring_ my second route.

Using the debugger, I eventually found out that the second route stubbornly got a `:file` parameter. Where could it have come from? I found [another known Rails issue][issue2510] about parameter caching: call `#params` once in a route-matching cycle and its value gets fixed for all subsequent routes. **Not good**. 

The solution was to use a slightly different method to access the params: `#path_parameters`. It works basically the same but does not trigger the erroneous caching behaviour:

    class ExistingFilesConstraint
      def matches?(request)
        params = request.path_parameters
        all_directories_exist?(params[:directories]) and
          (
            !params.has_key?(:file) or
            file_exists?(params[:file])
          )
      end
    
    private
      
      def all_directories_exist?(dirs)
        # ...
      end

      def file_exists?(file)
        # ...
      end
    end
{: lang="ruby" }

With this little change, the routes worked like a charm. 

## Improved testing

The only thing left to do was to properly test the routes. In hindsight, it is actually better than my first attempt:

    context 'GET /foo' do
      let(:subject) { { get: '/foo' } }

      context 'when the files and directories do exist'
        before do
          ExistingFileConstraint.
            any_instance.
            should_receive(:matches?).
            and_return(true)
        end

        it do
          should route_to(
            controller: 'browser',
            action: 'show',
            directories: 'foo'
          )
        end
    end
   
    context 'when the files or directories do not exist' do
      before do
        ExistingFileConstraint.
          any_instance.
          should_receive!(:matches?).
          and_return(false)
      end

      it { should_not be_routable }
    end
{: lang="ruby" }

So, creating custom constraint objects allows you to neatly separate routing logic into testable objects, as long a you keep a few nasty gotchas in mind.

[issue2510]: https://github.com/rails/rails/issues/2510
[issue2781]: https://github.com/rails/rails/issues/2781
[guide]: http://guides.rubyonrails.org/routing.html#advanced-constraints
[routing]: https://www.relishapp.com/rspec/rspec-rails/docs/routing-specs
