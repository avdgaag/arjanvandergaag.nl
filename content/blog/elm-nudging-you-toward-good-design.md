---
title: "Elm: nudging you toward good design"
kind: article
created_at: 2016-05-30 12:00
tags:
    - programming
    - elm
---
Elm is a functional programming language that compiles to javascript. I have found it to be a great and fun way to write HTML apps, despite it requiring some up front work to “please the compiler”.
{: .leader }

## The best of functional programming in your browser

[Elm][] promises to deliver fast, virtual DOM-based HTML apps with no runtime exceptions. The Elm compiler is pretty great at finding errors in your code, and explaining to you what’s wrong. Elm has immutable data structures, static typing, some pretty great tooling and (last but not least) it looks nice.

Here’s a simple Elm “hello, world!” application:

~~~
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)

greeting : String -> Html msg
greeting name =
  let
    greeting = "Hello, " ++ name
  in
    div [ class "elm-greeting" ]
        [ text greeting ]

main : Html msg
main =
  greeting "John"
~~~
{: .language-haskell }

You can see the results of this application by pasting the code in [Elm’s online editor][try].

## Why you should use Elm

If you’re building HTML apps, you should consider using Elm for a couple of reasons:

1. It’s a decent, well-designed language with a standard library. That alone gives it one up over Javascript.
2. Its static typing and smart compiler make runtime errors a thing of the past. Also, the compiler is famously [helpful in pointing out your errors][compilers-as-assistants].
3. Functional programming languages with immutable data structures are a joy to work with in general, and Elm is no exception. It’s even got side effects as first-class citizens!
4. Its tools and editor support (including [code formatter][], [time-travelling debugger][] and [SemVer][]-aware [package manager][]) work well and are all part of the package — no need for elaborate tutorials in how to set it all up.
5. Its syntax is nice, even if it takes some getting used to the significant whitespace and the lack of parentheses and semicolons. Once you get used to the restructuring, pattern matching, auto-currying and pipeline and composition operators, you’ll find it hard to go back.

### The Elm Architecture

What I like most about Elm is how it guides you towards well-architected code using the [Elm Architecture][]: a conventional way of structuring Elm applications using…

* a uni-directional flow of events,
* a single global data model,
* a virtual DOM implementation for speedy page updates,
* and infinitely testable components for modular code.

The [Elm guide][] does a pretty good job explaining the Elm architecture. Meanwhile, you can see the architecture in action in the [TodoMVC example application][todomvc].

## The not-so good parts

Of course, Elm is not without it’s warts: being a pure functional javascript language, side effects (such as telling the browser to focus on an input element on the page) can be cumbersome to achieve. Javascript interop is supported, but, due to the strongly typed nature of Elm, not as transparent as in, say, Coffee Script. That’s not necessarily bad, it just requires some more consideration to do it well.

### Pleasing the compiler with robust code

This is also an example of a wider pattern with static typing and compilers: it is not so much “pleasing the compiler”, as “writing robust code”. For example, here’s how to convert a string to a number:

~~~
> String.toInt "123"
Ok 123 : Result.Result String Int
> String.toInt "abc"
Err "could not convert string 'abc' to an Int" : Result.Result String Int
~~~

The return value of `String.toInt` is not a number, but a `Result`, which can be `Ok Int` or `Err String` (see [docs][result]). In human terms, `String.toInt` either:

* succeeds with a number, or…
* fails with an error message.

You cannot parse strings into numbers without explicitly dealing with both possible outcomes. In much the same way, Elm knows no `null` or `nil`, but it does know `Maybe` (see [docs][maybe]).

### A great complement to Elixir

Elm uses types to “tag” values with extra information. [Elixir][] does something similar, where it uses pattern matching on tuples:

~~~
case File.read("example.txt") do
  {:ok, contents} -> # do something with contents here
  {:error, msg} -> # present error msg to user
end
~~~
{: .language-elixir }

However, Elixir’s compiler won’t _force_ you to deal with all possible scenario’s. Regardless, Elixir (together with [Phoenix][]) [works great with Elm][phoenix-elm].

## A nice package

Of course, nothing about all this is particularly new. Elm did not invent static typing, but a compiler that helps us avoid `undefined is not a function` is welcome improvement over plain old javascript. Elm did not invent functional programming with immutable data structures, but that programming model is quite well suited for building user interfaces. In Elm, some things take a little more effort up front, but you’ll end up with better, more robust software for it.

If you’re looking to write single-page web applications, definitely give Elm a try: it gives you a great collection of tools nudging you into the right direction.

[Elixir]: http://elixir-lang.org
[Phoenix]: http://phoenixframework.org
[phoenix-elm]: https://www.youtube.com/watch?v=XJ9ckqCMiKk
[try]: http://elm-lang.org/try
[compilers-as-assistants]: http://elm-lang.org/blog/compilers-as-assistants
[code formatter]: https://github.com/avh4/elm-format
[time-travelling debugger]: http://elm-lang.org/blog/time-travel-made-easy
[SemVer]: http://semver.org
[package manager]: https://github.com/elm-lang/elm-package
[Elm Architecture]: http://guide.elm-lang.org/architecture/index.html
[Elm guide]: http://guide.elm-lang.org
[todomvc]: https://github.com/evancz/elm-todomvc
[result]: http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Result#Result
[maybe]: http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Maybe#Maybe
[Elm]: http://elm-lang.org
