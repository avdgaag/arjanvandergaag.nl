---
title: Writing custom RSpec matchers
tags:
  - code
  - ruby
  - rspec
created_at: 2015-03-07
kind: article
---
Test code is code like any other code, which needs to be maintained. It therefore needs to be readable and DRY. With RSpec, writing custom matchers can help you write better tests that are both easier to read and easier to write.
{: .leader }

**Update**: an updated version of this article was published as a Semaphore
community tutorial, titled
[How to Use Custom RSpec Matchers to Specify Behaviour](https://semaphoreci.com/community/tutorials/how-to-use-custom-rspec-matchers-to-specify-behaviour).

## Example: matching XML to Xpath expression

Let's say we have an API that responds in an XML format. We want to assert that sensitive information is omitted from the XML for  unauthorised users. We could write such a test like so:

~~~ ruby
context "for unauthorised users" do
  it "omits the team sales figures" do
    get "/api/stats.xml"
    xml_document = Nokogiri::XML(response.body)
    expect(xml_document.xpath("/stats/team/sales")).to be_empty
  end
end

context "for authorised users" do
  before do
    login_in_as users(:authorised_user)
  end

  it "includes the team sales figures" do
    get "/api/stats.xml"
    xml_document = Nokogiri::XML(response.body)
    expect(xml_document.xpath("/stats/team/sales")).not_to be_empty
  end
end
~~~

Fair enough, but there's **two different levels of abstraction** in play here: making the high-level assertions about the behaviour of our API; and the low-level implementation of verifying such an assertion.

## Testing with custom matchers

Custom RSpec matchers can help with this problem. We define our own domain-specific assertions and use them to compose readable specifications. For example, here's what a specification using such a custom matcher might look like:

~~~ ruby
context "for unauthorised users" do
  it "omits the team sales figures" do
    get "/api/stats.xml"
    expect(response).not_to have_xpath("/stats/team/sales")
  end
end

context "for authorised users" do
  before do
		login_in_as users(:authorised_user)
  end

  it "includes the team sales figures" do
    get "/api/stats.xml"
    expect(response).to have_xpath("/stats/team/sales")
  end
end
~~~

The `have_xpath` matcher is what we will implement next. There are two ways to implement matchers: using RSpec's matcher DSL, and writing a Ruby class. We'll look at both in turn.

## Using RSpec's matcher DSL

RSpec will, by default, load all Ruby files under `./spec/support` before running any tests. We can therefore create a new file `./spec/support/matchers/have_xml.rb` and define our custom matcher there.

An empty matcher looks like this:

~~~ ruby
RSpec::Matcher.define :have_xpath do |expected|
  match do |actual|
    # return true or false here
  end
end
~~~

It all boils down to coming up with a `true` or `false` response to indicate whether the test passed or failed. The `match` block will be called with the "actual" value as an argument — this is `response.body` in `expect(response.body).to have_xpath("…")`. This is the place where we implement our custom logic:

~~~ ruby
RSpec::Matcher.define :have_xpath do |xpath|
  match do |str|
    Nokogiri::XML(str).xpath(xpath).any?
  end
end
~~~

Note that we can change the block argument names to match our domain. We use Nokogiri to make a simple xpath assertion for the string we're given. I want to stress that accepting a string in our `match` block rather than a `response` object helps keep our matcher generic enough so we can re-use it later.

### Customising our matcher

Our matcher is basically ready for use, but we can do better. Let's see what happens when a test using this matcher fails. RSpec will report:

    expected "<stats><user>…</user></stats>" to have xpath "/stats/team/sales"

RSpec dumps the _actual_ and _expected_ values and combines them with the name of our matcher to create a generic error message. It's not too bad, but dumping the entire XML string into the error output is not super readable. Let's customise the error message:

~~~ ruby
RSpec::Matcher.define :have_xpath do |xpath|
  match do |str|
    Nokogiri::XML(str).xpath(xpath).any?
  end

  failure_message do |str|
    "Expected xpath #{xpath.inspect} to match in:\n" + Nokogiri::XML(str).to_xml(indent: 2)
  end

  failure_message_when_negated do |str|
    "Expected xpath #{xpath.inspect} not to match in:\n" + Nokogiri::XML(str).to_xml(indent: 2)
  end
end
~~~

Using `failure_message` and `failure_message_when_negated` we can customise the error message so it now reads as:

    Expected xpath "/stats/team/sales" to match in:
    <?xml version="1.0"?>
    <stats>
      <user>…</user>
    </stats>

We now see our XML document pretty-printed so we can more easily scan it to see what's wrong.

## Converting to a Plain Old Ruby Object

Our matcher is quite useful, but we could make it neater. To do so, I find it easier to convert it to a Ruby class an bypass the matcher DSL altogether. For anything non-trivial, it is nice to just deal with plain Ruby.

Matchers can be written as plain old Ruby objects, as long as they conform to a specific API — methods named like the blocks in our previous example. We could write the above matcher as a class as follows:

~~~ ruby
class HaveXpath
  def initialize(xpath)
    @xpath = xpath
  end

  def matches?(str)
    @str = str
    Nokogiri::XML(@str).xpath(@xpath).any?
  end

  def failure_message
    "Expected xpath #{@xpath.inspect} to match in:\n" + Nokogiri::XML(@str).to_xml(indent: 2)
  end

  def failure_message_when_negated
    "Expected xpath #{@xpath.inspect} not to match in:\n" + Nokogiri::XML(@str).to_xml(indent: 2)
  end
end
~~~

This is admittedly more code, and arguably less obvious than the DSL-version — but I do find it easier to refactor.

### Refactoring our matcher

Let's extract  a `xml_document` method:

~~~ ruby
class HaveXpath
  def initialize(xpath)
    @xpath = xpath
  end

  def matches?(str)
    @str = str
    xml_document.xpath(@xpath).any?
  end

  def failure_message
    "Expected xpath #{@xpath.inspect} to match in:\n" + xml_document.to_xml(indent: 2)
  end

  def failure_message_when_negated
    "Expected xpath #{@xpath.inspect} not to match in:\n" + xml_document.to_xml(indent: 2)
  end

  private

  def xml_document
    @xml_document ||= Nokogiri::XML(@str)
  end
end
~~~

Now we can also extract a `pretty_printed_xml` method:

~~~ ruby
class HaveXpath
  def initialize(xpath)
    @xpath = xpath
  end

  def matches?(str)
    @str = str
    xml_document.xpath(@xpath).any?
  end

  def failure_message
    "Expected xpath #{@xpath.inspect} to match in:\n" + pretty_printed_xml
  end

  def failure_message_when_negated
    "Expected xpath #{@xpath.inspect} not to match in:\n" + pretty_printed_xml
  end

  private

  def pretty_printed_xml
    xml_document.to_xml(indent: 2)
  end

  def xml_document
    @xml_document ||= Nokogiri::XML(@str)
  end
end
~~~

I find these refactorings simpler to reason about when our object is not clouded by metaprogramming cleverness, although there's nothing in here that would not have been possible with the DSL.

### Introducing a helper method

Note that with the class-version of our matcher, we need to write our exception like so:

~~~ ruby
expect(response.body).to HaveXpath.new("/stats/team/sales")
~~~

Which is not as nice as with our DSL-version. We can introduce a helper method to make things pretty again:

~~~ ruby
def have_xpath(*args)
  HaveXpath.new(*args)
end

expect(response.body).to have_xpath("/stats/team/sales")
~~~

So, class-based matchers usually come with helper methods to make our specifications readable and hide implementation details from the reader.

This example has only demonstrated the basics of RSpec matchers.  You can find more information on defining fluent, chained matchers, diffable matchers and accepting blocks as arguments n the RSpec documentation.

## Re-evaluating levels of abstraction

You might argue that this matcher is not quite high-level enough to actually model our domain. The matcher deals with XML, Xpath expressions and the structure of our XML document. This would be a fair point, and I'd argue that whenever this particular itch comes up, you could scratch it not with a more generic matcher, but with another helper method:

~~~ ruby
def include_team_sales_figures
  have_xpath("/stats/team/sales")
end

expect(response.body).to include_team_sales_figures
~~~

This should demonstrate the difference between a generic, re-usable matcher to hide implementation details from the reader of the code; and modelling your domain language so you can write human-friendly specifications.

## When to write custom matchers

I believe you should start writing custom matchers as soon as possible in a project. This helps you build a suite of easily re-usable matchers that the entire team can use. To get into this habit, try to limit yourself to a maximum of three lines per test: setup, excercise and verification. If you need more than a single line to write the verification code, you should write a custom matcher.
