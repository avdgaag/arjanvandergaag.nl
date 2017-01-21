---
title: Using custom inputs with Simple Form
kind: article
created_at: 2015-12-11 12:00
tags:
  - Ruby
  - Simple Form
---
Forms are a big part of web applications, but the tedious amount of boilerplate code required can quickly become an unwieldy, inconsistent mess. Luckily, we can use Simple Form to make matters easier.
{: .leader }

The [Rails][] framework already comes with [a bunch of great helper methods for building forms][form helpers], especially when [built around a model instance][form_for]. But these helpers give you input elements; they hardly offer any help with labels, help texts, inline validation errors, internationalizing, and so forth. [Simple Form][], by [Plataformatec][], automates much of the trivial decisions away. This leads to concise code, consistent output and, consequently, to simpler stylesheets.

We'll look at four ways to use Simple Form to simplify our code:

1. using Simple Form to generate consistent boilerplate code for HTML forms;
2. defining custom wrappers to finely control generated markup;
3. defining custom input types to DRY up more advanced forms;
4. dealing with complex values on the server.

## Example application

Let's say we have an ActiveRecord model for a product in our ecommerce shop, and its table has an integer field called `price_in_cents`. Here's what a model and its schema might look like:

~~~ ruby
# app/models/product.rb
class Product < ActiveRecord::Base
end

# db/schema.rb
create_table 'products' do |t|
  t.integer :price_in_cents, null: false
end
~~~

We can build a form to create a new product record, containing an input field for our `price_in_cents` field, like so:

~~~ rhtml
<%= form_for @article do |f| %>
  <div>
    <%= f.label :price_in_cents %>
    <%= f.number_field :price_in_cents %>
  </div>
<% end %>
~~~

This will give us, rather unsurprisingly, the following output:

~~~ rhtml
<form method="POST" action="/products" id="new_product">
  <div>
    <label for="product_price_in_cents">Price in cents</label>
    <input type="number" name="product[price_in_cents]" id="product_price_in_cents">
  </div>
</form>
~~~

Writing out forms like this is better than writing _all_ the elements by hand, but it still leaves something to be desired. Let's use Simple Form to make it suck less.

## Generate consistent markup

Simple Form is implemented as a [form builder][form builder], and it gives us a handy `simple_form_for` helper that mimics the regular `form_for`, but uses its own form builder. We can use like to so:

~~~ rhtml
<%= simple_form_for @article do |f| %>
  <%= f.input :price_in_cents %>
<% end %>
~~~

Simple Form's form builder gives us one new feature: the `input` method. This method does a couple of things. This is the output it generates:

~~~ rhtml
<div class="input string product_price_in_cents">
  <label class="string" for="product_price_in_cents">Price in cents</label>
  <input class="string" type="number" name="product[price_in_cents]" id="product_price_in_cents">
</div>
~~~

### Sensible HTML boilerplate

That's mostly the same output as before. That's because `input` uses all the same form helpers that we would otherwise use. But Simple Form can make a good guess at what type of input element to use, and gives us some helpful classes along with it. What's more, it will automatically use `I18n` to translate labels and insert hint texts. If we edit our `config/locales/en.yml` to include this:

~~~ yaml
en:
  simple_form:
    labels:
      product:
        price_in_cents: Price
    hints:
      product:
        price_in_cents: Enter the total price in cents.
~~~

...our output code changes to:

~~~ rhtml
<div class="input string product_price_in_cents field_with_hint">
  <label class="string" for="product_price_in_cents">Price</label>
  <input class="string" type="text" name="product[price_in_cents]" id="product_price_in_cents">
  <span class="hint">Enter the total price in cents.</span>
</div>
~~~

Note how the contents of the `<label>` element was automatically changed, and how we got a new `span.hint` element below our input. The added `field_with_hint` class allows us to style our input to our liking.

### Column-aware customizations

Since our database column is not null-able, we should add a presence validation to our model:

~~~ ruby
class Product < ActiveRecord::Base
  validates :price_in_cents, presence: true
end
~~~

Simple Form will reflect on our model and infer that this is a required field. Our markup is updated to this:

~~~ rhtml
<div class="input string required product_price_in_cents field_with_errors field_with_hint">
  <label class="string required" for="product_price_in_cents"><abbr title="required">*</abbr> Price in cents</label>
  <input class="string required" type="text" name="product[price_in_cents]" id="product_price_in_cents">
  <span class="hint">Enter the total price in cents</span>
  <span class="error">can&#39;t be blank</span>
