---
title: Splitting two tables using SQL
kind: article
created_at: 2019-06-04 20:30
tags:
  - postgresql
  - SQL
---
Say you have a PostgreSQL database and you want to move some columns from one table into another table, and replace them with a foreign key pointing to that new table — using just SQL. Here’s one way to do it.
{: .leader }

## Example schema

Let’s suppose we have a schema like the following:

~~~sql
create table products (
  id serial primary key,
  code character varying,
  price integer not null,
  title character varying not null,
  description text
);
~~~

This table holds products we sell in our webshop. But in comes a new requirement to support multiple languages: we’ll need to store translations of the `title` and `description` columns. So we pile on an extra column in our table:

~~~sql
create table products (
  id serial primary key,
  code character varying,
  price integer not null,
  title character varying not null,
  description text,
  language character varying not null
);
~~~

We set all our current products to language `en-GB` and we duplicate every row, set its `language` to `nl-NL` and translate the `title` and `description`fields.

It works, but now we’ve duplicated all our `code` and `price` fields. Let’s remedy that.

## The desired situation

We want to the data and IDs in our products table mostly intact, so we’re looking to move the `code` and `price` columns into a _new_ table. Here’s what we’ll do:

1. Rename `products` to `product_contents`
2. Add a new table `products`
3. Move `code` and `price` from `product_contents` to `products`
4. Add a foreign key from `product_contents` to `products`

## Our approach

Let’s ignore steps one and two for now, and focus on the moving part. We are going to solve this problem in three steps (in reverse order):

1. we want to update `product_contents` with a newly generated ID from `products`;
2. therefore, we want to insert `products` with a `code` and `price`;
3. therefore, we need some way to associate an existing row in `product_contents` with a new row in `products`.

## First steps

To update `product_contents` we know we want to do something like this:

~~~sql
update product_contents
   set product_id = ???
 where id = ???
~~~

We’re not quite sure yet how to fill in the blanks. For our insert operation, we want something like this to insert _into_ one table by _selecting_ from another:

~~~sql
insert into products (code, price)
select code, price
  from product_contents;
~~~

## Using common table expressions (CTEs)

We can combine the two using [common table expressions](https://www.postgresql.org/docs/11/interactive/queries-with.html):

~~~sql
with inserts as (
  insert into products (code, price)
  select code, price
    from product_contents
  returning id
)
update product_contents
   set product_id = inserts.id
  from inserts
 where id = ???
~~~

Using a `with` clause allows us to `insert` some rows first, and then refer to the results of that insertion in our `update` statement. We know we’ll somehow want to set `product_contents.product_id` to the right `inserts.id` value. Now we only need to figure our which row in `products` belongs to which row in `product_contents`.

## Associating new rows with old rows

We can do that by first associating all new IDs to be used in `products` and associating them with the `product_contents`:

~~~sql
select nextval('products_id_seq'), *
  from product_contents;
~~~

This will give us all the rows from `product_contents` along with a unique sequence value for the `products.id` column. Let’s use these IDs in our `insert`:

~~~sql
with product_contents_with_product_ids as (
  select nextval('products_id_seq') as new_product_id, *
    from product_contents
), inserts as (
  insert into products (id, code, price)
       select new_product_id, code, price
         from product_contents_with_product_ids
    returning id
)
update product_contents
   set product_id = inserts.id
  from inserts
 where id = ???
~~~

By looking at the `product_contents_with_product_ids` query results rather than the `product_contents` table we can now insert into `products` using IDs that are already associated with rows in `product_contents`.

## Joining old and new rows in our update

Now all that is left is to write our `update` join condition to insert the right ID into `product_contents`:

~~~sql
with product_contents_with_product_ids as (
  select nextval('products_id_seq') as new_product_id, *
    from product_contents
), inserts as (
  insert into products (id, code, price)
       select new_product_id, code, price
         from product_contents_with_product_ids
    returning id
)
update product_contents
   set product_id = inserts.id
  from inserts, product_contents_with_product_ids i
 where id = i.id
   and i.new_product_id = inserts.id
~~~

So this allows us to copy entire columns into a new table and use the inserted results to populate a new foreign key column in the old table — all in one query.

## Dealing with conflicting products

Finally, the whole point of this operations is to avoid duplication of product data (`code` and `price`). If we do already have duplication in `product_contents`, our `insert into products` is bound to generate some conflicts (assuming we’re using `code` as a primary key, or at least have set a unique constraint on it). We could try to deal with this by using [an `on conflict` clause](https://www.postgresql.org/docs/11/interactive/sql-insert.html#SQL-ON-CONFLICT):

~~~sql
insert into products (id, code, price)
     select new_product_id, code, price
       from product_contents_with_product_ids
on conflict do nothing
  returning id
~~~

Although this is the behaviour we want, it won’t actually do what we need. The `do nothing` does indeed mean nothing will be done, and therefore nothing will be returned. Our CTE expects the insertion to contain IDs for inserted rows, and our upsert will _not_ return the id of the already existing `products` record.

The easiest ([albeit not entirely waterproof](https://stackoverflow.com/questions/34708509/how-to-use-returning-with-on-conflict-in-postgresql#answer-42217872)) way is to make a fake update to the row, to ensure we don’t insert a new row but do return an id:

~~~sql
insert into products (id, code, price)
     select new_product_id, code, price
       from product_contents_with_product_ids
on conflict do update set code = EXCLUDED.code
  returning id
~~~

The end result of our insert trigger function becomes:

~~~sql
with product_contents_with_product_ids as (
  select nextval('products_id_seq') as new_product_id, *
    from product_contents
), inserts as (
  insert into products (id, code, price)
       select new_product_id, code, price
         from product_contents_with_product_ids
  on conflict do update set code = EXCLUDED.code
    returning id
)
update product_contents
   set product_id = inserts.id
  from inserts, product_contents_with_product_ids i
 where id = i.id
   and i.new_product_id = inserts.id
~~~

