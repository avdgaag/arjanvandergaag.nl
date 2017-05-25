---
title: "Writing a lexer and parser"
kind: article
created_at: 2017-05-23 12:00
tags:
  - Elixir
  - Erlang
  - yecc
  - leex
  - JSON
---
I like regular expressions as much as the next guy, but sometimes plain old regular expressions just won't cut it. Sometimes we need a little more. Luckily for us, Elixir comes with built-in support for leex and yecc. Let's see how we can use those to write our own parser.
{: .leader }

## About lexing and parsing

We need two steps to transform a string of source code into a meaningful data structure that our program can work with:

1. A [lexer][] transforms a big list of meaningless characters (our input string) into a list of distinct tokens, such as numbers, keywords and symbols.
2. A [parser][] transforms a list of tokens into a data structure according to rules describing how to combine tokens.

We can write lexers and parsers by hand, but in the Elixir/Erlang world, the [leex][] and [yecc][] projects can help us. They take special DSL files and compile them into [Erlang][] modules for us, that we then use in our applications. [Elixir][] comes fully equipped to work with leex and yecc out of the box.

[lexer]: https://en.wikipedia.org/wiki/Lexical_analysis
[parser]: https://en.wikipedia.org/wiki/Parsing
[leex]: http://erlang.org/doc/man/leex.html
[yecc]: http://erlang.org/doc/man/yecc.html
[Erlang]: http://www.erlang.org
[Elixir]: https://elixir-lang.org

## The example project

We'll build a small Elixir project to parse JSON documents. You can find the end result on github at [avdgaag/example_json_parser][repo]. First, generate a new Elixir project:

[repo]: https://github.com/avdgaag/example_json_parser

~~~
% mix new json_parser
% cd json_parser
~~~

We'll write our lexer and parser code in `./src`, so create that directory:

~~~
% mkdir src
~~~

Mix will automatically spot and compile the files we'll create in `./src`, so we're ready to go.

## The lexer

### Overview

We'll start with our lexer. We write our lexer in `src/json_lexer.xrl` as a series of regular expressions to recognise tokens. Each regular expression will be paired with some Erlang code to generate a value that our parses will later deal with. Here's a simple lexer file to recognise the keywords in our input:

~~~
Definitions.

Rules.

null|true|false : {token, {list_to_atom(TokenChars), TokenLine}}.

Erlang code.
~~~

Our lexer has three sections:

1. in the _definitions_ section we can define variables for re-uses or complex regular expressions, that we can use in our _rules_ section;
2. the _rules_ section pairs regular expressions matched against the input source with Erlang code to generate an output value;
3. in the _Erlang code_ section we can define helper functions, also to simplify the code in the rules section.

We have one _rule_ that uses the regular expression `null|true|false` to identify all the keywords we are currently interested in. It is followed by the Erlang code to return:

* `{token, _}` will tell the parser we've found a token. Later on, we'll see other return values.
* `TokenChars` and `TokenLine` are Erlang variables that leex make available to us. They contain the matched characters and the line in the  input string, respectively.
* `list_to_atom` is a regular Erlang function that converts a charlist (`TokenChars`) to an atom.
* The `{list_to_atom(TokenChars), TokenLine}` contains the information about the token that our parser needs: what we found and where we found it.

**Note**: this is Erlang code, not Elixir: atoms are written as `token`, not `:token`; variables are written as `TokenChars`, not `token_chars`. Also, each rule ends with a `.`.
{: .note }

### Trying it out

Let's try it out. When we compile our Elixir project, Mix will compile our lexer into an Erlang module called `json_lexer`. We can use it like so:

~~~
# lib/json_parser.ex
defmodule JsonParser do
  def parse(str) do
    case :json_lexer.string(to_charlist(str)) do
      {:ok, tokens, _} ->
        tokens
      {:error, reason, _} ->
        reason
    end
  end
end
~~~
{: .language-elixir }

The `string` function is defined for us by leex. Since this is Erlang, we need to feed it a charlist rather than a binary, so we use `to_charlist`. Start an iex session:

~~~
% iex -S mix
~~~

We can play with our lexer:

