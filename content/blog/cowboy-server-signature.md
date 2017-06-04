---
title: Dropping the Cowboy server signature in a Phoenix app
kind: article
created_at: 2017-06-04 12:00
tldr: You can drop the Cowboy server signature header through the Phoenix Endpoint configuration.
tags:
  - elixir
  - programming
  - phoenix
---
It is a good practice to not tell the world too much about what software your are using. When writing Elixir web applications with Phoenix, you are probably using Cowboy -- which by default will include the `Server` response header. Let's remove it.
{: .leader }

As [it turns out][question], [Cowboy][] (at least the current version) supports hooks to customize its responses. As per the [Cowboy documentation for hooks][hooks]:

> The onresponse hook is called right before sending the response to the socket. It can be used for the purposes of logging responses, or for modifying the response headers or body. The best example is providing custom error pages.

It says we need to provide a callback function (this is an Erlang example) when we start Cowboy:

~~~
cowboy:start_http(my_http_listener, 100,
    [{port, 8080}],
    [
        {env, [{dispatch, Dispatch}]},
        {onresponse, fun ?MODULE:custom_404_hook/4}
    ]
).
~~~
{: .language-erlang }

But when we generate a fresh [Elixir][] project with [Phoenix][], our production configuration looks like this:

~~~
config :example_phoenix, MyApp.Web.Endpoint,
  on_init: {MyApp.Web.Endpoint, :load_from_system_env, []},
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"
~~~
{: .language-elixir}

There's no obvious key for our callback function. To launch Cowboy with our own options, we need to go down a little rabbit hole:

* We never launch Cowboy ourselves; it is actually run though Plug's `Plug.Adapters.Cowboy`.
* We can configure Plug through `Plug.Adapters.Cowboy.child_spec/4`, which accepts a `:protocol_options` option which are passed through to Cowboy (see the [Plug documentation][plugdocs]).
* We never call `Plug.Adapters.Cowboy.child_spec/4` ourselves, but Phoenix sets it up for us in `Phoenix.Endpoint.CowboyHandler`.
* We never call `Phoenix.Endpoint.CowboyHandler.child_spec/3` ourselves, but as per the docs, [we can configure it][phoenixdocs] using the `:http` and `:https` options for our app's `Endpoint` module.

So, to configure Cowboy to use a callback function, we configure Phoenix like so:

~~~
config :example_phoenix, MyApp.Web.Endpoint,
  on_init: {MyApp.Web.Endpoint, :load_from_system_env, []},
  http: [protocol_options: [onresponse: &MyApp.Web.Endpoint.on_response/4]],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"
~~~
{: .language-elixir}

Then we can implement `MyApp.Web.Endpoint.on_response/4`:

~~~
defmodule MyApp.Web.Endpoint do
  def on_response(status, headers, body, request) do
  end
end
~~~
{: .language-elixir}

The [Cowboy documentation says][cowboydocs] we should use `cowboy_req:send_reply` to send a response to the client:

~~~
defmodule MyApp.Web.Endpoint do
  def on_response(status, headers, body, request) do
    {:ok, req2} = :cowboy_req.send_reply(status, headers, body, request)
    req2
  end
end
~~~
{: .language-elixir}

And that works... mostly. It [turns out that there is a bug in Cowboy that causes errors when you try this approach when serving static files from disk][bug]. The `body` argument will not yet bet filled (it will be read from disk later) and trying to set a body here will fail, causing the server the drop the connection. Ouch.

Luckily, there's a workaround using an undocumented valid return value:

~~~
defmodule MyApp.Web.Endpoint do
  def on_response(status, headers, body, request) do
    {status, headers, request}
  end
end
~~~
{: .language-elixir }

This seems to always work. Nice!

Now we've got our callback function in place, let's customize the headers. The `headers` arguments looks like this:

~~~
[{"server", "Cowboy"}, ...]
~~~
{: .language-elixir }

That's almost a keyword list, but not quite -- Cowboy uses binaries rather than atoms as the first element of the key/value-tuple. We cannot use Elixir's `Keyword.drop/2` or related functions. Instead, let's use `List.keydelete/3`:

~~~
defmodule MyApp.Web.Endpoint do
  def on_response(status, headers, body, request) do
    {status, List.keydelete(headers, "server", 0), request}
  end
end
~~~
{: .language-elixir }

And with that, we've successfully dropped the `Server` response headers from our Cowboy responses!

[plugdocs]: https://hexdocs.pm/plug/Plug.Adapters.Cowboy.html
[phoenixdocs]: https://hexdocs.pm/phoenix/Phoenix.Endpoint.CowboyHandler.html
[hooks]: https://ninenines.eu/docs/en/cowboy/1.0/guide/hooks#onresponse
[Cowboy]: https://ninenines.eu
[bug]: https://github.com/ninenines/cowboy/issues/738
[question]: https://stackoverflow.com/questions/22591552/erlang-cowboy-change-server-signature-in-http-headers#22592001
[cowboydocs]: https://ninenines.eu/docs/en/cowboy/1.0/guide/resp/#reply
[Elixir]: https://elixir-lang.org
[Phoenix]: http://www.phoenixframework.org
