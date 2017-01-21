---
title: Tips for writing better Cucumber steps
kind: article
created_at: 2014-07-07 22:00
tags:
 - ruby
 - cucumber
---
Cucumber is a nice way of documenting user-level acceptance tests in web
applications. I'm not a huge fan of it myself, because the collection of step
definitions in a typical project tends to grow into an unwieldy mess --- but
when I do use Cucumber in Rails projects, I tend to use a couple of tricks to
keep my steps sane. Here are some of the non-obvious tricks.
{: .leader }

## 1. Use markup conventions to write generic steps

We want to avoid having to write thousands of step definitions. You can take
advantage of conventions in naming and markup to define steps that are generic
enough to be re-used. Take this step definition for example:

{: .language-ruby }
    Then(/^I see (\d+) (.*?) rows$/) do |n, class_name|
      n = n.to_i
      class_name = class_name.parameterize.underscore
      expect(page).to have_css("tbody tr.#{class_name}", count: n)
    end

You can use this step when you have view templates that display records in
tables, to test that a certain number of records is displayed. When you have
markup like this:

{: .language-erb }
    <table>
      <thead>
        <tr>
          <th>Title</th>
        </tr>
      </thead>
      <tbody>
        <%= content_tag_for(:tr, @posts) do |post| %>
          <td><%= post.title %></td>
        <% end %>
      </tbody>
    </table>

…you can use the step definition above like so:

    Then I see 3 post rows

Note the `class_name.parameterize.underscore` part ensures human names such as
“paid invoices” or “Registered users” become “paid_invoices” and
“registered_users”, which works nicely with the prefix supported by
`content_tag_for` ([read more][content_tag_for]). You could also use this trick
to test for content, such as:

{: .language-ruby }
    Then(/^(.*?) row (\d+) contains "(.*?)"$/) do |class_name, n, text|
      class_name = class_name.paramterize.underscore
      within "table tbody tr.#{class_name}:nth-child(#{n})" do
        expect(page).to have_content(text)
      end
    end
    # Example usage:
    # Then invoice row 3 contains “$ 17.50”

This example focuses on table rows, but is easily adapted into more generic
terms, so you can simply state that the page should contain “4 users” or “an
invoice”. Writing such steps makes your scenarios quite readable, and forces
you into the habit of providing meaningful classes and markup to your templates.

The important take-away here is that you use good front-end development
practices (writing meaningful markup) _and_ write highly re-usable steps
without too much coupling. This requires a little magic sometimes, but it is
worth the effort.

## 2. Use Transform steps to reduce boilerplate

Transform steps are a nice secret of Cucumber. They allow you to transform step
arguments by matching them against a regular expression. The best example I can
think of is a _count_ argument, like in the example above. Capturing an argument
matching only digits in a regular step definition is easy enough, but we still
have to convert its string value to an integer every time. Enter transform steps:

{: .language-ruby }
    Transform(/^an?$)/) do |str|
      1
    end
    
    Transform(/^-?\d+$)/) do |str|
      str.to_i
    end

These two transform steps will automatically transform every regular step
argument matching these regular expressions (strings like “1”, “-24” or “a”)
into integers. Your step definition could look like this:

{: .language-ruby }
    Given(/^there (?:is|are) (an?|-?\d+) invoices?$/) do |n|
      FactoryGirl.create_list :invoice, n
    end

This trick can also be useful for dealing with dates and times, factories, money
and other special types of data where you don't want to deal with plain strings.
You can even use them to operate on tables. See the [Cucumber wiki on Step
Argument Transforms][transforms] for more information.

**A word of caution though**: transforms apply _everywhere_. You will have to make
them unique enough to only match where appropriate. For example, you might be
tempted to write a `Transform` step to parse natural language dates and times
using the [chronic][] library. But consider the regular expression to match a
string argument to be parsed as a date… it would have to match just about
_anything_ — most likely leading to conflicts with other `Transform` steps.

Transform steps are global and the first matching `Transform` step will be used
to transform the argument; there is no cascading or priority. The case of
parsing natural-language dates would be better solved in a specific, regular
step definition, where your can rely on argument order rather than format to
decide how to parse it:

{: .language-ruby }
    # Given I last signed in two weeks ago
    Given(/^I last signed in (.+)$/) do |date|
      date = Chronic.parse(date)
      # ...
    end

## 3. Use meta-programming to define factory steps

If you use [FactoryGirl][] to insert sample date before your tests, you could
use meta-programming to generate step definitions. Since FactoryGirl can give
you the names of all the factories it knows, you could define a step for each.
You will, of course, need a little string-crunching magic to make human-friendly
steps:

