---
title: Using PostgreSQL constraints
kind: article
tags:
  - PostgreSQL
  - SQL
  - Databases
  - Elixir
  - Ecto
created_at: 2019-03-16 09:32
---
A RDBMS such as PostgreSQL is not a data store, like a file on disk. It’s a data management system whose capabilities are often overlooked by developers relying solely on an ORM to deal with data. Constraints are a good example of an overlooked but useful feature. 
{: .leader }

A few years back, I was developing a Ruby on Rails application. Someone casually mentioned to me that they needed an extra user in my database so _their_ application could also access some of the data. I freaked out: if anyone but _my_ carefully crafted application would access that database, madness would ensue! How would this other application know of all the beautiful validations I had written in my application code? They could mess up all my application’s assumptions about the data and break it! I decided I needed to learn more about how to keep my data safe.

Sooner or later, every database will be accessed by some other application. That other application might be an actual other application, or it might be your own, six months into the future. New developers will write code communicating with your database, and many new services will interact with it concurrently. You will need to keep your data safe, **at the data level**. Constraints are one of the tools helping you do that.

Examples of constraints include a unique constraint on a column, or a foreign key constraint to ensure a value in one column also exists in another column. But let’s focus on some less common constraints when using PostgreSQL: the _check constraint_ and the _exclusion constraint_.

## Using check constraints 

A [check constraint](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-CHECK-CONSTRAINTS) can be used to ensure that all values for a given column satisfy a given boolean expression. For example, we might have a table with invoice lines in an ordering system:

~~~sql
create table invoice_lines (
  id serial primary key,
  product_id integer references products(id) not null,
  invoice_id integer references invoices(id) not null,
  quantity integer not null default 0
);
~~~

A `quantity` column with a negative value would not make sense, so we could add a check constraint to disallow negative values:

~~~sql
alter table invoice_lines
add constraint positive_quantity_check (quantity >= 0);
~~~

Now we can no longer insert rows with a negative value for the `quantity` column:

~~~sql
insert into invoice_lines (product_id, invoice_id, quantity) values (1, 1, -1);
[Err] ERROR:  new row for relation "invoice_lines" violates check constraint "positive_quantity_check"
DETAIL:  Failing row contains (1, 1, -1).
~~~

### Checks as boolean expressions

Check constraints use boolean expressions. You can use the usual operators, such as `=`, `<`, `>`, `>=` and `<=`; but you there are many more — and you can also use functions. Here are a few examples of check constraint expressions:

* `position('@' in email) > 0` to check whether an email column actually contains an @.
* `postcode ~ '^\d{4} ?[A-Z]{2}$'`  to check a postcode column against a regular expression for valid Dutch postcodes.
* `age(date_of_birth) < interval '150 years'` to check a person is entering a reasonable birth date.
* `char_length(trim(name)) > 0` is a (little convoluted) way to check a name column is not an empty or blank string, such as `"   "`.
* `created_at <= updated_at` to make sure two date column are always in the right order.

In the last example we can see check constraints are not limited to a single column; your expression can reference any column in the row.

## Wrap common constraints in domain types

Our database might also have an inventory table, also including a `quantity` column. The same constraints about negative values would apply there. We could repeat the check constraint, but we could also wrap our check in a _domain type_.