~~~
iex> JsonParser.parse("null")
[null: 1]
iex> JsonParser.parse("true")
[true: 1]
iex> JsonParser.parse("false")
[false: 1]
iex> JsonParser.parse(~s({ "key": "value" }))
{1, :json_lexer, {:illegal, '{'}}
~~~
{: .language-elixir }

Note that iex will display `[{true, 1}]` as the keyword list `[true: 1]`.

Anything other than one of our three keywords returns an error. This makes sense: we haven't written lexing rules for all content in our input. Let's fix that.

### Recognising symbols

In order for us to process a JSON object, we need to deal with curly braces. We'll also need to deal with commas, colon and square brackets. Let's all capture those using a single regular expression:

~~~
Definitions.

Rules.

null|true|false : {token, {list_to_atom(TokenChars), TokenLine}}.
[{}\[\]:,] : {token, {list_to_atom(TokenChars), TokenLine}}.

Erlang code.
~~~


Let's try it again:

~~~
iex> JsonParser.parse(~s({ "key": "value" }))
{1, :json_lexer, {:illegal, ' '}}
~~~
{: .language-elixir }

Now, we get a different error: our lexer encounters whitespace.

### Ignoring whitespace

We are not actually interested in whitespace, but it is significant to the lexer. Therefore, we'll define a rule to ignore whitespace altogether using the special `skip_token` return value:

~~~
Definitions.

Rules.

null|true|false : {token, {list_to_atom(TokenChars), TokenLine}}.
[{}\[\]:,] : {token, {list_to_atom(TokenChars), TokenLine}}.
[\s\t\r\n]+ : skip_token.

Erlang code.
~~~

This might also be a good time to simplify our rules using some definitions:

~~~
Definitions.

KEYWORDS=null|true|false
SYMBOLS=[{}\[\]:,]
WHITESPACE=[\s\t\r\n]+

Rules.

{KEYWORDS} : {token, {list_to_atom(TokenChars), TokenLine}}.
{SYMBOLS} : {token, {list_to_atom(TokenChars), TokenLine}}.
{WHITESPACE} : skip_token.

Erlang code.
~~~

Note that our variables have to be all uppercase.

### Recognising strings

Running our code again now has our lexer trip over the `"` of our first string:

~~~
iex> JsonParser.parse(~s({ "key": "value" }))
{1, :json_lexer, {:illegal, '"'}}
~~~
{: .language-elixir }

We've got our first real challenge on our hands. Let's recognise strings:

~~~
Definitions.

KEYWORDS=null|true|false
SYMBOLS=[{}\[\]:,]
WHITESPACE=[\s\t\r\n]+
STRING="[^\"]+"

Rules.

{STRING}     : {token, {string, TokenLine, TokenChars}}.
{KEYWORDS}   : {token, {list_to_atom(TokenChars), TokenLine}}.
{SYMBOLS}    : {token, {list_to_atom(TokenChars), TokenLine}}.
{WHITESPACE} : skip_token.

Erlang code.
~~~

Our new rule matches two double quotes and everything in between. In the accompanying Erlang code, we return a token again -- but this time with a three-element tuple as contents. This tuple tells our parser what _category_ of thing we found (a `string`), where we found it (`TokenLine`) and the actual content of what we found (`TokenChars`). We need the distinction between category and contents because there are many different strings. The keyword `null` is always exactly he same, so there is no need to distinguish between category and content there.

### Adding some Erlang code

Let's try it out:

~~~
iex> JsonParser.parse(~s("test"))
[{:string, 1, '"test"'}]
~~~
{: .language-elixir }

Interestingly, it gives us a charlist of the entire string  -- including the quotes. Let's get rid of those using a little Erlang:

~~~
Definitions.

KEYWORDS=null|true|false
SYMBOLS=[{}\[\]:,]
WHITESPACE=[\s\t\r\n]+
STRING="[^\"]+"

Rules.

{STRING}     : {token, {string, TokenLine, extract_string(TokenChars)}}.
{KEYWORDS}   : {token, {list_to_atom(TokenChars), TokenLine}}.
{SYMBOLS}    : {token, {list_to_atom(TokenChars), TokenLine}}.
{WHITESPACE} : skip_token.

