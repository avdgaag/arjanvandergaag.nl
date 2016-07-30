---
title: FactoryGirl Tips and Tricks
kind: article
tags:
  - code
  - ruby
  - testing
created_at: 2012-06-20 21:00
tldr: patterns and anti-patterns for the FactoryGirl library
---
[FactoryGirl][1] is an awesome fixture replacement library that gives you a lot
of power and flexibility, at the cost of more code to maintain and increased
mental overhead. It pays get to know it, so you can wield its flexibility to
improve your tests and your productivity.
{: .leader }

## Get the most out of FactoryGirl

### 1. Use **traits** for modular factories

Traits are reusable pieces of attribute definitions that you can mix and match
into your factories. Traits are to factories what modules are to classes a much
more natural and flexible way of sharing common behaviour.

For example, say you have a `Post` and a `Page` object that both have a
publication date. You could use inheritance to create various combinations:

{: .language-ruby }
    FactoryGirl.define do
      factory :post do
        title 'New post'

        factory :draft_post do
          published_at nil
        end

        factory :published_post do
          published_at Date.new(2012, 12, 3)
        end
      end

      factory :page do
        title 'New page'

        factory :draft_page do
          published_at nil
        end

        factory :published_page do
          published_at Date.new(2012, 12, 3)
        end
      end
    end

    FactoryGirl.create :draft_page
    FactoryGirl.create :published_post

The repetition should be obvious. Traits can make this DRY:

{: .language-ruby }
    FactoryGirl.define do
      factory :post do
        title 'New post'
      end

      factory :page do
        title 'New page'
      end

      trait :published do
        published_at Date.new(2012, 12, 3)
      end

      trait :draft do
        published_at nil
      end
    end

    FactoryGirl.create :post, :published
    FactoryGirl.create :page, :draft

With a simple example the difference might seem trivial, but try to think how
quickly the complexity of your inheritance chain would increase if you had not
one but two, six or twelve different attributes (or sets of attributes) you
wanted to be able to apply in different combinations.

Traits are awesome because they can define callbacks, ignored attributes and
even nest other traits.

### 2. Use ignored attributes to tweak callbacks

FactoryGirl lets you define ignored attributes, which will not be set on your
newly created object. This is surprisingly useful in combination with dependent
attributes and callbacks, which do get to access them.

Consider an example of a blog post with comments:

{: .language-ruby }
    FactoryGirl.define do
      factory :comment do
        author 'Anonymous'
        body 'Great post, man!'
        approved_at Date.new(2012, 3, 6)
        post
      end

      factory :post do
        title 'New post'
      end

      trait :with_comments do
        after :create do |post|
          FactoryGirl.create_list :comment, 3, :post => post
        end
      end
    end

It is trivial to create a post with three comments by applying the
`with_comments` trait to a factory invocation. But what if we wanted to adjust
the number of comments? We can use an ignored attribute:

{: .language-ruby }
    trait :with_comments do
      ignore do
        number_of_comments 3
      end

      after :create do |post, evaluator|
        FactoryGirl.create_list :comment, evaluator.number_of_comments, :post => post
      end
    end

Note that a special second argument is passed to the callback block, the
evaluator, which knows about the ignored attributes. Now you can simply pass in
the ignored attribute like you do a regular attribute:

{: .language-ruby }
    FactoryGirl.create :post, :with_comments, :number_of_comments => 4

Make trivial variations possible with ignored attributes removes the need for
tons of almost-identical factories.

### 3. Create non-generic examples

Your factories are used in tests with as goal to make assertions about their
state and behaviour. It can really help to use very specific example objects
with well-known attribute values. So don't create a
`person_with_three_comments_and_a_post`; instead use a `person_mike` and
`person_john`. Use your factories to let your tests tell a simple story about
your objects.

### 4. Use aliases

FactoryGirl allows you to define aliases to existing factories to make them
easier to re-use. This could come in handy when, for example, your `Post`
object has a `author` attribute that actually refers to an instance of a `User`
class. While normally FactoryGirl can infer the factory name from the
association name, in this case it will look for a `author` factory in vain. So,
alias your `user` factory:

{: .language-ruby }
    FactoryGirl.define do
      factory :user, :aliases => [:author] do
        username 'anonymous'
      end

      factory :post do
        author # => populated with the user factory
      end
    end

### 5. allow setting up common associations

When you have many business models with many associations to other business
models, you quickly end up with tests that first have to employ a dozen objects
before the object under test is in such a state that meaningful queries can be
made about it. This might be a sign of bad design, but could very well be
unavoidable. In case of the latter, consider creating traits and factories that
preload such associations for you, as with the example of a post with comments:

{: .language-ruby }
    FactoryGirl.define do
      factory :post do
        title 'New post'
      end

      trait :with_comments do
        after :create do |post|
          FactoryGirl.create_list :comment, 3, :post => post
        end
      end
    end

    FactoryGirl.create :post, :with_comments

## Common pitfalls when creating factories

### 1. Do not use random attribute values

