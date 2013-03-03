---
title: Working with Postgresql on the command line
kind: article
created_at: 2013-03-02 14:00
tags: [unix, development, postgresql, shell]
tldr:
  The psql program is so powerful you no longer need
  GUI tools to work with your database.
---
Unlike MySQL, PostgreSQL doesn't have lots of nice-looking GUI tools available
to it. But don't let that hold you back, because its command-line client packs a
lot of power that you'll quickly come to love, once you get to know it.
{: .leader }

## Editing your queries

You can use the `psql` program to interactively send queries to your database.
Although there are steps you can take to make editing in the interactive shell
easier[^1], nothing beats your regular editor.

To create a new SQL file in your editor and quickly send it to your database,
you can use the `--file` (or `-f`) option. Assuming you use Vim, here are two
example key mappings:

    map <leader>r :w !psql -d mydb -1 -f -<cr>

This allows you to use `\r` in normal mode to execute the entire file, or in
visual mode to execute only the current selection. Note the use of the `-1`
option (short for `--single-transaction`) to wrap your queries in a transaction,
as if you had used `BEGIN`/`COMMIT`, and the `-` argument to `-f` to tell `psql`
to read from standard input.

Alternatively, you can start your editor _from_ the `psql` prompt using the
`\edit` (or `\e`) metacommand. This will launch `$EDITOR` to edit a temporary
file containing the last query you ran. When you quit the editor, `psql` will
run the contents of that file as the next query.

Finally, you can use PostgreSQL variables and interpolation to make writing
queries a little easier. For example:

    psql> \set t my_long_table_name
    psql> select count(*) from :t;

Note how `psql` will interpolate `:t` with `my_long_table_name`. You might use
this to read a blob of data from a file, and insert it into a row:

    psql> \set content `cat my_big_textfile`
    psql> INSERT INTO posts VALUES (:'content');

The quotes in the placeholder name will escape the variable contents as an SQL literal.

## Inspecting tables

The main reason I used to prefer GUIs to work with databases is how easy they
make it explore the database schema. `psql` provides a handy family of
metacommands to explore objects in the database, all starting with `\d`.[^3] You
can list all tables in  your current schema using just `\d`. Specify an
additional name and `psql` will tell you all about that named object. For
example, use `\d comments` to list column information of the `comments` table:

    psql> \d comments
                                          Table "public.comments"
         Column                 Type                                   Modifiers                       
    ---------------- --------------------------- -----------------------------------------------------
    id               integer                     not null default nextval('comments_id_seq'::regclass)
    body             text                        not null
    commentable_id   integer                     not null
    commentable_type character varying(255)      not null
    user_id          integer                     not null
    created_at       timestamp without time zone not null
    updated_at       timestamp without time zone not null
    Indexes:
        "comments_pkey" PRIMARY KEY, btree (id)
        "index_comments_on_commentable_id_and_commentable_type" btree (commentable_id, commentable_type)
        "index_comments_on_user_id" btree (user_id)

To zoom in on the `comments_id_seq` sequence, use `\d comments_id_seq`:

        Sequence "public.comments_id_seq"
       Column      Type          Value        
    ------------- ------- -------------------
    sequence_name name    comments_id_seq
    last_value    bigint  375
    start_value   bigint  1
    increment_by  bigint  1
    max_value     bigint  9223372036854775807
    min_value     bigint  1
    cache_value   bigint  1
    log_cnt       bigint  21
    is_cycled     boolean f
    is_called     boolean t
    Owned by: public.comments.id

I've found these commands tell me all I need to know about my database, without
the need to take my hands off the keyboard.

## Working with results

When querying your data, `psql` might give you a lot of data — way more than a
single terminal's screen full. There are several ways to make working with such
data a little easier.

### Customize the pager

