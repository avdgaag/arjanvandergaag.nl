---
title: Wrestling JSON with jq
created_at: 2015-01-20 12:00
kind: article
tags:
  - shell
  - programming
  - json
  - unix
---
When you deal with JSON-based APIs a lot, a Unix-y tool to filter and transform
JSON streams can be a valuable tool. Jq is such a tool, and you would do well to
learn its basic usage.
{: .leader }

[Jq][jq] is a command-line tool to tranform JSON streams into other JSON
streams. You can use it in a Unix pipeline to collect information from one set
of JSON and output another set for further processing. This post will explain
what that means using an example.

## Example: collect all Bitbucket repo URLs

Let's try collecting all the URLs for Git repositories you have hosted on
[Bitbucket][]. The [Bitbucket JSON API][api] gives us information about our
repositories, but no simple way to get just the URLs we need. Rather than
whipping up some Ruby to parse the JSON we get back, let's use [jq][].

### 1. Fetching our JSON document from the API

Bitbucket's API can be used with cURL as follows:

    % curl --silent https://api.bitbucket.org/2.0/repositories/avdgaag

The response will be a JSON document with information on all my public
repositories.[^1] In this example our response will have on repository. The
output cURL spits out looks like this:

    {"pagelen": 10, "values": [{"scm": "git", "has_wiki": false, "description":
    "...", "links": {"watchers": {"href": "..."}, "commits": {"href": "..."},
    "self": {"href": "..."}, "html": {"href": "..."}, "avatar": {"href": "..."},
    "forks": {"href": "..."}, "clone": [{"href": "...", "name": "https"},
    {"href": "...", "name": "ssh"}], "pullrequests": {"href": "..."}},
    "fork_policy": "no_forks", "name": "...", "language": "", "created_on":
    "...", "full_name": "...", "has_issues": false, "owner": {"username": "...",
    "display_name": "...", "uuid": "...", "links": {"self": {"href": "..."},
    "html": {"href": "..."}, "avatar": {"href": "..."}}}, "updated_on": "...",
    "size": 2328936, "is_private": true, "uuid": "..."}], "page": 1, "size": 1}

A nice, unreadable blob of JSON content! So, what if we have fifty repositories
and want to get the clone URLs (the SSH-variant) for each of them?

### 2. Filtering the JSON with jq

Assume we have piped the cURL output into a file called response. We have also
installed jq on our system, for example using [Homebrew][] on Mac OS X (see full
[jq installation instructions][download]). We can simply format and print the
JSON using `jq '.'`:

    % jq '.' response
    {
      "pagelen": 10,
      "page": 1,
      "size": 1,
      "values": [
        {
          "scm": "git",
          "has_wiki": false,
          "description": "...",
          "links": {
            "watchers": { "href": "..." },
            "commits": { "href": "..." },
            "self": { "href": "..." },
            "html": { "href": "..." },
            "avatar": {"href": "..."},
            "forks": {"href": "..."},
            "clone": [
              {"href": "...", "name": "https"},
              {"href": "...", "name": "ssh"}
            ],
            "pullrequests": {"href": "..."}
          },
          "fork_policy": "no_forks",
          "name": "...",
          "language": "",
          "created_on": "...",
          "full_name": "...",
          "has_issues": false,
          "owner": {
            "username": "...",
            "display_name": "...",
            "uuid": "...",
            "links": {
              "self": {"href": "..."},
              "html": {"href": "..."},
              "avatar": {"href": "..."}
            }
          },
          "updated_on": "...",
          "size": 2328936,
          "is_private": true,
          "uuid": "..."}
       ]
     }

Of course, we could also have piped our cURL output straight into jq:

    % curl ... | jq '.'

Either way, our JSON gets pretty-printed. Now we can start building our query.

### 3. Querying simple values

First, let's zoom in on the top-level `values` attribute:

    % jq '.values' response
    [
      {
        "scm": "git",
        "has_wiki": false,
        ...
      }
    ]

Our JSON stream is now the value for the `values` attribute, which is an array
of objects. To collect a particular attribute path for each entry in this array,
we can expand our query as follows:

    % jq '.values[].links.clone' response
    [
      {
        "href": "..."
        "name": "https"
      },
      {
        "href": "...",
        "name": "ssh"
      }
    ]

As you can see, we can construct paths through our JSON document by joining
nested keys with a `.`, like `.values.links.clone`. Our `values` attribute
happens to hold an array, and we want to collect the rest of the path for each
of the objects in the array: `.values[].links.clone`. We could also have fetched
just the clone links for the first repository using an index with
`.values[0].links.clone`.

### 4. Unwrapping the array into multiple objects

We now have an array of objects, but we don't really want an "array" as a single
value; we're interested in all the array values. So we pull the same trick as
before and add some brackets to "unwrap" the array:

    % jq '.values[].links.clone[]' response
    {
      "href": "..."
      "name": "https"
    }
    {
      "href": "...",
      "name": "ssh"
    }

That gives us a "stream" of objects. Nice!

### 5. Filtering our stream with a condition

Here comes the tricky bit. Now we got an array of objects with `href` and `name`
attributes, we want to collect the `href`s where `name` equals `ssh`. Jq has a
[nice `select` function][select] to do that:

    % jq '.values[].links.clone[] | select(.name == "ssh")' response
    {
      "href": "...",
      "name": "ssh"
    }

Using the `|` we can pass one stream of objects (namely all `clone` objects) to
a new expression. In this case that's the `select` function which makes sure our
output only contains the objects that match its subexpression.

Now we can use _another_ pipe to filter our new stream and get just the values
we're interested in:

    % jq '.values[].links.clone[] | select(.name == "ssh") | .href' response
    "ssh://bitbucket.org/..."

### 6. Outputting raw values

We've got our selection down to the right values. Too bad, though, that the
values are formatted as JSON --- including string quotes. When we want to
further process this list of values using other programs, we probbly prefer raw
values over formatted strings. Luckily, jq has a command-line flag to do just
that:

    % jq --raw-values \
      '.values[].links.clone[] | select(.name == "ssh") | .href' \
      response
    ssh://bitbucket.org/...

**Note** you can abbreviate `--raw-values` to `-r`.

Hurrah! We've used jq to quickly pull some values out of a complex JSON document
without having to resort to opening our editor, writing Ruby or Python, figuring
out how to use their HTTP libraries exactly, and then parsing and printing the
response.

Jq's syntax takes a little getting used to, but it's got [decent
documentation][docs] and a wealth of functions and constructs to use. Most of
this stuff you are not going to keep in your head, but I have found the patterns
in this post (collecting key paths and conditional filtering) to be simple
enough to use without having to resort to the manpages.

Do refer to the [jq documentation][docs] for more information and enjoy your
new-found JSON-wrestling superpowers!

[docs]:      http://stedolan.github.io/jq/manual/
[jq]:        http://stedolan.github.io/jq/
[Bitbucket]: https://bitbucket.org/
[api]:       https://confluence.atlassian.com/display/BITBUCKET/Use%2Bthe%2BBitbucket%2BREST%2BAPIs
[download]:  http://stedolan.github.io/jq/download/
[Homebrew]:  http://brew.sh/
[select]:    http://stedolan.github.io/jq/manual#selectboolean_expression

[^1]: To also include private repositories, include a `--user USERNAME:PASSWORD` option.
