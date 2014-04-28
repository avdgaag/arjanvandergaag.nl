---
title: Working with Rails Attributes magic
kind: article
created_at: 2014-04-25 20:00
tags:
  - Ruby
  - Rails
  - Programming
tldr:
  Rails has a lot of magic we sometimes need to work around. Luckily, we can.
---
The [Rails][] framework comes with a lot of magic. Sometimes magic makes us
productive, sometimes we need to work around it. One such area is how Rails is
coupled to your database to provide some seemingly basic functionality.
{: .leader }

ActiveRecord provides the handy `store` macro through [ActiveRecord::Store][]
that allows us to define a group of accessor methods that will be serialised
together in a single text column in JSON, YAML or some other format. It's handy
for NoSQL-like flexible schema's in your traditional relational database, or for
quickly fleshing out a design you're not too sure of yet.

Here's how you define three attributes on an ActiveRecord model that will get
serialised to a single text column in JSON format:

{: .language-ruby }
    class Product < ActiveRecord::Base
      store :properties,
            acessors: %i(color size available_on),
            coder: JSON
    end

Given you have a `properties` column in your `products` table, you can now use
these like so:

{: .language-ruby }
    product = Product.new
    product.color # => nil
    product.color = 'Red'
    product.save
    product.properties
    # => "{ \"color\": \"Red\" }"

It's kind of neat, but you might run into some unexpected problems. Here are a
few I have run into.

## Reading string-typed values

You cannot use Rails' default `date_select` or `datetime_select` helpers in your
forms, as our `available_at` does not return a `DateTime` object. You will most
likely be greeted by an error like:

{: .language-ruby }
    NoMethodError: undefined method 'day' for "2014-03-12":String

Luckily, this is easily solved with a custom reader method:

{: .language-ruby }
    def available_at
      return super.to_datetime if super.respond_to?(:to_datetime)
      DateTime.parse(super)
    end

This is not waterproof, but will suffice for most use cases to ensure we always
get a `DateTime` object back.

## Multi-parameter assignment errors

Second, try writing to our `available_at` property through a form. Rails has no
knowledge that our virtual column should contain a `DateTime` object, so any
value assigned to `available_at` will be assigned as-is (i.e. a string).

This will trigger a `ActiveRecord::MultiparameterAssignmentErrors` error,
without too much hints on how to fix it. The thing is, Rails uses a special
convention for its parameters' names in order to create values through
constructor methods that take multiple parameters.

Here's what usually happens. Fist, when you use a `datetime_select` helper to
pick "2014-04-21 12:53", Rails receives the following parameters:

{: .language-ruby }
    {
      "product[available_at(2i)]" => "4", 
      "product[available_at(4i)]" => "12",
      "product[available_at(1i)]" => "2014",
      "product[available_at(3i)]" => "21", 
      "product[available_at(5i)]" => "53", 
    }

Which it parses to a hash like this:

{: .language-ruby }
    {
      :product => {
        "available_at(2i)" => "4", 
        "available_at(4i)" => "12",
        "available_at(1i)" => "2014",
        "available_at(3i)" => "21", 
        "available_at(5i)" => "53", 
      }
    }

The parameter keys have extra information about their order (1 through 5) and
type (`i` stands for integer). ActiveRecord will construct an assignment
operation like this:

{: .language-ruby }
    self.available_at = DateTime.new(
        params["available_at(1i)"].to_i,
        params["available_at(2i)"].to_i,
        params["available_at(3i)"].to_i,
        params["available_at(4i)"].to_i,
        params["available_at(5i)"].to_i
    )

Ordering and coercing parameters seems reasonable here, but how does it know to
use `DateTime`? Rails looks at the column definition:

{: .language-ruby }
    column = Product.columns_hash['available_at']
    column.type  # => :datetime
    column.klass # => DateTime

This information is, of course, read by introspecting the database. This should
clarify why this doesn't work with virtual attributes: **they have no column
definition to indicate which class should be used to create the property
value**.

We _could_ go into our controller and try to wrestle the incoming parameters
there, and do the sort-coerce-instantiate routine there and just pass our model
a nice `DateTime` object, but down that path madness lies. Instead, let's just
tell Rails to use the logic it already has for constructing multi-parameter
values:

{: .language-ruby }
    class Product < ActiveRecord::Base
      self.columns_hash['available_at'] = OpenStruct.new(type: :datetime, klass: DateTime)
    end

Technically, we only need our fake column object to respond to the `klass`
method, but also responding to `type` will help form builders such as
[simple_form][] to decide on which controls to use.

## Metaprogramming to the rescue (of course)

So we've got some custom code to make our virtual `available_at` column work.
Here's the full picture:

{: .language-ruby }
    class Product < ActiveRecord::Base
      store :properties,
            acessors: %i(color size available_on),
            coder: JSON
      
      self.columns_hash['available_at'] = OpenStruct.new(type: :datetime, klass: DateTime)
      
      def available_at
        return super.to_datetime if super.respond_to?(:to_datetime)
        DateTime.parse(super)
      end
    end

It is not terrible, but introduce multiple datetime fields and you'll quickly
clutter up your model definition. Enter [concerns][] and metaprogramming:

{: .language-ruby }
    module ProductProperties
      extend ActiveSupport::Concern

      PROPERTIES = %i(color size available_at).freeze

      included do
        store :properties,
              acessors: PROPERTIES,
              coder: JSON
      
        PROPERTIES.map(&:to_s).grep(/_at$/).each do |property|
          self.columns_hash[property] = OpenStruct.new(type: :datetime, klass: DateTime)

          define_method property do
            return super.to_datetime if super.respond_to?(:to_datetime)
            DateTime.parse(super)
          end
        end
      end      
    end

    class Product < ActiveRecord::Base
      include ProductProperties
    end

We use a module that will loop over all properties ending in `_at` and define
the proper fake column definitions and reader methods for us. This concept is
easily extended to columns ending in `_on`, which should use the `Date` class
instead.

## Conclusion

Introducing more plain Ruby to Rails projects, such as custom attribute accessor
methods that do not necessarily map directly to database columns, reveals the
extent to which Rails (and especially ActiveRecord) is coupled to the database.
That allows us a great deal of speed and focus on some areas; but sometimes
you'll really have to dive in and figure out a way to work _around_ the
framework. But I think that's a reasonable price to pay.

[simple_form]:         https://github.com/plataformatec/simple_form
[ActiveRecord::Store]: http://api.rubyonrails.org/classes/ActiveRecord/Store.html
[Rails]:               http://rubyonrails.org
[concerns]:            http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
