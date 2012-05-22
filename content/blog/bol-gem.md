---
title: A Ruby gem for the bol.com developer API
kind: article
created_at: 2012-02-02 13:30
tldr: I released a Ruby gem for the Bol.com API
tags: [ruby, rubygems, bol.com]
---
It has bugged me for a long time that I could not access product information
from [bol.com][] the same way I could from Amazon.com. When bol.com released
their public API some time ago, I _still_ couldn't. Not easily. So I wrote a
Ruby library for [the Bol.com API][api].
{: .leader }

The bol.com API allows you to fetch detailed information for common products,
such as books, DVDs and toys, search for products by keyword, or list
bestsellers. The API is not too complex: it's just a handful of endpoints, a
couple of available query parameters and a request signature. 

I built a wrapper around this API that exposes the available operations and
handles the difficult parts of request signing and XML parsing. All you, as the
developer, have to do is provide the access credentials. All operations give
you nice, clean Ruby objects back, such as a `Bol::Product`.

## Getting started

You need to [sign up for a developer account][signup] first. When your account
has been approved, you can request an API key. The key has two parts -- one
public, one secret -- that will be used by bol.com to make sure you really are
who you say you are when you make a request.

Once you have both your access key and its secret, you can get started by
installing the Ruby gem:

    $ gem install bol

## An example application

Let's create a very simple Sinatra application to search the bol.com store (see
[the completed app in one file][0]). Create an application file `app.rb`:

    require 'sinatra'

    get '/' do
      erb :search
    end
{: lang="ruby" }

Add a simple form view:

    <form method="post" action="/search">
      <label>Query: <input type="text" name="q"></label>
      <input type="submit">
    </form>
{: lang="html" }

Run the app to confirm everything works:

    $ ruby -rubygems app.rb

When you browse to `http://localhost:2567` you can see the search page, but it
doesn't do anything yet. Let's add a search action:

    post '/search' do
      @products = []
      erb :results
    end
{: lang="ruby" }

And a view to display results:

    <ol>
    <% @products.each do |product| %>
      <li><%= product.title %></li>
    <% end %>
    </ol>
{: .rhtml }

## Implementing search

We've added a `/search` route that will somehow set an array of products, and
then render them to an ordered list on the page. Simple enough. Now to actually
search some products:

    post '/search' do
      @products = Bol.search params[:q]      
      erb :results
    end
{: lang="ruby" }

Searching the bol.com website is as easy as `Bol.search(params[:q])`. Restart
the app, and try it out. You will get an error, complaining that the gem is not
properly configured. We need to provide our access key and its secret, so they
can be used to sign our requests:

    Bol.configure do |c|
      c.access_key = '123256789'
      c.secret     = 'abcdefghi'
    end
{: lang="ruby" }

When you restart the application, you should be able to search bol.com by
keyword and get a list of titles back. 

## Showing product details

Let's go one step further and add some product details. We'll create a new
route for that:

    get '/product/:id' do
      @product = Bol::Product.find params[:id]
      erb :product
    end
{: lang="ruby" }

We can use `Product#find` to find a particular product on bol.com by its
internal ID. We'll create a link to the detail page in our search results:

    <ol>
    <% @products.each do |product| %>
      <li>
        <a href="/product/<%= product.id %>">
          <%= product.title %>
        </a>
      </li>
    <% end %>
    </ol>
{: .rhtml }

We also need a view for our new action:

    <h1><%= @product.title %></h1>
    <dl>
      <% @product.attributes.each_pair do |k, v| %>
      <dt><%= k %></dt>
      <dd><pre><%= v %></pre></dd>
      <% end %>
    </dl>
{: .rhtml }

Restart the app, perform a search and click on a result. You should see all
available product details. Note that there are several sizes of cover image
available, and that the `author` attribute is an `Array` -- there can be more
than one, after all.

## Scoping search results to categories

Now we want to limit our search results to a particular category of products.
Bol.com products are extensively categorized and we can look up those
categories and search in them. Let's add a drop-down list of categories to
search to our search form:

    get '/' do
      @categories = Bol.categories
      erb :search
    end

    post '/search' do
      @products = Bol::Scope.new(params[:category_id])
        .search params[:q]      
      erb :results
    end
{: lang="ruby" }

And in the view:

    <form method="post" action="/search">
      <select name="category_id">
        <% @categories.each do |category| %>
        <option value="<%= category.id %>">
          <%= category.name %> (<%= category.count %>)
        </option>
        <% end %>
      </select>
      <input type="text" name="q">
      <input type="submit">
    </form>
{: .rhtml }

Once we've reloaded the application, we can choose a category to search in and
get results limited to that category. Categories are nested, so you can get
subcategories using `Bol::Scope.new(some_id).categories`. And there are also
_refinements_, such as groupings by price or brand and other attributes, but
they work similarly to categories.

## Referral links

Then only referral links remain. It is a good idea to link to
products on bol.com, so you can get a kickback on any sales
resulting from the traffic you send over. This is not strictly a
feature of the developer API, but it is so commonly used, I just
threw it in here. You can simply ask a product for its referral
URL, given a specific referral ID:

    product = Bol.find(params[:id])
    product.referral_link('my-site-id')
    # => "http://..."
{: lang="ruby" }

## Other features

This example application showcases the basics of the bol gem, but it includes
some more:

* Ordering and limiting of number of results
* Automatic pagination
* Joining and subtracting categories and refinements to create complex scopes
* List popular or bestselling products

See the project [README][1] file for more information.

## Example application and source code

That's all you need to know to get started. You can see the entire [example
application][0] in [this gist][0]. You can find [the source for this Ruby gem
on Github][1], where I also keep the API documentation and track issues. The
gem is still in beta stage, so it can be field-tested before getting an actual
stamp-of-approval by releasing a version 1.0. Try it out and do let me know if
you make anything awesome with it!

[0]:       https://gist.github.com/1722664
[1]:       https://github.com/avdgaag/bol
[bol.com]: http://bol.com
[api]:     http://developers.bol.com
[signup]:  https://developers.bol.com/inloggen/?action=register
