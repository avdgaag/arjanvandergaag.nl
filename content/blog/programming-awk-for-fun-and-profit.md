---
title:      Programming Awk for fun and profit
kind:       article
created_at: 2013-01-05 14:00
tldr:       Learn yourself some Awk to quickly manipulate text.
tags:       [unix, awk]
---
I recently came to learn and love Awk, a "pattern-directed scanning and
processing language". If you find yourself working with text on a command line
often, you owe it to yourself to learn some Awk.
{: .leader }

Awk is valuable to learn, because in many cases it can replace complex Unix
pipelines consisting of `sed`, `grep`, `cut`, `wc` and `tr`. It offers a
concise language for text processing that makes it easier to use than Perl or
Ruby. And above all, Awk is so small, it is easy to learn.

## The components of an Awk program

### Records and fields

The Awk programming language revolves around records and fields. Awk's purpose
is to parse input into records, parse records into fields, operate on those
records to generate output records and fields.

In true Unix fashion, by default a record consists of a single line, with
fields separated by whitespace. Naturally, you can customize delimiters using
the special variables `RS` and `FS` for _Record Separator_ and _Field
Separator_ and their output-specific companions `ORS` and `OFS`.

Note that `FS` is actually a regular expression, so you can tell Awk to split
on various punctuation characters at once using a value like `[| ,()]`.

### Rules

An Awk program always loops over all the records from its input to execute
rules. A _rule_ consists of a _pattern_ and an _action_:

    pattern { action }

A rule's action is executed when its pattern matches the current record. The
default pattern matches any record; the default action is to print the current
record.

Multiple rules in a single program are separated by newlines or semicolons.

### Patterns

Patterns can match record by regular expression, by range or by boolean
expression. Here are a few examples:

By regular expression: `/foo/`
: Matches when the entire record contains "foo" somewhere.

By boolean expression: `$2 ~ /foo/`
: Matches when the second field matches the regular expression `foo`.

By boolean expression: `NR % 2`
: Matches all uneven records (lines), because `NR` is a special variable
containing the current record number and `0` is falsy.

By range: `/foo/, /bar/`
: Using the comma notation, this matches every record from the first to contain
`foo` up to and including the next that contains `bar`.

`BEGIN` and `END`
: run a block of code before or after looping over all the input.

### Actions

While the default action of printing the current action already makes Awk an
interesting alternative to grep, custom actions make Awk truly powerful.

Actions can contain entire programs using loops, variables, functions and
conditionals – but in the end they usually come down to printing information to
the output stream.

For example, you can print columns from the input record using the special `$`
function:[^1]

    { print $2, $1 }

This program prints the first two columns of every record in reverse order. To
have a little more control over output formatting, you can use the familiar
`printf` function:

    { printf "%6s: $%.2f", $1, $2 }

This will print the first input column as six characters wide, right-aligned
string; and the second as monetary value. 

[^1]: Since `$` is a function, you could use expressions to retrieve a dynamic
      column number, i.e. `n = NR % 2; print $n`.

### Advanced Awk programming

Awk is a surprisingly complete programming language. Consider the following
example program:

    BEGIN { max = 0 }
    { if($1 > max) max = $1 }
    END { print max }

This simple program demonstrates the use of variables and conditionals to find
the biggest value in the first column.

Consider the following example:

    { categories[$2]++ }
    END {
      for(key in categories) {
        print key, categories[key]
      }
    }

This program builds a histogram of the second column, outputting each unique
value found in the second column of its input, following by how many times that
value was found. Note the use of an [associative array][3] and the `for(key in
array)` loop.

Finally, Awk allows you to use a set of [built-in functions][1] and even
[define your own][2].

[1]: http://www.math.utah.edu/docs/info/gawk_13.html
[2]: http://www.math.utah.edu/docs/info/gawk_14.html
[3]: http://www.math.utah.edu/docs/info/gawk_12.html

## Running Awk programs

The simplest way to use Awk is on the command line, for example to print known
usernames:

    $ awk -F: '{ print $1 }' /etc/passwd

Awk will read its first non-option argument as the program to run, and any
other arguments as files to read. Awk will gladly accept multiple files as one
big input stream. Of course, it will also work fine in a Unix pipeline.

When your programs get too large to comfortably write at a command prompt, you
could put it in a file and tell Awk to run it:

    $ awk -f my_program.awk /etc/passwd

Alternatively, as Awk also functions as an interpreter, you can write your Awk
programs in an executable file. In a file called `usernames.awk`:

    #!/usr/bin/awk -f
    BEGIN { FS = ":" }
    { print $1 }

Make the file executable with `chmod +x usernames.awk` and invoke it with
`./usernames.awk /etc/passwd`.

## Conclusion

Search around the web and you'll find dozens of pages with Awk one-liners to do
all sorts of crazy text manipulation stuff. They're a good resource to pick up
new ideas from, but the power of Awk lies not in building libraries of text
processing functions, but rather in the ability to quickly whip up custom
scripts to handle unique circumstances. Master Awk and be creative!
