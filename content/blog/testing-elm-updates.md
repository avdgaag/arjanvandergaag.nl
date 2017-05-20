---
title: "Testing Elm updates"
kind: article
created_at: 2017-02-21 12:00
tags:
    - programming
    - elm
    - testing
---
If your [Elm][] program compiles, it probably works. When writing Elm programs, I tend to write a lot fewer unit tests than I usually would. But you can (and should) still write tests. Here’s how I test my update functions.
{: .leader }

## Unit testing Elm code

The Elm community has built the [elm-test][] package for writing unit tests with Elm. Along with [node-test-runner][] you’ve got a pretty neat TDD setup going. To run your tests and watch for file changes, run:

    % elm test --watch

After you’ve set up elm-test, this is what an example test file would look like:

~~~ haskell
module MyTest exposing (all)

import Expect
import Test exposing (..)

all : Test
all =
describe "My Elm app"
    [ test "test the truth" <|
        \_ ->
            Expect.equal True True
    ]
~~~

Admittedly, elm-test’s syntax is not the prettiest I’ve ever seen, but that’s nothing some editor snippets and [elm-format][] won’t solve for you.

## About pure functions and side effects

Elm functions are pure. Their outputs are determined by their inputs and they have no side effects. One of the most important parts of any Elm program is the `update` function. This function takes a message and the current state of the application, and returns the new state and, optionally, a description of any side effects you want to trigger.

Note that your update function does not have side effects in itself — you can only let it return _a description of the desired effects you want the Elm runtime to implement for you_. These side effects are called _commands_ in Elm, and despite their name, they’re still just data.

## Example update function

Here’s a simple `update` function for a To Do list application:

~~~ haskell
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)
        CompleteTask id ->
            ({ model
                | tasks = List.map (checkById id) model.tasks
            }, Cmd.none)
~~~

Assume, for now, that a function exists with the signature `checkById : Int -> Task -> Task`. It will take a `Task` and it will compare its ID to the given ID and decide to mark that task as completed or not.

How can we test this update function?

## Setting up a test skeleton

The easiest way to get started is by writing the simplest test possible. In this case, that’s the scenario where we trigger a `NoOp` message in our application. It should do nothing.

### Testing the model

Let’s set up a simple test file that tests the right model value is returned:

~~~ haskell
module UpdateTest exposing (all)

import Expect
import MyApp exposing(..)
import Test exposing (..)

model : Model
model =
    { tasks = [] }

all : Test
all =
    describe "update"
        [ describe "NoOp"
            [ test "does not alter the state" <|
                \_ ->
                    model
                        |> update NoOp
                        |> Tuple.first
                        |> Expect.equal model
            ]
        ]
~~~

In this test I have set up a nested test group for the `NoOp` message, and it has a single test: it should not change the state. I’ve used the pipeline-style of composing the test. In case you’re not familiar, this is equivalent to writing:

~~~ haskell
Expect.equal model (Tuple.first (update NoOp model))
~~~

This test should pass, so we can specify the second part of this function: the non-existent side-effects.

### Testing the commands

The fact that commands are merely _descriptions of desired side effects_ makes it real easy to test for them:

~~~ haskell
test "it has no side effects" <|
    \_ ->
        model
            |> update NoOp
            |> Tuple.second
            |> Expect.equal Cmd.none
~~~

That was easy: the second element in the two-tuple return value should be a _null command_. Now we have set up this pattern, we can write a test that is actually interesting.

## Testing completing a task

To test our `CompleteTask` message, we need to test for four things:

1. it marks a message as completed when a existing ID is used;
2. it does nothing when a non-existent ID is used;
3. it does nothing when a task with the given ID does exist, but is already completed;
3. it has no side effects.

The last test is essentially the same as in the first example, so I will not repeat it here.

### Testing the happy path

Let’s write a test for the first scenario. I’ll first make sure there is a task in our example model, and then verify that using its ID in the `CompleteTask` message will change its completion flag. Note that the “task” will not actually _change_, as Elm has immutable data types; by _change_ I mean the output model will contain a `Task` record that is equal to the original record _except for_ the completion flag.

First, update our example model to include a `Task` to update. Luckily, this won’t affect our `NoOp` test:

~~~ haskell
model : Model
model =
    { tasks = [{ id = 1, title = "Buy milk", completed = False }]
    }
~~~

This is enough to test marking a `Task` as completed:

~~~ haskell
test "marks found task as completed" <|
    \_ ->
        model
            |> update CompleteTask 1
            |> Tuple.first
            |> Expect.equal
                [ { id = 1
                  , title = "Buy milk"
                  , completed = True
                  }
                ]
~~~

At this point, you could choose to refactor your example data a little by extracting the `Task` value into a separate function, but I’ll leave that as an exercise to the reader.


### Testing the alternative paths

Let’s test the path where the ID does not exist:

~~~ haskell
test "ignores IDs of tasks that do not exist" <|
    \_ ->
        model
            |> update CompleteTask 99
            |> Tuple.first
            |> Expect.equal model
~~~

This test was actually a lot simpler: the output model is simply the same as the input model.

Finally, we can test that tasks that are already completed will not be changed (i.e. this is not a “toggle” function):

~~~ haskell
test "does not alter already completed tasks" <|
    \_ ->
        let
            completedOnce =
                model
                    |> update (CompleteTask 1)
                    |> Tuple.first
        in
           completedOnce
               |> update (CompleteTask 1)
               |> Tuple.first
               |> Expect.equal completedOnce
~~~

I could have added another `Task` to the example model, or updated the model in the test itself; but instead I chose to apply the `CompleteTask` message twice and verify it results in the same output. To me, this makes sense: marking a single task as completed twice gives you the same completed task as completing it only once would. Decide for yourself what style you prefer!

## The value of testing commands

Testing side effects is a little more involved: while simple side effects such as generating a Random number or determining the current date/time are simple enough, testing if your update function triggers the correct HTTP request, for example, means you have to duplicate such a request in your test — along with its payload, custom headers, and so forth. This is not impossible, but hardly as valuable as an integration test that has your Elm front-end code talk to an actual back-end server.   When writing tests for your `update` function, **keep asking yourself if you are testing at the right level of abstraction**.

## The value tests add to the compiler

A non-trivial Elm application will deal with a lot of different messages. Writing tests for all of them can be quite a bit of work. But let us remember [what Kent Beck said about testing software][beck]:

> I get paid for code that works, not for tests, so my philosophy is to test as little as possible to reach a given level of confidence (…). If I don't typically make a kind of mistake (like setting the wrong variables in a constructor), I don't test for it.

It is all about reaching some level of confidence about your code. With Elm, you should write tests that help you trust your own code. In practice that means that I would probably not actually write a test for passing the `NoOp` message to my `update` function. Also, the compiler saves me from having to write tests for nonexistent messages, not covering some of different types of `Msg`, or using strange input types. That saves us a lot of work. Regardless, the update function is the core of our application, so it deserves at least _some_ tests. I hope to have demonstrated that adding those tests is actually quite easy to do!

[elm-test]: http://package.elm-lang.org/packages/elm-community/elm-test/latest
[node-test-runner]: https://github.com/rtfeldman/node-test-runner
[elm-format]: https://github.com/avh4/elm-format
[beck]: http://stackoverflow.com/questions/153234/how-deep-are-your-unit-tests/153565#153565
[Elm]: http://elm-lang.org
