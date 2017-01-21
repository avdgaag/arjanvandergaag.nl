---
title: Using Ruby command line options
kind: article
created_at: 2014-03-24 21:00
tldr:
  Ruby comes with some powerful command line options to make shell scripting
  easier.
tags: [ruby, development, refactoring]
---
Not many people know the powerful command line options that Ruby understands.
They really demonstrate how Ruby drew inspiration from Perl and is a great tool
for general-purpose command line scripting.
{: .leader }

I've prepared a short refactoring story to demonstrate how might use some of the
options at our disposal. Ruby can do more than I can show you here with this
example, so be sure to check out its manpage using `man ruby`. Note: I have also
given [a presentation on this subject][slides] at [Eindhoven.rb][].

Let's say we are given the task to update some data files that we need to use on
a project. The data kind of looks like CSV but contains some other stuff as
well. We need to filter out some sales records based on country, which is listed
as one of the fields per row. Here's a sample from the file we are dealing with:

    % wc -l
    1005 data.csv
    % head data.csv
    # Copyright 2014 Acme corp. All rights reserved.
    #
    # Please do not reproduce this file without including this notice.
    # ===============================================================
    Name,Partner,Email,Title,Price,Country
    Nikolas Hamill,Emely Langosh Sr.,nash@moen.info,Awesome Wooden Computer,42261,Puerto Rico
    Friedrich Zboncak MD,Ms. Trycia Sporer,nils@treutelrodriguez.name,Sleek Wooden Hat,35701,Suriname
    Marcus Nicolas,Margot Hoppe,maeve@hilll.info,Rustic Steel Shoes,40258,Argentina
    Toni Ernser I,Guillermo Kihn II,clara.marvin@west.net,Sleek Cotton Pants,68332,Turks and Caicos Islands
    Mayra Kerluke DDS,Marvin Lynch,sydni.schuppe@schuster.com,Incredible Steel Gloves,47017,New Zealand

Of course there are many ways to deal with data like this, including using
[CSV][] from Ruby's standard library. Let's assume we can't use that option and
we need to implement something manually. Here's how such a script might look:

~~~ ruby
#!/usr/bin/env ruby -w
# This tranforms input files that look like CSV and strips comments and
# filters out every line not about "Suriname".

# Define some basic variables that control how records and fields
# are defined.
input_record_separator  = "\n"
field_separator         = ','
output_record_separator = "\n"
output_field_separator  = ';'
filename = ARGV[0]

