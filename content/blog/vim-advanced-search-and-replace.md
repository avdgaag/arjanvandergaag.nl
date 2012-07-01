---
title: Vim advanced search and replace
kind: article
created_at: 2012-07-01 12:00
tags: [vim, development, ruby]
---
When I get a few days off from work, I do what every self-respecting geek would
do: I dive into my text editor and try to learn some new stuff. Here's a few
    tricks I learned recently concerning search and replace in Vim.
{: .leader }

## 1. Indenting a multi-line search match

Say you have a Markdown document with code blocks marked up in Github-style
'fences':

    Here is a code example:

    ```ruby
    puts "Hello, world"
    ```

You want to convert these code blocks to standard Markdown code blocks -- which
have no fences, but instead are indented four spaces. This is desired end
result:

    Here is a code example:

        puts "Hello, world"

The example includes only a single code block with a single line of code, but
let's assume there's several multi-line code blocks. How to go about this
problem?

My first attempt was to use a regular expression search to match the entire
code block, and then find some way to perform the indent command on its
matches. The regular expression is not too hard, once you know the relevant Vim
regular expression syntax:

    /\v^```ruby\_.{-1,}```$/

Note the `\v` for [very magic syntax][magic], `\_.` to [match any
character][anychar] (including newlines) and `{-1,}` to [non-greedily
match][nongreedy] at least one of `\_.`.

This search matches all the fenced code blocks alright, so we need a way to
operate on every match. Here the [global command][global] (`g`) comes into
play. Here's my first attempt to indent every match:

    :g/\v```ruby\_.{-1,}```$/>

The global command allows you to operate on every line matching a pattern, in
this case using the `>` command to indent lines. Alas, only the first line of
the match would indent, giving me:

    Here is a code example:

        ```ruby
    puts "Hello, world"
    ```

My misunderstanding was that a multi-line search would match multiple lines --
instead, a search in Vim is found on _a single line_ (which makes sense when
you think about it).

After some Googling for search operations, I found the global command sets the
current line in vim to the line of the search match. From there, you can start
a new range up to the closing fence and operate on that range with the indent
command. Here's how:

    :g/^```ruby/.,/```$/>

So, to recap: <code>g/^```ruby/</code> searches for our opening fence and sets
Vim's _current line_ to that line. The rest of the command is the operation on
that line. <code>.,/```$/</code> is a [range][]. We might express ranges with
line numbers (i.e. `10,20`), but we can also use special symbols and searches.
In this case, `.` is the current line (the one with the opening fence), and we
end our range on the first match from our current line that matches our closing
line. Finally, we can operate on a range using any ex command[^1], in this case
`>` to indent. Success!

## 2. Solve your problems with external tools

It later occured to me the above problem might just as well have been solved
using Ruby. Here's an example solution:

    :%!ruby -pe "gsub /^/, '    ' if /^```ruby/../```$/"

We use `%!` to filter the entire file through the `ruby` program. The `-p` flag
to Ruby tells it to loop over `STDIN` and print every line back to `STDOUT`.
The `-e` flag to Ruby evaluates a string of Ruby code. Since `-p` put Ruby in
the special command-line mode, `gsub` and and regular expressions are
implicitly sent to the current line. The above string of Ruby code is
equivalent to the following program:

    while $_ = STDIN.gets
      if $_ =~ /^```ruby/../```$/
        $_.gsub! /^/, '    '
      end
      print $_
    end
{: lang="ruby" }

Finally, the regular expression range syntax (also known as the [flip-flop
operator][flipflop]) is one of those awesome Ruby tricks few people know:
looping over several lines, it becomes true when the left-hand regex matches,
and stays true on subsequent tests until the right-hand side regex matches.

Is the Ruby alternative more readable than the Vim one? You decide for yourself
-- just know there's more than one way to skin a cat.

## 3. Adding an incrementing counter to search matches

A while back I had an HTML document with sixteen headers I wanted to prefix
with an incrementing number. I wanted to turn this:

    <h3>Heading 1</h3>
    <p>Lorem ipsum</p>
    <h3>Heading 2</h3>
    <p>Lorem ipsum</p>
{: lang="html" }

…into this:

    <h3>1. Heading 1</h3>
    <p>Lorem ipsum</p>
    <h3>2. Heading 2</h3>
    <p>Lorem ipsum</p>
{: lang="html" }

