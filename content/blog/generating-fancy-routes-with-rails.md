---
title: Generating fancy URLs with Rails
kind: article
created_at: 2012-01-13 20:00
tags: [rails, ruby]
tldr: a hacky way to dryly generate fancy resourceful routes
---
There's a problem with Rails resourceful routes. It is very easy to generate standard resourceful routes; it is equally easy to match incoming fancy URLs. But DRYly generating fancy URLs is a lot harder than suspected.
{: .leader }

Matching fancy _incoming_ routes is easy enough:

    get '/posts/:year/:month/:id' => 'posts#show'
{: .ruby }

Our application will now correctly match URLs like `/posts/2011/3/1-hello-world`, but see what happens when we try to generate a polymorphic route:

    link_to(post.title, post)
    # => <a href="/posts/1">hello, world</a>
{: .ruby }

This is _not_ what we want. Of course, we could set `:year` and `:month` parameters manually, but that's not very DRY. We could also try to override the `post_url` and `post_path` methods, but  this does not cover all use cases.

## Hypothetical solution

Ideally, we would like to return a hash of parameters for the `to_param` method:

    class Post
      def to_param
        { year: created_at.year,
          month: created_at.month,
          id: id }
      end
    end
{: .ruby }

Rails would then have to interpolate these params into the generated URL. Alas, this doesn't work.

## Actual, hacky solution

We can hack around it, tough, by overriding `url_for`:

    class ApplicationController
      def url_for(options = {})
        obj = options[:_positional_args][0]
        if obj === Post
          options[:_positional_keys] = [
            obj.year,
            obj.month,
            obj
          ]
        end
        super(options)
      end
      helper_method :url_for
    end
{: .ruby }

This works fine for the most part -- despite being a terrible hack. The `helper_method :url_for` line does, however, override `ActionView`'s normal behaviour of generating only paths instead of full URLs. To get around this, we can create a new helper method that uses the controller method:

    module ApplicationHelper
      def url_for(options = {})
        return super unless options.is_a? Hash
        controller.url_for(
          options.reverse_merge(only_path: true)
        )
      end
    end
{: .ruby }

Now all URLs are properly generated:

    link_to post.title, post
    # => <a href="/2011/2/1-hello,world">Hello, world</a>
{: .ruby }

## A note of warning

The code in these examples is extremely simplified. Being a hack, you need to add some proper checks for argument types and the contents of the `:_positional_args` and `:_positional_keys` options. Also, you can probably not depend on this behaviour remaining on subsequent versions of Rails. But it still just might come in useful some time…

[*DRY]: Don't Repeat Yourself