File.open(filename, 'r+') do |f|

  # Read the entire contents of the file in question
  # in an input array.
  input = f.readlines(input_record_separator)
  output = ''

  # Loop over all the lines in the file with a counter
  input.each_with_index do |last_read_line, i|

    # Remove the ending newline from the line for easier
    # processing.
    last_read_line.chomp!(input_record_separator)

    # Extract all fields in this record.
    fields = last_read_line.split(field_separator)

    # Only proceed for non-comment lines about Suriname
    if fields[5] == 'Suriname' && !(last_read_line =~ /^# /)

      # Write the output lines including the line number
      # and combine fields using our custom separator
      fields.unshift i
      output << fields.join(output_field_separator)
      output << output_record_separator
    end
  end

  # Rewind back to the start of the file and replace all its
  # contents with the content in `output`.
  f.rewind
  f.write output
  f.flush
  f.truncate(f.pos)
end
~~~

This is definitely not some of the best code I have every written, but it gets
the job done. It takes the first command line argument as a file name, reads the
file and then loops over all the lines in it to filter out just what we want.
For the lines we want, it appends a new line to a special output string which
gets written to the same file once all lines have been processed.

I can use the program as follows:

    % chmod +x filter_sales
    % ./filter_sales data.csv

## Using default globals

In order to optimise this program we can first switch to using some built-in
global variables. In order to clarify their names, we require the [english][]
library:

~~~ ruby
#!/usr/bin/env ruby -w
require 'english'
$INPUT_RECORD_SEPARATOR  = "\n"
$FIELD_SEPARATOR         = ','
$OUTPUT_RECORD_SEPARATOR = "\n"
$OUTPUT_FIELD_SEPARATOR  = ';'
filename = ARGV[0]

File.open(filename, 'r+') do |f|
  input = f.readlines(input_record_separator)
  output = ''
  input.each_with_index do |last_read_line, i|
    $LAST_READ_LINE = last_read_line
    $INPUT_LINE_NUMBER = i
    $LAST_READ_LINE.chomp!($INPUT_RECORD_SEPARATOR)
    $F = $LAST_READ_LINE.split($FIELD_SEPARATOR)
    if $F[5] == 'Suriname' && !($LAST_READ_LINE =~ /^# /)
      $F.unshift $INPUT_LINE_NUMBER
      output << $F.join($OUTPUT_FIELD_SEPARATOR)
      output << $OUTPUT_RECORD_SEPARATOR
    end
  end
  f.rewind
  f.write output
  f.flush
  f.truncate(f.pos)
end
~~~

These global variables are used by Ruby itself and are the first step in
shrinking our code.

## Using default values

As these global variables are used by Ruby internally, they mostly ship with
sensible default values. Also they are used as defaults in sensible locations.
We can therefore reduce our code like so:

~~~ ruby
#!/usr/bin/env ruby -w
require 'english'
$FIELD_SEPARATOR         = ','
$OUTPUT_RECORD_SEPARATOR = "\n"
$OUTPUT_FIELD_SEPARATOR  = ';'
filename = ARGV[0]

File.open(filename, 'r+') do |f|
  input = f.readlines
  output = ''
  input.each_with_index do |last_read_line, i|
    $LAST_READ_LINE = last_read_line
    $INPUT_LINE_NUMBER = i
    $LAST_READ_LINE.chomp!
    $F = $LAST_READ_LINE.split
    if $F[5] == 'Suriname' && !($LAST_READ_LINE =~ /^# /)
      $F.unshift $INPUT_LINE_NUMBER
      output << $F.join
      output << $OUTPUT_RECORD_SEPARATOR
    end
  end
  f.rewind
  f.write output
  f.flush
  f.truncate(f.pos)
end
~~~

We have gotten rid of some arguments and the declaration of
`$INPUT_RECORD_SEPARATOR`. We can also use `IO#print`, which will join multiple
arguments together using `$OUTPUT_FIELD_SEPARATOR`. It will also include a
`$OUTPUT_RECORD_SEPARATOR` if it is not `nil`.

~~~ ruby
#!/usr/bin/env ruby -w
require 'english'
$FIELD_SEPARATOR         = ','
$OUTPUT_RECORD_SEPARATOR = "\n"
$OUTPUT_FIELD_SEPARATOR  = ';'
filename = ARGV[0]

File.open(filename, 'r+') do |f|
  input = f.readlines
  f.rewind
  input.each_with_index do |last_read_line, i|
    $LAST_READ_LINE = last_read_line
    $INPUT_LINE_NUMBER = i
    $LAST_READ_LINE.chomp!
    $F = $LAST_READ_LINE.split
    if $F[5] == 'Suriname' && !($LAST_READ_LINE =~ /^# /)
      $F.unshift $INPUT_LINE_NUMBER
      f.print *$F
    end
  end
  f.flush
  f.truncate(f.pos)
end
~~~

This change helped us get rid of the `output` variable. Next, rather than
reading the entire file into a single `input` array, we can read it line by line
using a `while` loop:

~~~ ruby
#!/usr/bin/env ruby -w
require 'english'
$FIELD_SEPARATOR         = ','
$OUTPUT_RECORD_SEPARATOR = "\n"
$OUTPUT_FIELD_SEPARATOR  = ';'
filename = ARGV[0]

File.open(filename, 'r+') do |f|
  while f.gets
    $LAST_READ_LINE.chomp!
    $F = $LAST_READ_LINE.split
    if $F[5] == 'Suriname' && !($LAST_READ_LINE =~ /^# /)
      $F.unshift $INPUT_LINE_NUMBER
      f.print *$F
    end
  end
end
~~~

We can now use `IO#gets` to read a line from our file, and automatically set
`$LAST_READ_LINE` and `$INPUT_LINE_NUMBER`. We have lost our ability to re-write
the entire file though, so we'll need to bring that back somehow. Luckily, we
can.

## Reading and editing files in-place

By using the `-n` and `-i` flags, we can let Ruby read through our file using
`IO#gets` and let `IO#print` write straight back into the file. The `-i`
optionally takes a file extension to create a backup file, but omitting it skips
the backup file altogether. Let's rewrite our program by letting Ruby use these
two flags.

~~~ ruby
#!/usr/bin/env ruby -w -n -i
require 'english'
BEGIN {
  $FIELD_SEPARATOR         = ','
  $OUTPUT_RECORD_SEPARATOR = "\n"
  $OUTPUT_FIELD_SEPARATOR  = ';'
}

$LAST_READ_LINE.chomp!
$F = $LAST_READ_LINE.split
if $F[5] == 'Suriname' && !($LAST_READ_LINE =~ /^# /)
  $F.unshift $INPUT_LINE_NUMBER
  print *$F
end
~~~

The `-n` flag wraps the script in a `while gets ... end` loop. In order to set
our field and record separator variables, we need a `BEGIN { ... }` block that
gets called at the start of the program -- wherever it is defined in the source
code. Our calls to `IO#print` now default to our single open file and the `-i`
flag handles writing our output back into the original file.

Also note there is a `-p` flag that works mostly the same as `-n`, but includes
a `print $_` statement at the end of the loop. It will read and then print every
line in the file, allowing you to either skip lines using `next` or modify the
current line before printing. But for now, we'll stick with `-n`.

## Configuring variables using command-line options

We can use more command line switches to set some values in our program:

~~~ ruby
#!/usr/bin/env ruby -w -n -i -F, -l
require 'english'
BEGIN {
  $OUTPUT_FIELD_SEPARATOR  = ';'
}

$F = $LAST_READ_LINE.split
if $F[5] == 'Suriname' && !($LAST_READ_LINE =~ /^# /)
  $F.unshift $INPUT_LINE_NUMBER
  print *$F
end
~~~

Using the `-F` flag we can specify the value for `$INPUT_FIELD_SEPARATOR`, and
with `-l` we can tell Ruby to assign the value of `$INPUT_RECORD_SEPARATOR` to
`$OUTPUT_FIELD_SEPARATOR` _and_ remove `$INPUT_FIELD_SEPARATOR` from the
`$LAST_READ_LINE` using `String#chomp!`. That means the input records separator
is removed when reading lines (which is what we want) and added when writing
lines (which is also what we want). Removing newlines from the input line helps
prevent _double_ newlines in output lines.

Now, let's use Ruby's auto-splitting feature using `-a`:

~~~ ruby
#!/usr/bin/env ruby -w -n -i -F, -l -a
require 'english'
BEGIN {
  $OUTPUT_FIELD_SEPARATOR  = ';'
}

if $F[5] == 'Suriname' && !($LAST_READ_LINE =~ /^# /)
  $F.unshift $INPUT_LINE_NUMBER
  print *$F
end
~~~

With `-a` Ruby will automatically split the current line into `$F` on every
iteration. Now we are getting somewhere.

## Compare against current line

Ruby provides us with one more special shortcut we can use once the `-n` (or
`-p`) flag is used: in conditionals, regular expressions implicitly match
against the value of `$LAST_READ_LINE` and ranges of numbers against the value
of `$INPUT_LINE_NUMBER`. With this knowledge we can simplify our conditional:

~~~ ruby
#!/usr/bin/env ruby -w -n -i -F, -l -a
require 'english'
BEGIN {
  $OUTPUT_FIELD_SEPARATOR  = ';'
}

unless $F[5] != 'Suriname' || /^# /
  $F.unshift $INPUT_LINE_NUMBER
  print *$F
end
~~~

## Shortening the code

Now we've got all the parts in place we can shorten our code a bit by making our
conditional a one-liner and removing the `english` library and switch to the
abbreviated Perl-y global variable names:

~~~ ruby
#!/usr/bin/env ruby -w -n -i -F, -l -a
BEGIN { $, = ';' }
print $., *$F unless $F[5] != 'Suriname' || /^# /
~~~

## Conclusion

So, yes, we've basically built a half-assed implementation of Awk in Ruby. If
you know Awk ([and you should!][awk]) you might as well use that. But chances
are you know Ruby better. Once you get comfortable with these command line
flags, Ruby becomes a very nice tool in your sysadmin toolbelt. You might write
a simple script like this straight on the command line like so:

    ruby -wlani -F, -e "BEGIN { $, = ';' }" -e "print $., *$F unless $F[5] != 'Suriname' || /^# /"

...or you might use some fancier tools, such as quickly parsing some YAML:

    ruby -r yaml -e 'puts YAML.load(ARGF)["database"]' config/database.yml

Sometimes, the methods Awk or Sed give you are best suited for what you need to
do. But sometimes you need something more, or you just don't care to look up how
to perform certain operations you _know_ how to do in Ruby in some other
language. You should always use the right tool for the job, and given Ruby's
flexibility I think it may surprise you how often that tool is Ruby.

[slides]:       https://speakerdeck.com/avdgaag/getting-started-with-ruby
[Eindhoven.rb]: http://eindhovenrb.nl
[CSV]:          http://ruby-doc.org/stdlib-2.1.1/libdoc/csv/rdoc/index.html
[english]:      http://ruby-doc.org/stdlib-2.1.1/libdoc/English/rdoc/index.html
[awk]:          http://arjanvandergaag.nl/blog/programming-awk-for-fun-and-profit.html