</div>
~~~

We've got an extra class on our input wrapper to indicate our field is `required`, there's a new element in our label to indicate the field is required, and when we submit the form without entering anything, we even get inline validation errors (the `span.error`) and an extra class on our wrapper (`field_with_errors`) so we can style our input. That's a lot of useful stuff we got for free there!

### Benefits for markup

Let's review how Simple Form helps us write sane, consistent markup:

* automatically generated HTML boilerplate code ensures all our forms use the same structure and naming conventions;
* column-aware attributes gives us the right input type automatically;
* integration with I18n gives us human-friendly labels and hints;
* model introspection makes our inputs aware of validations, giving us automatic "required" labels and inline errors.

Basically, Simple Form simply automates a lot tedious decisions away. This leaves us with clean input code and consistent output code. I find this to be equal parts reluctantly succinct and awkwardly auto-magical; since forms are such a tedious but well-defined problem, I can accept the added complexity.

## Markup customization with wrappers

By generating our markup for us, Simple Form takes a lot of trivial decisions out of our hands --- but that's not to say we simply have to accept whatever defaults it gives us. We can configure Simple Form with wrappers to customize the components and HTML structure it generates. We have seen the output for Simple Form's default wrapper; now let's define our own. We'll add a new wrapper for inputs with label and input elements arranged horizontally, rather than vertically. We'll call it `inline` and we define it in `config/initializers/simple_form.rb`:

~~~ ruby
config.wrappers :inline,
  class: :input,
  hint_class: 'field--with-hint', error_class: 'field--with-errors' do |b|

  # mix in special behavior using `use :component`
  b.use :html5
  b.use :placeholder

  # define custom HTML output using `wrapper`
  b.wrapper tag: :div, class: 'column-3' do |c|
    c.use :label, class: 'field__label'
  end
  b.wrapper tag: :div, class: 'column-3' do |c|
    c.use :input
    c.wrapper tag: :div, class: 'field__meta', unless_blank: true do |d|
      d.use :hint,  wrap_with: { tag: :div, class: 'field__hint' }
      d.use :error, wrap_with: { tag: :div, class: 'field__error' }
    end
  end
end
~~~

We define our wrapper using a special DSL. We make our wrapper the global default, or apply it on a per-form or per-input basis. Let's apply it to this one input:

~~~ rhtml
<%= f.input :price_in_cents, wrapper: :inline %>
~~~