A [PostgreSQL domain type](https://www.postgresql.org/docs/11/domains.html) is “custom” data type that is based on a regular datatype, but with associated check constraints defined on them. You can then use these domain types as a column type in your data definition. Let’s create a `positive_integer` type:

~~~sql
create domain positive_integer 
as integer
default 0
check (value >= 0);
~~~

Now we could define our table as follows:

~~~sql
create table invoice_lines (
  id serial primary key,
  product_id integer references products(id) not null,
  invoice_id integer references invoices(id) not null,
  quantity positive_integer not null
);
~~~

We can re-use `positive_integer` as a data type for columns in other tables, all sharing the same check.

**Note**: Although it is technically possible to add a `not null` clause in the domain type definition, it does not work in the same way as the column-level `not null` constraint ([see the documentation](https://www.postgresql.org/docs/11/sql-createdomain.html#id-1.9.3.62.7)). It’s therefore best to keep the `not null` in your table definition.

## Exclusion constraints

Finally, my favourite is the [exclusion constraint](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-EXCLUSION) that allows us to ensure that a row does not match any other row in the table using a boolean expression. That sounds a lot like a uniqueness constraint, and in a sense it is — but the great thing about exclusion constraints is they let you provide your own operator. An exclusion constraints look like this:

~~~sql
alter table invoice_lines
add exclude using gist (position WITH =);
~~~

This will ensure a value for `position` is never used twice, as with a unique constraint. But how about using `&&` to check whether two ranges overlap? Assume we have a table containing price information, where prices are valid between two dates:

~~~sql
create table prices (
  id serial primary key,
  product_id integer references products(id) not null,
  price positiver_integer not null,
  validity tstzrange not null,
);
~~~

The `tstzrange` is a range of timestamps. You might insert a row as follows to indicate a price is valid from January 1st 2018 up to but not including December 31st:

~~~sql
insert into prices (product_id, price, validity)
values (1, 1199, '[2018-01-01, 2018-12-31)')
~~~

Of course, given any particular date, there should only ever be a single valid price. Phrased differently, the validity range for a row should never overlap with that of any other row. Here’s how we can write that as an exclusion constraint:

~~~sql
alter table prices
add exclude using gist (validity with &&);
~~~

This will compare the validity range of the current row with every other row in the table using the `&&` operator (see the documentation for more information on [ranges and their operators](https://www.postgresql.org/docs/11/rangetypes.html)). When it finds a true value (i.e. two ranges overlap) the current row will violate this constraint and the operation will fail with an error. PostgreSQL will create the necessary gist index for you automatically.

Of course, this is not perfect: prices for different products should be able to have overlapping validity ranges. Our constraint can include multiple clauses (each with their own operator) to deal with this:

~~~sql
alter table prices
add exclude using gist (
  product_id with =,
  validity with &&
);
~~~

This will test for equality on the product ID and _then_ on overlapping validity ranges.

The nice thing about exclusion constraints is that they provide data-level guarantees. Consider how you would write a check like this in application-level code: it would most likely require two queries for looking for overlaps and then inserting a new row. What happens if many different clients are performing this operation simultaneously? It’s easy to make mistakes and introduce race conditions that will leave your data in an inconsistent state. 

**Note**: in order to combine plain and composite values in an exclusion constraint, you might need to install the [btree_gist](https://www.postgresql.org/docs/11/btree-gist.html) extension using `create extension btree_gist`.

## When not to use constraints

Don’t start ripping out your application-level data validations and replace them with database constraints. Not every validation in your model layer should be a data-level constraint. A user account `password` not being `null` is fine as a constraint at the database level; the rule that passwords should be between 6 and 14 characters long is not. Such a business rule might change, or you might even support different rules at the same time (imagine disallowing passwords under 8 characters for new signups, but not yet forcing existing users to update their old passwords if they’re too short). These are best dealt with at the application level.

Also, constraints are there to tell your application that something went wrong. It’s up to your application to tell the user something is wrong. For example, [Elixir](https://elixir-lang.org)’s [Ecto](https://hexdocs.pm/ecto/Ecto.html) library knows how to gracefully expect constraint violations and translate them into validation errors using [`Ecto.Changeset.check_constraint`](https://hexdocs.pm/ecto/Ecto.Changeset.html#check_constraint/3):

~~~elixir
def changeset(invoice_line, params \\ %{}) do
  invoice_line
  |> cast(params, [:quantity])
  |> validate_required([:quantity])
  |> check_constraint(:positive_integer)
end
~~~

## Conclusion

Adding constraints in your database are a great way to safe-guard your data. They will save you from writing a bunch of application code, they’re most likely way more performant than any code you’ll write, they are safe to use in concurrent environments and they make your data layer easy to use from other applications. Go forth and constrain!