Erlang code.

extract_string(Chars) ->
    list_to_binary(lists:sublist(Chars, 2, length(Chars) - 2)).
~~~

Give it another try:

~~~
iex> JsonParser.parse(~s("test"))
{:string, 1, "test"}
~~~
{: .language-elixir }

And with that, we've got our lexer to lex our input source! For completeness sake, let's also add support for numbers:

~~~
Definitions.

KEYWORDS=null|true|false
SYMBOLS=[{}\[\]:,]
WHITESPACE=[\s\t\r\n]+
STRING="[^\"]+"
NUM=[0-9]+

Rules.

{STRING}     : {token, {string, TokenLine, extract_string(TokenChars)}}.
{KEYWORDS}   : {token, {list_to_atom(TokenChars), TokenLine}}.
{SYMBOLS}    : {token, {list_to_atom(TokenChars), TokenLine}}.
{NUM}\.{NUM} : {token, {float, TokenLine, list_to_float(TokenChars)}}.
{NUM}        : {token, {int, TokenLine, list_to_integer(TokenChars)}}.
{WHITESPACE} : skip_token.

Erlang code.

extract_string(Chars) ->
    list_to_binary(lists:sublist(Chars, 2, length(Chars) - 2)).
~~~

Now we're ready to recognise basically anything a JSON document can throw at us -- but not any combination of these tokens is a valid JSON document. It's time for the next step.


## The parser

### Overview

With our lexer ready, we now need a parser. We write our parser in `src/json_parser.yrl`, which will make an Erlang module `json_parser` available to our Elixir code after compilation. We can feed the tokens from our lexer to our parser:

~~~
# lib/json_parser.ex
defmodule JsonParser do
  def parse(str) do
    with {:ok, tokens, _} <- :json_lexer.string(to_char_list(str)),
         {:ok, result} <- :json_parser.parse(tokens)
    do
      result
    else
      {:error, reason, _} ->
        reason
      {:error, {_, :json_parser, reason}} ->
        to_string(reason)
    end
  end
end
~~~
{: .language-elixir }

Our parser will define a set of rules describing how to combine different tokens into an output value. These tokens can come straight out of our lexer, or be the result of other rules. This is best explained using an example:

~~~
Terminals '{' '}' '[' ']' ':' ',' null true false string int float.
Nonterminals value.
Rootsymbol value.

value ->
    null : nil.
value ->
    true : true.
value ->
    false : false.
value ->
    string : '$1'.
value ->
    int : '$1'.
value ->
    float : '$1'.

Erlang code.
~~~

The parser definition also has three sections:

1. first, it lists all the tokens we might encounter. The tokens we'll encounter from our lexer are listed as `Terminals`, since they cannot be broken down any further. Special symbols are quoted. Under `Nonterminals`, it lists tokens we define ourselves as combinations of other tokens. Finally, it names the `Rootsymbol` where our parsing should start.
2. then we list our rules in the format `left -> right : code`. Under left we describe the non-terminal token we're parsing, under right we describe what other tokens it consists of, and finally the code defines the return value of the rule, and, ultimately, of our parser.
3. Just as with our lexer, `Erlang code` can hold function definitions to use in our rules' code.

### Parser rules

A rule looks like this:

~~~
value ->
    null : nil.
~~~

This says that we can parse a JSON value when we see the `null` token. When we do, we'll return the Erlang value `nil`. By defining multiple rules for the same non-terminal, we can define alternatives. So, we can _also_ parse a JSON value when we see the `true` token:

~~~
value ->
    null : nil.
value ->
    true : true.
~~~

When we do, we return the `true` atom.

### Reading token contents

The string case is special:

~~~
value ->
    string : '$1'
~~~

The `$1` is a special parser variable referring to the _contents_ of the first token in our right-hand side, i.e. `string`.

Running our parser now would give us something we do not want. It would output something like this:

~~~
iex> JsonParser.parse(~s("test"))
{:string, 1, "test"}
~~~
{: .language-elixir }

The `$1` in our parser gave us the contents of the token, which we defined in our lexer using either a two or three-element tuple. But we're only interested in the third element of that content tuple. Let's use some Erlang code to extract it:

