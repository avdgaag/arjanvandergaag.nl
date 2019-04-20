---
title: Using updatable views in PostgreSQL
kind: article
created_at: 2019-04-20 12:00
tags:
  - postgresql
  - SQL
---
Liberal use of views is key to good database design, [according to the PostgreSQL documentation](https://www.postgresql.org/docs/11/interactive/tutorial-views.html). They might be a bit of a hassle to use properly, but they have the potential to greatly simplify your application layer.
{: .leader }

## An example schema

To illustrate the usage of views, let’s use a simple example schema to play around with. Consider a web shop selling products. It serves international customers, so it presents products in multiple languages. Its database might have these tables:

~~~sql
create table products (
  code character varying primary key,
  price integer not null,
  archived_at timestamp without time zone
);

create table product_contents (
  language character varying,
  code character varying references products(code),
  title character varying not null,
  description text,
  constraint product_content_pkey primary key (language, code)
);
~~~

We’ve got a `products` table containing our product code, unit price in cents and a timestamp to record when a product was archived. After this date, we should no longer show it in our shop. The `product_contents` table has a title and description for a product in a particular language, denoted by `language`.

Let’s add a few records:

~~~sql
insert into products
  (code, price, archived_at)
values
  ('abc123', 1099, null),
  ('def456', 899, '2018-12-31 12:00:00');

insert into product_contents
  (language, code, title, description)
values
  ('en-GB', 'abc123', 'Squeaky toy', 'Your dog will love it.'),
  ('nl-NL', 'abc123', 'Piepspeelgoed', 'Je hond zal het geweldig vinden.');
~~~

## Automatically updatable views

[Simple views in PostgreSQL are _automatically updatable_](https://www.postgresql.org/docs/11/interactive/sql-createview.html#SQL-CREATEVIEW-UPDATABLE-VIEWS). That means that you can `insert`, `update` and `delete` on them, and PostgreSQL will figure out how to translate your queries to the actual table for you. Let’s see it in action with a simple view to get only the non-archived products:

~~~sql
create view current_products as 
select code, price, archived_at
  from products
 where archived_at is null;
~~~

Of course, we can `select` from this view and only ever get records where `archived_at` is `null`. But we can also `insert` a new row into our table:

~~~sql
insert into current_products (code, price)
values ('ghi789', 499);
~~~

Our new row got inserted into our table, with `null` set for our unspecified `archived_at` column (not because `archived_at` was not specified, but because our view uses `null` in its condition):

~~~
=# select * from products;
  code  │ price │     archived_at     
────────┼───────┼─────────────────────
 abc123 │  1099 │ NULL
 def456 │   899 │ 2018-12-31 12:00:00
 ghi789 │   499 │ NULL
(3 rows)
~~~

You might wonder what happens when you _do_  specify a value for `archived_at` in this query. Let’s see:

~~~sql
insert into current_products
  (code, price, archived_at)
values
  ('archprod', 499, '2018-01-01 12:00');
~~~

This doesn’t really make sense from a logical point of view, but technically, it works! PostgreSQL will happily insert the row for you:

~~~
=# select * from products;
      code       │ price │     archived_at     
─────────────────┼───────┼─────────────────────
 abc123          │  1099 │ NULL
 def456          │   899 │ 2018-12-31 12:00:00
 ghi789          │   499 │ NULL
 archivedproduct │   499 │ 2018-01-01 12:00:00
(4 rows)
~~~

Depending on your application, you may or may not like this behaviour. You can control it using [the `with local check option` or `with cascaded check option` on your view definition](https://www.postgresql.org/docs/11/interactive/sql-createview.html#id-1.9.3.97.6.2.7.1.2):

~~~sql
create view current_products as 
select code, price, archived_at
  from products
 where archived_at is null
with cascaded check option;
~~~

This clause will tell PostgreSQL to check whether the inserted row will be visible in the view. If not, the operation is rejected:

~~~
=# insert into current_products (code, price, archived_at)
values ('archivedproduct2', 499, '2018-01-01 12:00');
ERROR:  new row violates check option for view "current_products"
DETAIL:  Failing row contains (archivedproduct2, 499, 2018-01-01 12:00:00).
~~~

## Read-only views

Views are not automatically updatable but _read-only_ when they reference multiple tables or use aggregates (see the [exact list of requirements](https://www.postgresql.org/docs/11/interactive/sql-createview.html#SQL-CREATEVIEW-UPDATABLE-VIEWS)). Let’s create a view that is read-only:

~~~sql
create view current_product_versions as
select code, price, language, title, description
  from current_products
  join product_contents using (code);
~~~

It will give us a row for each translated product:

~~~
=# select * from current_product_versions;
  code  │ price │ language │     title     │           description            
────────┼───────┼──────────┼───────────────┼──────────────────────────────────
 abc123 │  1099 │ en-GB    │ Squeaky toy   │ Your dog will love it.
 abc123 │  1099 │ nl-NL    │ Piepspeelgoed │ Je hond zal het geweldig vinden.
(2 rows)
~~~

Also note how `current_product_versions` references our earlier `current_products` view, rather than the original table! But it’s the `join` clause that makes `current_product_versions` read-only. If we try to write to it, PostgreSQL will raise an error:

~~~
=# insert into current_product_versions (code, price, language, title, description) values ('xxx', 999, 'en-US', 'Squeaky toy', 'Yo dawg will dig it');
ERROR:  cannot insert into view "current_product_versions"
DETAIL:  Views that do not select from a single table or view are not automatically updatable.
HINT:  To enable inserting into the view, provide an INSTEAD OF INSERT trigger or an unconditional ON INSERT DO INSTEAD rule.
~~~

We can still simulate writing to it using triggers to replace the default behaviour of `insert`, `update` and `delete` operations. For example, here’s how we might replace inserts on our view:

~~~sql
create or replace function insert_current_product_version() returns trigger as $$
declare
begin
  insert into current_products (code, price)
  select NEW.code, NEW.price;
  insert into product_contents (language, code, title, description)
  select NEW.language, NEW.code, NEW.title, NEW.description;
  return NEW;
end;
$$ language plpgsql;

create trigger insert_current_product_version_trg
instead of insert on current_product_versions
for each row execute function insert_current_product_version();
~~~

We define a trigger `insert_current_product_version_trg` to call function `insert_current_product_version` _instead of_ an insert operation. The trigger function `insert_current_product_version` can access the virtual row to be inserted using [the special `NEW` variable](https://www.postgresql.org/docs/11/interactive/plpgsql-trigger.html#PLPGSQL-DML-TRIGGER) and can use it to perform two different inserts into actual tables.

With this trigger set up, we _can_ insert rows:

~~~
=# insert into current_product_versions
   (code, price, language, title, description)
   values ('xxx', 999, 'en-US', 'Squeaky toy',
   'Yo dawg will dig it');
INSERT 0 1
~~~

We can follow the same approach for update and delete operations. But there are a few important caveats to keep in mind:

* although technically not required for PostgreSQL, many ORMs depend on the returned number of affected rows for these operations. Make sure to not just `return null` from your trigger functions.
* your triggers run _before_ your statement has gotten a chance to reach to target table and use its default values. Therefore, your triggers are unaware of the underlying column defaults, unless you explicitly add them to your view using `alter table`.
* views in PostgreSQL do not have primary key constraints. If your ORM tries to auto-detect a primary key, it will mostly likely fail unless you explicitly tell it which column(s) should be treated as primary key.

Most of these caveats are also further explained in [the PostgreSQL documentation about trigger functions](https://www.postgresql.org/docs/11/interactive/plpgsql-trigger.html#PLPGSQL-DML-TRIGGER).

## When to use views

Views are a powerful way to design how your application reads and writes data, independent from the optimal storage/normalisation solution for your data. A well-crafted view can greatly simplify your application code. Then again, not every query generated by your ORM should be replaced by a view in the database. I try to use this guideline: how should data access work across applications (perhaps written with different languages and frameworks) all accessing the same database? I use it to keep my application logic in my application, and my data design in my database.

## Why use views at all?

Dealing with read-only views via triggers and functions can be a hassle. Are they worth it?

First, lots of views you’ll write will indeed be automatically updatable, so that removes most of the hassle. Introducing views will enrich your domain vocabulary and help your application deal more with _business_ logic than with _storage_ logic.

Second, views are helpful when you’re not the only client for a data store. Data has a longer lifespan than code, so chances are your application will get replaced at some point, while your database lives on. Using views instead of extensive application logic keeps the data logic where it belongs.

Third, using views can be helpful when performing incremental upgrades to the underlying data model. For example, when splitting or combining tables to make future changes easier, it is helpful to introduce a temporary view so the application can keep functioning like before. This lets you make small steps and keep the application in a working state, rather than embarking on a massive rewrite where you can only hope you’ll get it back in a working state at the end.

Lastly, the hassle that comes with using views is simple enough. It’s not necessarily _easy_, and functionality in database functions and triggers are not directly obvious, but it’s all still rather straightforward — once you know the pitfalls. Now you do, so have fun!