One common pattern is to use a fake data library (like [Faker][2] or
[Forgery][3]) to generate random values on the fly. This may seem attractive
for names, email addresses or telephone numbers, but it serves no real purpose.
Creating unique values is simple enough with sequences:

{: .language-ruby }
    FactoryGirl.define do
      sequence(:title) { |n| "Example title #{n}" }

      factory :post do
        title
      end
    end

    FactoryGirl.create(:post).title # => 'Example title 1'

Your randomised data might at some stage trigger unexpected results in your
tests, making your factories frustrating to work with. Any value that might affect
your test outcome in some way would have to be overridden, meaning:

1. Over time, you will discover new attributes that cause your test to fail
   sometimes. This is a frustrating process, since tests might fail only once
   in every ten or hundred runs -- depending on how many attributes and
   possible values there are, and which combination triggers the bug.
2. You will have to list every such random attribute in every test to override
   it, which is silly. So, you create non-random factories, thereby negating
   any benefit of the original randomness.

One might argue, [as Henrik Nyh does][5], that random values help you discover
bugs. While possible, that obviously means you have a bigger problem: holes in
your test suite. In the worst case scenario the bug _still_ goes undetected; in
the best case scenario you get a cryptic error message that disappears the next
time you run the test, making it hard to debug. True, a cryptic error is better
than no error, but randomised factories remain a poor substitute for proper
unit tests, code review and TDD to prevent these problems.

Randomised factories are therefore not only not worth the effort, they even
give you false confidence in your tests, which is worse than having no tests at
all.

### 2. Test for explicit values

In addition to random values being bad, relying on your factories default
values may be bad idea, too. Unless you create specific story-telling
factories, such as "john" rather than "user1", you should anticipate someone
else (i.e. you, four weeks from now) changing the default factory values. When
you are testing, you want to test for explicit values your test controls. A
test like this is silly:

{: .language-ruby }
    FactoryGirl.define do
      factory :post do
        title { Forgery(:lorem_ipsum).words(5) }
      end
    end

    describe 'Blog' do
      it 'should show the post title on the page' do
        post = FactoryGirl.create :post
        visit '/blog'
        page.should have_content(post.title)
      end
    end

What happens when your post title randomly turns out to be an empty string, or
a phrase that also happens to occur somewhere else on the page? If your test
value is random or outside your control, how can you prove something about it?
Consider this improved example and its increased readability:

{: .language-ruby }
    it 'should show the post title on the page' do
      post = FactoryGirl.create :post, :title => 'My example post'
      visit '/blog'
      page.should have_content('My example post')
    end

The explicit title and test value underline the intent of the test and leave
far less room for false positives or future changes.

### 3. Do not use dynamic values by default

Dynamic attribute values are evaluated on invocation time rather than
evaluation time. This allows you to use, for example, the current time in your
factories:

{: .language-ruby }
    FactoryGirl.define do
      factory :post do
        created_at Time.now # => will be the same for every object
        published_at { Time.now } # => will be updated for every object
      end
    end

This does not mean, however, that you should alway use dynamic attribute values
when a simple static value will do fine:

{: .language-ruby }
    FactoryGirl.define do
      factory :post do
        title { 'My new post' } # silly!
        body 'Lorem ipsum'      # pretty!
      end
    end

Although I'm sure there will be minor performance benefits to using static
values, that is not the point. We want our tests to be readable and clear.
Using blocks everywhere conceals the true meaning of the actually dynamic
attributes between the static attributes.

### 4. Do not manually create associations

When using Rails, FactoryGirl is smart enough to know how to set up
associations for you. So don't do this:

{: .language-ruby }
    FactoryGirl.define do
      factory :comment do
        post { FactoryGirl.create :post }
      end
    end

Usually you can just use another factory name as an attribute, or use the
`association` method to customise it:

{: .language-ruby }
    FactoryGirl.define do
      factory :comment do
        post
      end

      factory :user do
        username 'anonymous'
      end

      factory :post do
        association :author, :factory => :user, :username => 'admin'
      end
    end

Note how the `comment` factory simply uses the `post` factory to set its `post`
attribute. The `post` factory however uses the `user` factory to populate its
`author` attribute _and_ provides some additional details on how it is to be
built.

## Further reading

* Henrik Nyh believes you should [randomize your factories][5]
* [New features in FactoryGirl 3.2][6] by Thoughtbot, including custom build strategies and callback skipping.
* Thoughbot recommends you [use `build_stubbed` for a faster test suite][7]

## More tips?

If you have any pet peeves when using FactoryGirl, [let me know on Twitter][4]!


[1]: https://github.com/thoughtbot/factory_girl
[2]: http://faker.rubyforge.org/
[3]: https://github.com/sevenwire/forgery
[4]: http://twitter.com/avdgaag
[5]: http://henrik.nyh.se/2012/07/randomize-your-factories
[6]: http://robots.thoughtbot.com/post/21719164760/factorygirl-3-2-so-awesome-it-needs-to-be-released
[7]: http://robots.thoughtbot.com/post/22670085288/use-factory-girls-build-stubbed-for-a-faster-test