~~~
value ->
    string : extract_value('$1').

Erlang code.

extract_value({_, _, Value}) ->
    Value.
~~~

This will give us what we want:

~~~
iex> JsonParser.parse(~s("test"))
"test"
~~~
{: .language-elixir }

### Parsing lists of tokens

Now to a more involved job: parsing arrays. Let's give it a try:

~~~
iex> JsonParser.parse("1")
1
iex> JsonParser.parse("[1,2,3]")
"syntax error before: '['"
~~~
{: .language-elixir }

This gives us an error. Let's define a new non-terminal to deal with arrays:

~~~
value ->
    array : '$1'.
array ->
    '[' array_elements ']' : '$2'.
array ->
    '[' ']' : [].
~~~

This is simple enough: an array is defined by whatever is between the two square brackets, _or_, when there is nothing between them, it is just an empty list.

Let's define the `array_elements`:

~~~
array_elements ->
    value ',' array_elements : ['$1' | '$3'].
array_elements ->
    value : ['$1'].
~~~

This is a recurring (pun intended!) pattern in writing parsers using yecc: we let our rule _recurse_ to parse lists of tokens. Our `array_elements` should be either a value followed by a comma and more `array_elements`, or it is just a single value. Using this recursion, we build an entire output array of values -- and since we have already defined `value` to be anything, this should work. Add our new non-terminals to the list at the top of the file and give it a try:

~~~
iex> JsonParser.parse("[1,2,3]")
[1,2,3]
iex> JsonParser.parse("[true, false, null]")
[true, false, nil]
~~~
{: .language-elixir }

### Parsing objects

We can parse objects in much the same way. Rather than square brackets we'll use curly braces, and instead of a single value each "element" will actually be a key/value-pair:

~~~
value ->
    object : '$1'.
object ->
    '{' key_value_pairs '}' : '$2'.
object ->
    '{' '}' : [].
key_value_pairs ->
    key_value_pair ',' key_value_pairs : ['$1' | '$3'].
key_value_pairs ->
    key_value_pair : ['$1'].
key_value_pair ->
    string ':' value : {binary_to_atom(extract_value('$1'), utf8), '$3'}.
~~~

Note that we build the output value for an object as a list of two-element tuples (a keyword list), since in Erlang land we cannot use Elixir's Map module.

Let's see it work:

~~~
iex> JsonParser.parse("{}")
[]
iex> JsonParser.parse(~s({"name": "John"}))
[name: "John"]
~~~
{: .language-elixir }

### The end result

This our final result of our parser for JSON documents:

~~~
Terminals '{' '}' '[' ']' ':' ',' null true false string int float.
Nonterminals value array array_elements object key_value_pairs key_value_pair.
Rootsymbol value.

value ->
    null : nil.
value ->
    true : true.
value ->
    false : false.
value ->
    string : extract_value('$1').
value ->
    int : extract_value('$1').
value ->
    float : extract_value('$1').
value ->
    array : '$1'.
value ->
    object : '$1'.
array ->
    '[' array_elements ']' : '$2'.
array ->
    '[' ']' : [].
array_elements ->
    value ',' array_elements : ['$1' | '$3'].
array_elements ->
    value : ['$1'].
object ->
    '{' key_value_pairs '}' : '$2'.
object ->
    '{' '}' : [].
key_value_pairs ->
    key_value_pair ',' key_value_pairs : ['$1' | '$3'].
key_value_pairs ->
    key_value_pair : ['$1'].
key_value_pair ->
    string ':' value : {binary_to_atom(extract_value('$1'), utf8), '$3'}.

Erlang code.

extract_value({_, _, Value}) ->
    Value.
~~~

You can see the entire end result at Github at [avdgaag/example_json_parser][repo].

## Conclusion

Writing lexers and parsers isn't all that hard, once you know the basics of how they work and you understand the recursing rules pattern. Naturally, parsing any valid Elixir or Ruby code is a lot more involved than parsing JSON. But sometimes everyday projects call for parsing user input or configuratin files; once you know the basics of leex and yecc, they become valuable additions to your toolbox. Have fun writing your own parsers!