`psql` will page through the query results using `$PAGER`, usually defaulting to
`more`.[^2] If you prefer `less` (and why wouldn't you?), you can set the
`$PAGER` environment variable or use `\setenv PAGER less` at the prompt.

### Customize the presentation

`psql` will draw pretty borders between your query columns. You can turn them
off using `\pset border 0`, or add even more borders with `\pset border 2`. It's
also nice to use pretty unicode characters to draw those borders by setting
`\pset linestyle unicode`. Finally, use wrapped mode to wrap content in columns
with `\pset format wrapped` to prevent your columns from running wider than your
screen.

When there's so much content and wrapped mode won't cut it anymore, switch to
vertical mode using `\x`. This will display a single column per row, making many
columns or long text values much easier to read.

### Inspect data in external programs

Sometimes you just want to open your results in your editor or a spreadsheet for
further analysis. Use `\o data` in the interactive shell (or the command line
argument `--output data`) to redirect all output to the file `./data`. Note that
`data` might also be a script that accepts query results on standard input.

**Tip**: for some quick and dirty CSV generation, issue `\f ','` to set the
field separator to `,`, `\a` to switch to unaligned output mode and `\t` to
show tuples but no headers or footers. Or, from your shell: `psql -d mydb
-t -A -F,`.

## Other tweaks and tips

One nice customisation to make is tweaking the `psql` command prompt. Mine looks
like this:

    arjan@mydb
    =# SELECT count(*) FROM posts;

The prompt is defined by the special `PROMPT1`, `PROMPT2` and `PROMPT3`
variables. You'll usually see `PROMPT1`; `PROMPT2` is used when entering queries
across multiple lines. Some of the special substitutions you can use are:

`%n`
: The current user name

`%/`
: The current database

`%#`
: `>` for regular users, `#` for database superusers.

`%R`
: Expected input indicator, hinting when you have unbalanced quotes or missed a
  semicolon.

`%x`
: Current transaction status: nothing when there's no transaction, `*` if there
  is, `!` if the transaction has failed.

### Store preferences in .psqlrc

If you tweak your `psql` preferences it would be nice not to have to reapply
them in every session. Store your customisations in `~/.psqlrc` to issue them at
the start of every session. [My .psqlrc file][psqlrc] looks like this:

    \set PROMPT1 '%n@%/\n%R%x%# '
    \set PROMPT2 '%R%x%# '
    \pset border 1
    \pset format wrapped
    \pset linestyle unicode
    \pset null NULL

You can then keep that file under source control, along with all your other
dotfiles.

### Running single commands

When you are really in a hurry, or are trying to practice some shell-scripting
magic, you can use the `--command` (or `-c`) option to `psql` to run a one-off
command:

    $ psql -d mydb -c 'select count(*) from users;' -A -t
    58

### Using connection strings

If you have ever wanted to connect to a remote Heroku postgres database, you
know how easy it is to get the connection details from Heroku:

    $ heroku config:get DATABASE_URL -a myapp
    postgres://username@password:very-long-hostname:5432/database

Try converting that to the appropriate command-line options to `psql` to do some
manual prodding around. But, turns out, `psql` will accept such a connection URI
just fine:

    $ psql `heroku config:get DATABASE_URL -a myapp`

In this particular example, you might as well run `heroku pg:psql` as that does
essentially the same thing. But it's good to know that you _can_ do this, if you
want to.

## Conclusion

Using the `psql` program is much easier than it may seem. Its a good Unix
citizen and it is very simple to integrate into your regular editor. This
interoperability also makes it easy to customise your workflow even further with
scripts and aliases -- for example, to automatically connect to the database
described in `./config/database.yml` if you're in a Rails project, or to
automatically download and import data dumps from remote production databases.
Such scripts are left as an exercise to the reader.

[^1]: For example, if you are a Vim user, try adding "set editing-mode vi" to `~/.inputrc` to enable Vim key bindings in most interactive shells, including `psql`.

[^2]: The exact program used differs per operating system, but on Mac OS X it seems to default to `more`.

[^3]: There's a whole range of `\d` metacommands, so read the `psql` man pages for more information.

[psqlrc]: https://raw.github.com/avdgaag/dotfiles/master/home/.psqlrc
