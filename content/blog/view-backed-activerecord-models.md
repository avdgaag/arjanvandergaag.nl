---
title: View-backed ActiveRecord models
kind: article
created_at: 2019-06-04 20:30
tags:
  - postgresql
  - SQL
  - Ruby
  - Rails
---

[Views are a useful tool to use in database design](http://arjanvandergaag.nl/blog/postgresql-updatable-views.html). But frameworks like Rails mostly assume you are writing models around database tables, not views. Still, with some tweaks, there is nothing stopping us from creating ActiveRecord models around views.
{: .leader }

## An example schema

Say we have a Rails application for a webshop that sells products in multiple languages. Here is the migration that creates the tables for our `Product` and `ProductContent` models:

~~~ruby
class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :product_contents do |t|
      t.string :title
      t.text :description
      t.string :language, limit: 5
      t.references :product, foreign_key: true
      t.integer :lock_version, default: 0, null: false
      t.timestamps
    end

    create_table :products do |t|
      t.string :code
      t.integer :price
      t.datetime :archived_at
      t.timestamps
    end
  end
end
~~~

Our `products` table uses a special `archived_at` column to indicate whether a product is still available (`archived_at is null`) or whether it should be hidden from our website (`archived_at is not null`). A product has content (`title`, `description`) in different languages in `product_contents`. Let’s ignore constraints and indices for now.

## An ActiveRecord model

We could write ActiveRecord models like the following:

~~~ruby
# app/models/product.rb
class Product < ApplicationRecord
  has_many :product_contents

  scope :current, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
end

# app/models/product_content.rb
class ProductContent < ApplicationRecord
  belongs_to :product
end
~~~

This would work fine. However, when you’re dealing with a `Product` you need to remember to use an `archived` or `current` scope, or surprising things may happen. You might, therefore, be tempted to use `default_scope`:

~~~ruby
class Product < ActiveRecord::Base
  has_many :product_contents

  scope :archived, -> { where.not(archived_at: nil) }
  scope :current, -> { where(archived_at: nil) }
  default_scope { current }
end
~~~

When you use `default_scope`, however, you will soon be reaching for `unscoped` to bypass it. Down this road well-documented madness lies.

What’s more, in your model you will start writing methods that will need to check for the value of `archived_at` to determine whether the operation is allowed. Should you be allowed to update an archived product? Order an archived product? If you find yourself writing a bunch of conditionals to decide what to do based on the internals of an object, good object oriented design practices tell us we need to introduce a new object.

## A view-backed model

Let’s use a view to encapsulate the distinction between a current and an archived product. In this case, we’ll introduce a new term in our domain model called _current product_ to indicate a product that has not been archived. Let’s write a migration to create a “current products” view:

~~~ruby
class CreateCurrentProducts < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
    create view current_products as
    select *
      from products
     where archived_at is null
    with cascaded check option
    SQL
  end

  def down
    execute 'drop view current_products'
  end
end
~~~

And configure our application to maintain it’s schema in SQL format, rather than a Ruby DSL:

~~~ruby
# in config/application.rb
config.active_record.schema_format = :sql
~~~

Once we’ve run our migrations and our view is in place, we can create a model for it:

~~~ruby
# app/models/current_product.rb
class CurrentProduct < ApplicationRecord
end
~~~

Let’s verify it works with some tests. First, we’ll need some test data:

~~~yaml
# test/fixtures/products.yml
toy:
  code: sqtoy
  price: 1

leash:
  code: leash
  price: 1
  archived_at: 2018-12-31 12:00:00
~~~

Then, we can verify if fetching all “current product” records gives us the expected results:

~~~ruby
# test/models/current_product_test.rb
require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  test "includes only current products" do
    assert_equal ["sqtoy"], CurrentProduct.pluck(:code)
  end
end
~~~

It passes!

## The pitfalls of working with views

In [my earlier post about updatable views in PostgreSQL][views], I noted a few pitfalls when working with views:

1. Views in PostgreSQL do not have primary keys.
2. The number of affected rows returned from trigger operations on read-only views is significant.
3. Trigger functions on read-only views have no knowledge of the underlying table’s default values, so you will have to explicitly set them again on the view.

Let’s review how these issues work in practice in our Rails application.

## 1. Primary keys

Loading multiple records at the same time using our `CurrentProduct` model works fine. But look what happens when we try to load a single record:

~~~ruby
test "loads a single recor" do
  toy_id = products(:toy).id
  assert_equal "sqtoy", CurrentProduct.find(toy_id).code
end
# Error:
# ProductTest#test_loads_a_single_recor:
# ActiveRecord::UnknownPrimaryKey: Unknown primary key for table current_products in model CurrentProduct.
#     test/models/current_product_test.rb:9:in `block in <class:ProductTest>'

~~~

Without the ability to infer the primary key column from the schema, Rails cannot find a record by a single value for us. We’ll need to explicitly tell it which column to use are our “primary key”:

~~~ruby
class CurrentProduct < ApplicationRecord
  self.primary_key = :id
end
~~~

With that change, our test should pass.

**Note**: Rails does not support composite primary keys. Therefore, take care to design your views in such a way that you can use an original table `id` column as primary key.

## 2a. Number of affected rows: deleting

When updating read-only views through trigger functions, return values matter. To demonstrate this, let’s create a non-simple view to use a `join` to combine `current_products` and `product_contents`:

~~~ruby
class AddCurrentProductVersions < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
    create view current_product_versions
    as select
      c.id,
      p.id as product_id,
      p.code,
      p.price,
      c.title,
      c.description,
      c.language,
      c.created_at,
      c.updated_at
    from current_products p
      join product_contents c on p.id = c.product_id
    SQL
  end

  def down
    execute 'drop view current_product_versions'
  end
end
~~~

The join makes this a read-only view. We could define our model like so:

~~~ruby
# app/models/current_product_version.rb
class CurrentProductVersion < ApplicationRecord
  self.primary_key = :id
end
~~~

Let’s try to delete a record:

~~~ruby
test "can delete a record" do
  product = Product.create!(code: "rope", price: 4)
  product_content = product.product_contents.create!(
    title: "Play rope",
    description: "A rope to play tug of war with",
    language: "en-GB"
  )
  cpv = CurrentProductVersion.find(product_content.id)
  assert cpv.destroy
end
~~~

To make this work, we implement an `instead of delete` trigger:

~~~sql
create or replace function delete_current_product_versions()
returns trigger as $$
declare
begin
  delete from product_contents where id = OLD.id;
  delete from products where id = OLD.product_id;
  return OLD;
end;
$$ language plpgsql;

create trigger trg_delete_current_product_versions
instead of delete on current_product_versions
for each row execute function delete_current_product_versions();
~~~

Again, our return value (`return OLD`) is significant: it indicates our operation _succeeded_ and should therefore be counted in the number of affected operations. ActiveRecord’s optimistic locking (triggered by the `lock_version` column) wraps `update` and `delete` operations and adds an extra condition to the query to check for the right version. For example, `delete from current_product_versions where id = 1` becomes `delete from current_product_versions where id = 1 and lock_version = 3`. ActiveRecord then looks at the number of rows affected by the operation. When one row is affected, all is well. When zero rows are affected, ActiveRecord assumes that’s because the lock version was out of sync and it raises an `ActiveRecord::StaleObject` error. By using `return OLD`, we indicate one row was affected by this trigger, and therefore avoid this error. Note that without the `lock_version` column we would not have had this problem, as ActiveRecord would have ignored the number of rows affected.

## 2b. Number of affected rows: inserting

We want to be able to use fixtures for our view so we can write some more tests. To accomplish that, we need the ability to `insert` into our view. Let’s write a `instead of insert` trigger function:

~~~sql
create or replace function insert_current_product_versions()
returns trigger as $$
declare
begin
  with inserted_product as (
    insert into products (code, price, created_at, updated_at)
    values (NEW.code, NEW.price, NEW.created_at, NEW.updated_at)
    returning id
  ) insert into product_contents
    (title, description, language, product_id, created_at, updated_at)
  select
    NEW.title, NEW.description, NEW.language, inserted_product.id, NEW.created_at, NEW.updated_at
  from inserted_product;
  return NEW;
end;
$$ language plpgsql;

create trigger trg_insert_current_product_versions
instead of insert on current_product_versions
for each row execute function insert_current_product_versions();
~~~

With this, we can verify inserts work with a test:

~~~ruby
def valid_attributes
  # ...
end

test "can create a new record" do
  cpv = CurrentProductVersion.create!(valid_attributes)
end
~~~

Our test verifies inserting works at all (if it doesn’t, `create!` will raise an exception). It looks good, but let’s make one extra assertion:

~~~ruby
test "can create a new record" do
  cpv = CurrentProductVersion.create!(valid_attributes)
  refute_nil cpv.id
end
~~~

This test fails because the `id` is `nil`! Again, our trigger function return value matters: we do return `NEW`, as we should, but `NEW` only contains the data ActiveRecord gave to the database in the first place. It does not contain the newly generated value for `id`. Let’s adapt our trigger function to also return that value:

~~~sql
create or replace function insert_current_product_versions()
returns trigger as $$
declare
  new_id bigint;
begin
  with inserted_product as (
    insert into products (code, price, created_at, updated_at)
    values (NEW.code, NEW.price, NEW.created_at, NEW.updated_at)
    returning id
  ) insert into product_contents
    (title, description, language, product_id, created_at, updated_at)
  select
    NEW.title, NEW.description, NEW.language, inserted_product.id, NEW.created_at, NEW.updated_at
  from inserted_product returning id into new_id;
  NEW.id = new_id;
  return NEW;
end;
$$ language plpgsql;
~~~

Note how we modify `NEW` to add our `new_id` to it.

## 3. Using column defaults via read-only views

Let’s set up our fixtures:

~~~yaml
# test/fixtures/current_product_versions.yml
ball:
  code: ball
  price: 3
  title: Ball
  description: A soft green ball to chew on
  language: en-GB
~~~

All seems well until we write a test to load a fixture record:

~~~ruby
test "can find a fixture row" do
  ball = current_product_versions(:ball)
  assert_equal ball, CurrentProductVersion.find(ball.id)
end
~~~

When we try to load a record by ID, it mysteriously fails. We’ve found an issue with how we _insert_ records!

Rails generates fixture IDs based on the fixture _names_. It therefore really wants to explicitly set IDs when inserting fixtures. But our `insert_current_product_version` function completely ignores any given IDs! We’ll need to explicitly include the ID value in our `insert` statements. Let’s try it by changing `insert_current_product_version` to:

~~~sql
create or replace function insert_current_product_versions()
returns trigger as $$
declare
  new_id bigint;
begin
  with inserted_product as (
    insert into products (code, price, created_at, updated_at)
    values (NEW.code, NEW.price, NEW.created_at, NEW.updated_at)
    returning id
  ) insert into product_contents
    (id, title, description, language, product_id, created_at, updated_at)
  select
    NEW.id, NEW.title, NEW.description, NEW.language, inserted_product.id, NEW.created_at, NEW.updated_at
  from inserted_product returning id into new_id;
  NEW.id = new_id;
  return NEW;
end;
$$ language plpgsql;
~~~

Note how we have now included the `NEW.id` value in our outer-most `insert` statement. Run our tests again, and… failure!

~~~
ProductContentTest#test_can_create_a_new_record:
DRb::DRbRemoteError: PG::NotNullViolation: ERROR:  null value in column "id" violates not-null constraint
~~~

What gives? Our earlier test suddenly fails! Turns out, views do not “inherit” column default values from the tables they reference. Therefore, no default value — not even for the `id` column — will be applied before our trigger function runs. Now we no longer omit `id` from our `insert`, we are explicitly sending `null`, which is invalid. The best way (if not the most DRY) is to add a default value to the view:

~~~sql
alter table current_product_versions
alter id set default nextval('product_contents_id_seq')
~~~

Add this to your migration, re-run it, and now all the tests should pass. If any other column defaults are relevant, you’ll have to copy them to the view to have them take effect.

## A word of caution regarding fixtures

Using fixtures can be nice, but beware: using fixtures for both tables _and_ views can lead to unexpected results. When loading fixtures, Rails will delete everything from a table and then insert all new fixtures. Let’s assume you’ve loaded fixtures for the `products` table and then try to load fixtures for the `current_product_versions` view. Rails will first `delete from current_product_versions` — and our `delete_current_product_versions` function will delete all of our `products`. This is not what we want, and I know of no simple way to avoid this issue. If instead of fixtures you’re using factories of some sort, you’ll most likely not run into this problem. If you are using fixtures, the best way to avoid this issue is to use either fixtures for tables, or for views, but not both.

## Re-cap

When using view-backed ActiveRecord models, remember the following:

* set an explicit primary key in your ActiveRecord model;
* If your views are not automatically updatable…
	* explicitly add column defaults to your view;
	* be sure to `return OLD` from your `instead of delete` trigger function;
	* be sure to `return NEW` from your `instead of update` and `instead of insert` functions…
	* …but modify `NEW` to include any newly generated values, such as auto-incrementing ID.
	* take care to explicitly set IDs in your trigger functions;
* Don’t mix fixtures for tables and views.

## Is it worth the hassle?

Effectively using database views with ActiveRecord in a Rails project takes some work, especially when it concerns read-only views that you have to provide triggers for. Still, I believe views _are_ worth the hassle. If you know the pitfalls — and now you do — it is relatively easy to avoid them.

Admittedly, logic in triggers and functions in the database is not directly obvious or as easy to maintain as regular application code is. But Rails’ migrations and schema do give you a single source of truth for these database objects.

So my conclusion is view-backed models are definitely safe enough to try, with the potential to greatly improve your codebase. Give them a try!

[views]: http://arjanvandergaag.nl/blog/postgresql-updatable-views.html