{: .language-ruby }
    FactoryGirl.factories.each do |factory|
      # create a human-friendly factory name
      factory_name = factory.name.to_s.humanize.downcase

      # generate a regex fragment matching both plural and singular forms
      factory_matcher = [factory_name, factory_name.pluralize].join(‘|’)
  
      Given(/^there (?:is|are) (an?|-?\d+) (?:#{factory_matcher})$/) do |n|
        FactoryGirl.create_list factory_name, n
      end
    end

If you have a factory named `GuestUser`, you could now use this step as follows:

    Given there is a guest user
    And there are 3 guest users

You could even get extra fancy and include FactoryGirl traits:

{: .language-ruby }
    factory.defined_traits.each do |trait|
      trait_name = trait.name.to_s.humanize.downcase
      Given(/^there (?:is|are) (an?|-?\d+) (?:#{factory_matcher}) (?:that is |with |that are)?#{trait_name}$/) do |n|
        FactoryGirl.create_list factory.name, n, trait.name
      end
    end

If your factory looks like this:

{: .language-ruby }
    FactoryGirl.define do
      factory :guest_user do
        trait :stale do
          created_at { 6.weeks.ago }
        end
      end
    end

…you could use the following step in you scenarios:

    Given there are 2 guest users that are stale

I am not arguing that you should use elaborate `Background` sections for your
scenarios to set up complex data sets. I do think these steps can help create
readable exceptions to more generic, bigger setup steps.

Do observe that if you use these steps, you are automatically forced to write
meaningful names for your factories and traits. I've found this effect very
helpful, as they have the unintended side effect of also clarifying my unit
tests.

## 4. Time travelling scenarios

Sometimes, your scenarios are dependent on a particular date and time. For
example, you might develop a calendar system and want to test the colouring of
"yesterday" -- whatever that may be. Rails 4 ships with some good helper methods
for stubbing `Time` (see[ActiveSupport::Testing::TimeHelpers][time_helpers]) and
for earlier versions and non-Rails projects there's [Timecop][]. You can use
these easily in a step:

{: .language-ruby }
    Given(/^the current date is (.+)$/) do |time_string|
      travel_to(Time.parse(time_string))
    end

So far, so good. We can use a step like `Given the current date is 2014-04-23`
and our tests run as if that is the current date. But we need to remember to
travel back to the _actual_ date and time, so as not to influence other tests.
We might use Cucumber's `After` hook:

{: .language-ruby }
    After do
      travel_back
    end

...but to more explicit, let's use tags to indicate that this particular
scenario uses time travelling:

{: .language-ruby }
    After('@time_travel') do
      travel_back
    end

Now we can write a scenario like:

    @time_travel
    Scenario: Time-dependent test
      Given the current date is 2014-04-23
      ...

## 5. Switch between multiple sessions

Capybara supports multiple sessions. You could use this to simulate logging in
as two users at the same time, so that one user sees another user's changes
appearing in his browser in real time (just to name an example). The API is
simple: just assign a session name:

{: .language-ruby }
    Capybara.session_name = 'John'

Now you are in session "John". Assign "Graham" and you're in session "Graham".
Translating this to a Cucumber step is easy:

{: .language-ruby }
    When(/^I am in (.*) browser$/) do |name|
      Capybara.session_name = name
    end

But switching explicitly is kind of awkward, so we can use compound steps --
where one step completely contains another:

{: .language-ruby }
    When(/^(?!I am in)(.*(?= in)) in (.*) browser$/) do |other_step, name|
      step("I am in #{name} browser")
      step(other_step)
    end

This step matches anything _not_ starting with `I am in` (our original browser
step) but ending with `in <name> browser`. Anything that comes before it, is
called as another step. For example:

    When I log in as admin in John's browser
    And I log in as customer in Graham's browser

These two steps both run the `I log in as <role>` steps but in different
Capybara sessions. I took this tip from [Collective Idea][].

[chronic]:         https://github.com/mojombo/chronic
[content_tag_for]: http://api.rubyonrails.org/classes/ActionView/Helpers/RecordTagHelper.html#method-i-content_tag_for
[FactoryGirl]:     https://github.com/thoughtbot/factory_girl
[transforms]:      https://github.com/cucumber/cucumber/wiki/Step-Argument-Transforms
[Collective Idea]: http://collectiveidea.com/blog/archives/2011/08/04/simultaneous-capybara-sessions-in-cucumber/
[time_helpers]:    https://github.com/rails/rails/blob/cee2c85b07317524861ba14b51d8e7e9b34966ba/activesupport/lib/active_support/testing/time_helpers.rb
[Timecop]:         https://github.com/travisjeffery/timecop