This gives us the following output (I've inserted some white space for readability):

~~~ rhtml
<div class="input string required product_price_in_cents field--with-errors field--with-hint">
  <div class="column-3">
    <label class="string required" for="product_price_in_cents"><abbr title="required">*</abbr> Price</label>
  </div>
  <div class="column-3">
    <input class="string required" type="text" value="" name="product[price_in_cents]" id="product_price_in_cents" />
    <div class="field__meta">
      <div class="field__hint">Enter the total amount in cents.</div>
      <div class="field__error">can&#39;t be blank</div>
    </div>
  </div>
</div>
~~~

Notice how we’ve now ended up with some BEM-like classes, wrapping tags that allow styling with a CSS grid framework, and a new wrapper tag around the hint and error — and with the `unless_blank` option we even ensure this wrapper is omitted when it has no content. Now we're getting a lot of mileage out of that one `f.input :price_in_cents` in our template!

With wrappers we can control the generated output apart from our label and input elements themselves. Next, we'll see how we can customize those using custom inputs.

## Custom input components

Apart from the markup around our input elements, we can also create custom input components for the input elements themselves. A custom input allows us to customize the `<input>` and `<label>` elements for a given attribute, taking the current form object into account.

### Customize HTML output

Let's create a simple custom input type that we can use for monetary values. Although Simple Form can infer input types from column types and names, we'll stick with explicitly telling it which input type to use:

~~~ rhtml
<%= f.input :price_in_cents, as: :money %>
~~~

To make this work, we need to define the following class:

~~~ ruby
# app/inputs/money_input.rb
class MoneyInput < SimpleForm::Inputs::StringInput
  def input
    '&euro; ' + super
  end
end
~~~

### Tweaking output by overriding hook methods

Custom inputs are Ruby objects that know how to generate strings of HTML code. These objects can contain quite a bit of behavior, so we're best off subclassing one of the built-in inputs --- in this case, the regular `StringInput`. The one method we've tweaked is `input`, which should output the `<input>` element. We've prefixed the old output with a Euro-sign, resulting in output like this:

~~~ rhtml
&euro; <input class="string required" type="text" value="" name="product[price_in_cents]" id="product_price_in_cents">
~~~

This demonstrates a pattern in custom inputs: for the most part, we can rely on built-in inputs and default behavior to build our output --- but by overriding specific "hook" methods, we can achieve almost any result we want.

### Using two input fields for monetary values

Let's set ourselves a challenge: rather than asking our users to enter a monetary value in cents, we can present them with _two_ input fields instead: one for euros and one for cents. A custom input allows us to DRYly do this. This is roughly the output we want to achieve:

~~~ rhtml
<div class="input">
  <label>Price</label>
  &euro;
  <input name="product[price(1i)]" type="number">
  ,
  <input name="product[price(2i)]" type="number">
</div>
~~~

Note the special naming convention of the attributes: the `(1i)` and `(2i)` suffices will trigger Rails to parse these two parameters into a single, composite value of two integers. In a minute, we'll deal with these values on the server side. This is how we want to implement the `input` method in our `MoneyInput` class:

~~~ ruby
def input(wrapper_options = nil)
  format(
    '&euro; %s,%s'
    input_major,
    input_minor
  ).html_safe
end
~~~

Our (as of yet undefined) `input_major` and `input_minor` methods should output strings of HTML code. To do so, we can use any helper method we want, since we can access our view via the `template` attribute. Also, we can access the form builder (and though it the underlying model) via `@builder`. Here’s the simplest possible implementation for `input_major`:

~~~ ruby
def input_major
  template.text_field_tag(
    'product[price(1i)]',
    @builder.object.price / 100,
    id: 'product_price_1i'
  )
end
~~~

We use `template.text_field_tag` rather than `@builder.text_field`, because we want to control the name and value attributes of the tag it outputs.

### Making a re-usable input type

Of course, our custom input is not very flexible this way. Let’s use some extra methods from our form builder to make this input model-agnostic:

~~~ ruby
def input_major
  template.text_field_tag(
    "#{@builder.object_name}[#{attribute_name}(1i)]",
    @builder.object.send(attribute_name) / 100,
    id: "#{@builder.object_name}_#{attribute_name}_1i"
  )
end
~~~

Here's what we've used:

* we use `@builder.object` to access the `@product` object in `simple_form_for(@product)`;
* we use `@builder.object_name` to get the parameter key for this type of object, which in this case is `"product"`;
* we use `attribute_name` to get the name of the current attribute (i.e. `:price_in_cents` in `f.input :price_in_cents`);

Now we can use this custom `MoneyInput` for any model and any attribute we want!

### Connecting the label

Our custom input is also responsible for generating the `<label>` tag for our input element. Since we've used a custom name for our input elements, we should tweak the `for` attribute of our `<label>` tag. We can override the `label_html_options` method to do that:

~~~ ruby
def label_html_options
  super.merge(for: "#{@builder.object_name}_#{attribute_name}_1i")
end
~~~

The `label_html_options` returns a hash of options to be sent to Rails' `label_tag` helper method. We use `super` to take the original output and merge in our custom `for` option to connect it to the the first of our two `<input>` tags.

### Putting it all together

Although there’s lots more we could do, we’ve got a working input element now. Here's the complete code of our `MoneyInput`:

~~~ ruby
class MoneyInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    format(
      '&euro; %s,%s'
      input_major,
      input_minor
    ).html_safe
  end

  def label_html_options
    super.merge(for: "#{@builder.object_name} _#{attribute_name}_1i")
  end

  private

  def input_major
    template.text_field_tag(
      "#{@builder.object_name}[#{attribute_name}(1i)]",
      @builder.object.send(attribute_name) / 100,
      id: "#{@builder.object_name}_#{attribute_name}_1i"
    )
  end

  def input_minor
    template.text_field_tag(
      "#{@builder.object_name}[#{attribute_name}(2i)]",
      @builder.object.send(attribute_name) % 100,
      id: "#{@builder.object_name}_#{attribute_name}_2i"
    )
  end
end
~~~

You might have noticed that our `MoneyInput` is now responsible for extracting euros and cents from a single integer value in our model. This is business logic that should definitely not belong in an input type --- which solidly belongs in the presentation layer. Let's fix that, and the issue of how to deal with two parameters for a single attribute, next.

## Models composed of complex values

ActiveRecord models can be composed of complex values, such as `Date` or `DateTime` objects. A `Date` object consists of three integers for year, month and day; to assign a date value, Rails' `date_select` gives us a `<select>` element for each of these. Special parameter name suffices indicate how these values should be parsed.

### Rails parameter parsing for complex types

Posting parameters like these:

~~~ ruby
{
  'product' => {
    'published_on(2i)' => '2',
    'published_on(1i)' => '1972',
    'published_on(3i)' => '23'
  }
}
~~~

...will be handled by Rails more or less like this:

~~~ ruby
product.published_at = Date.new(1972, 2, 23)
~~~

Rails takes the suffices and reads both how to parse the values (`i` for integer) and how to order them in the `Date.new` call (`1`, `2`, `3`). We can also use this feature for our _own_ complex attribute types, such as `Money`.

### Mapping our own complex types

To do so, we can use `composed_of` to let Rails know how it should transform our database values to a Ruby object, and back again:

~~~ ruby
class Product < ActiveRecord::Base
  composed_of :price,
    class_name: 'Money',
    constructor: :from_cents,
    mapping: %w(price_in_cents cents)
end
~~~

We’ve indicated that our model has a `price` attribute that returns a `Money` object. The `constructor` property indicates how `price` values can be read from the database `price_in_cents` column, while the regular `new` method takes input values from our params. Our `Money` class, then, can look like this:

~~~ ruby
class Money
  include Comparable

  # Create a new `Money` from a single database value integer,
  # which is the total amount in cents.
  def self.from_cents(cents)
    new(*cents.divmod(100))
  end

  # Build new `Money` value using a major and minor value,
  # so we don't have to use floats.
  def initialize(major, minor)
    @cents = major * 100 + minor
    freeze
  end

  def major
    @cents / 100
  end

  def minor
    format '%02d', @cents % 100
  end

  def inspect
    "#<Money #{major}.#{minor}>"
  end

  def eql?(other)
    other.is_a?(self.class) &&
      @cents == other.cents
  end

  def <=>(other)
    @cents <=> other.cents
  end
end
~~~

Instances of our new `Money` object are compared and sorted by their `cents` value. We can use it like so:

~~~ ruby
product = Product.new(price_in_cents: 1999)
product.price # => #<Money 19.99>
product.price = Money.new(24, 99)
product.price_in_cents # => 2499
~~~

### Combining custom inputs and complex types

We can now link our `MoneyInput` and `Money` value class together. Rather than calculating euros and cents in the custom input, we can use our new value object. We'll point our input at our "virtual" `price` attribute:

~~~ rhtml
<%= f.input :price, as: :money %>
~~~

...and we'll update `MoneyInput` to work with `Money` values:

~~~ ruby
# app/inputs/money_input.rb
def input_major
  template.text_field_tag(
    "#{@builder.object_name}[#{attribute_name}(1i)]",
    @builder.object.send(attribute_name).major,
    id: "#{@builder.object_name}_#{attribute_name}_1i"
  )
end

def input_minor
  template.text_field_tag(
    "#{@builder.object_name}[#{attribute_name}(2i)]",
    @builder.object.send(attribute_name).minor,
    id: "#{@builder.object_name}_#{attribute_name}_2i"
  )
end
~~~

Now we'll post two ordered integer parameters to the `price` attribute, which will construct a new `Money` object in our model. This will, in turn, be persisted into the `price_in_cents` column. We've got a nicely re-usable but non-trivial input type and a pretty value object on the server side to go along with it. Nice!

## Conclusion

Simple Form helps us write consistent markup that is easy to style, and nudges us into the right direction towards value objects and away from primitive obsession. The wrapper DSL and structure of custom input classes has a bit of a learning curve, but it is worth your while to get to know them. Simple Form is, when used correctly, a real time saver in Rails projects.

[Plataformatec]: http://plataformatec.com.br/
[Simple Form]: https://github.com/plataformatec/simple_form
[Rails]: http://rubyonrails.org
[form_for]: http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html
[form builder]: http://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html
[form helpers]: http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html