I accomplished it with Vim's search-and-replace capabilities and a little
vimscript, taking advantage of `\=`, which allows us to [use an expression in
the substitue string][expr].

The first step to solving this problem is matching the right characters for
replacement. In this case, we want to insert our counter right after the
opening heading tag. We can match that exact position like so:

    /\v\<h3\>\zs/

We have to escape the `<` and `>` because in Vim's regular expression syntax
they represent [left en right word boundaries][boundaries]. `\zs` is Vim's
[positive look-behind][plb] syntax, causing Vim to look for our opening heading
tag, but only starting our match _after_ it.

Using vimscript to increment a counter is not too hard, either. We could do it
like so:

    let i=1
    " insert i in the document somehow
    let i=i+1

My first try to combine these was to just use a regular substitue command,
combining it with the vimscript lines for the counter:

    :let i=1 | %s/\v\<h3\>\zs/\=i/ | let i=i+1

You can use `|` to combine multiple statements into a single command. `\=i`
will use the current value of `i` as the the substituion string. But here's the
end result:

    <h3>1Heading 1</h3>
    <p>Lorem ipsum</p>
    <h3>1Heading 2</h3>
    <p>Lorem ipsum</p>
{: lang="html" }

Vim has inserted the same value of `i` on every match. Here's why: `%s` is a
_single_ operation on a range (`%`) that includes the entire document. If only
we could make a single replacement for every line that matched our search… The
global command to the rescue, again:

    :let i=1 | g/\v\<h3\>\zs/s//\=i/ | let i=i+1

I replaced the `%` range with a global command using the same search pattern.
To not repeat myself, I removed the search pattern from the substitution
command, causing vim to re-use to last used pattern -- which in this case is
the pattern from the global command. Miraculously, it works:

    <h3>1Heading 1</h3>
    <p>Lorem ipsum</p>
    <h3>2Heading 2</h3>
    <p>Lorem ipsum</p>
{: lang="html" }

We just need to add a little extra text to the substitution string:

    :let i=1 | g/\v\<h3\>\zs/s//\=i.". "/ | let i=i+1

As you can see, we can concatenate the string `". "` to our counter using the
`.` operator, giving us the end result:

    <h3>1. Heading 1</h3>
    <p>Lorem ipsum</p>
    <h3>2. Heading 2</h3>
    <p>Lorem ipsum</p>
{: lang="html" }

Another great success!

## 4. Editing complex commands

Admittedly, we have created quite a monster command using vimscript, a global
command, a substition command, the special expression register and positive
look-behinds. But Vim is a developer's editor, and developers (should) know
this stuff. It is not the most readable of code, but it is not horrible either.

The only truly awkward aspect of typing complex commands like these is entering
them on Vim's command line. There's a remedy for that, though: the [command
line window][clw].

The command line window is a new window (a split screen) in the current tab,
that contains a buffer with your entire command history, one command per line.
You can move around and edit commands just like in any buffer, making it easy
to make changes. But when you press `Enter` in normal mode, it will execute the
current line as if you had typed it on Vim's command line, against the
previously active window.

The command line window is a great help in iteratively building up complex
commands. It allows you to quickly revisit previously issued commands, make
some changes, and execute it again. When done, you can simply close it again
using `:q`. But Vim wouldn't be Vim if it hadn't some awkardness, and this time
it's the `q:` shortcut to open it. It just way too similar to `:q`, and I open
the command-line window by accident _all the time_.

[magic]: http://vimdoc.sourceforge.net/htmldoc/pattern.html#/magic
[anychar]: http://vimdoc.sourceforge.net/htmldoc/pattern.html#/\_.
[nongreedy]: http://vimdoc.sourceforge.net/htmldoc/pattern.html#/\{-
[global]: http://vimdoc.sourceforge.net/htmldoc/repeat.html#:g
[range]: http://vimdoc.sourceforge.net/htmldoc/cmdline.html#:range
[flipflop]: http://www.ruby-doc.org/docs/ProgrammingRuby/html/tut_expressions.html#S6
[boundaries]: http://vimdoc.sourceforge.net/htmldoc/pattern.html#/\<
[plb]: http://vimdoc.sourceforge.net/htmldoc/pattern.html#/\zs
[expr]: http://vimdoc.sourceforge.net/htmldoc/change.html#:s\=
[clw]: http://vimdoc.sourceforge.net/htmldoc/cmdline.html#command-line-window

[^1]: For a full list of available ex commands, search the Vim help system using: `:help holy-grail`.
