---
title: Up and running with Lotus
kind: article
tags:
  - ruby
  - lotus
created_at: 2015-03-17 21:00
---
Up and coming Ruby web framework Lotus just hit 0.3.0. I've enjoyed playing with
it over the last couple of weeks, and thought I'd write up what I've learned
about its basic concepts.
{: .leader }

## Introduction

[Lotus][lotusrb] was originally created by [Luca Guidi][]. It's composed of
sub-frameworks that are quite loosely coupled, such as [router][lotus-router],
[controller][lotus-controller], [view][lotus-view] and [model][lotus-model]
libraries. Documentation is set to receive more attention in the future, so
diving into Lotus takes some reading of code at this point. Even though it is
clear, well-structured code, but this post will help you through the basics.

**Note**: I will try to keep this article and the example repository up to date,
but do consider this is written against version 0.3.0 of Lotus.

**Update**: Luca Guidi was kind enough to provide feedback on the first version
of this article; I have updated it accordingly.

## The example application

I've put up a very (_very_) simple application on Github at
[avdgaag/lotus-demo][repo] that I will refer to throughout. You can use it to
follow along.

For starters, Lotus comes with a nice generator for setting up new applications,
much like Rails does:

    % gem install lotusrb
    % lotus new demo --database postgresql --lotus-head

Use Lotus HEAD to get the latest and greatest. Lotus gives us these files:

    demo/.lotusrc
    demo/Gemfile
    demo/config.ru
    demo/config/environment.rb
    demo/config/.env
    demo/config/.env.development
    demo/config/.env.test
    demo/lib/demo.rb
    demo/lib/config/mapping.rb
    demo/Rakefile
    demo/spec/spec_helper.rb
    demo/spec/features_helper.rb
    demo/db/.gitkeep
    demo/lib/demo/entities/.gitkeep
    demo/lib/demo/repositories/.gitkeep
    demo/spec/demo/entities/.gitkeep
    demo/spec/demo/repositories/.gitkeep
    demo/spec/support/.gitkeep
    demo/.gitignore
    demo/apps/web/application.rb
    demo/apps/web/config/routes.rb
    demo/apps/web/config/mapping.rb
    demo/apps/web/controllers/home/index.rb
    demo/apps/web/views/application_layout.rb
    demo/apps/web/templates/application.html.erb
    demo/apps/web/views/home/index.rb
    demo/apps/web/templates/home/index.html.erb
    demo/apps/web/public/javascripts/.gitkeep
    demo/apps/web/public/stylesheets/.gitkeep
    demo/spec/web/features/.gitkeep
    demo/spec/web/controllers/.gitkeep
    demo/spec/web/views/.gitkeep

We've got a mostly familiar layout here, with `lib`, `spec`, `config` and `db`
directories that will hold no surprises. There's also some noticeable differences
compared to a Rails application.

### Important features

* A single Lotus project can hold several web applications. These are created in
  `./apps`, with the default `./apps/web` already created for you. The idea is
  to develop your domain model much like a Ruby gem in `./lib`, and build the
  web-facing parts in `./apps`. Different apps in a project might include a
  control panel, an API, a public-facing marketing website, and so forth.
* Consequently, Lotus applications don't have the familiar `models` directory;
  you are expected to define your business objects in `./lib`. Rather than the
  Active Record pattern, [Lotus::Model][lotus-model] uses the [data mapper
  pattern][datamapper]. You get `./lib/demo/entities` and `./lib/demo/repositories`
  directories by default, as well as a `./lib/config/mapping.rb`.
* Actions and views are objects in Lotus. A controller is merely a collection of
  actions (in a module). This is reflected in the generated application
  structure: there is no `./apps/controllers/home_controller.rb` with an `index`
  method; instead, there is a `./apps/controllers/home/index.rb`, which defines a
  `Index` class.
* [Lotus::View][lotus-view] separates views from templates, much like
  [Mustache][] does. You are encouraged to put logic in the view object (such as
  `./apps/web/views/home/index.rb`) and your markup in a template file (i.e.
  `./apps/web/templates/home/index.html.erb`).
* Lotus currently has fewer Rake tasks and generators, although some interesting
  work is happening on this front. But, as you can tell from the generated
  directory structure, it is ready for test-driven development from the get-go.

Keep these points in mind and you'll find Lotus holds few other surprises.

## 01. First steps

Let's build a simple blogging application that shows a list of articles on the
front page. The simplest first step is a feature test for an empty page:

~~~ruby
# spec/web/features/homepage_spec.rb
require_relative '../../features_helper'

describe 'Homepage' do
  it 'links to the home page' do
    visit '/'
    assert page.has_link?('a', href: '/')
  end

  it 'shows a placeholder' do
    visit '/'
    assert page.has_css?('.placeholder', text: 'There are no articles yet.')
  end
end
~~~

Lotus comes with `spec/features_helper.rb` that sets you up for testing with
[Minitest][] and [Capybara][]. If you prefer RSpec over Minitest, you can
generate your initial application with the `--test=rspec` option.

Implementing these tests is easy enough; the new application comes with a
default action, view and template. All you need to do is uncomment the default
route:

~~~ruby
# apps/web/config/routes.rb
get '/', to: 'home#index'
~~~

See the full changeset at [bb301c][]. Launch a web server with `lotus server`
and bathe in the glory of your first Lotus application at [http://localhost:2300](http://localhost:2300).

Note that Lotus is in no way bound to any particular testing framework, nor does
it come with special test helpers or libraries. You'll do fine with Minitest,
and that's what I will use here --- but you could just as easily have used RSpec
by adding the `--test=rspec` option to the application generator.

## 02. Loading some data

Let's load some articles from a database to show on the page. We'll need to
prepare our database and set up some data access infrastructure. Lotus::Model
support various kinds of adapters, one of which is a schema-less filesystem
adapter (based on Ruby's `Marshal`) which is nice for rapid prototyping --- but
for demonstration purposes I'll stick to a conventional PostgreSQL database.

### Creating a database table with a Sequel migration

I'm going to assume you have a database set up (if not, look into Postgres'
`createdb` command). You could manually maintain your database schema, but
migrations under source control are much better. Lotus itself does not come with
schema management functionality yet (it's scheduled for the next release), but
since Lotus::Model uses [Sequel][] under the covers, we get [its database
migrations][sequel-migrations] for free.

Let's write a migration using Sequel's migrations DSL in
`./db/migations/001_create_articles.rb`. The filename is important: it is
prefixed with a database version number. Our migration might look like this:

~~~ruby
Sequel.migration do
  change do
    create_table :articles do
      primary_key :id
      String :title, null: false
      String :body, text: true, null: false
      Time :created_at, null: false, default: 'now()'
    end
  end
end
~~~

See [64f0e7][]. Run the migrations using Sequel's executable:

    % sequel -m db/migrations postgres://localhost/demo_development

If you find this cumbersome, the [Sequel migrations
documentation][sequel-migrations] contains an example of how you can turn this
into a Rake task.

### Accessing our database

To read and write from our database we'll need a `Lotus::Repository`, that can
map data from the database (using the mapper) to a `Lotus::Entity`. See
[7cd9b21][] for the full details, which is mostly simple boilerplate. Although
the use of `Lotus::Entity` is recommended, I like how an entity boils down to a
simple plain old Ruby object:

~~~ruby
module Demo
  class Article
    attr_reader :id, :title, :body

    def initialize(attributes = {})
      @id, @title, @body = attributes.values_at(:id, :title, :body)
    end
  end
end
~~~

If that's not easy to reason about, I don't know what is. And because Lotus
comes with some nifty Presenter features (which we'll see later in this post),
it comes quite naturally to keep view-related code separate from the entity.
I like how nudges you, the developer, into the right direction.

You can play around with how this works by firing up an interactive console with
`lotus console`:

    >> article = Article.new(title: 'Hello, world', body: 'Lorem ipsum')
    => #<Demo::Article:0x007fc879427810 @title="Hello, world", @body="Lorem ipsum">
    >> Demo::ArticleRepository.create(article)
    => #<Demo::Article:0x007fc879427810 @id=1 @title="Hello, world", @body="Lorem ipsum">

For testing purposes, make sure you enter some data into the database using
either the Lotus console, or by manually executing some SQL.

### Using our entities in our application

Armed with our new article repository and entity, we can change our application
to display our data. Refer to [bff69a6][] for the full changeset. Loading data
in a controller action is simple enough, but getting it into a template is a
little less magical than you might be used to from Rails. We explicitly `expose`
an action instance variable, so we can reference it in views and templates:

~~~ruby
module Web::Controllers::Home
  class Index
    include Web::Action

    expose :articles

    def initialize(repository: Demo::ArticleRepository)
      @repository = repository
    end

    def call(params)
      @articles = @repository.all
    end
  end
end
~~~

Exposures are stored in a hash attribute on the action, which makes for rather
elegant testing:

~~~ruby
require_relative '../../../spec_helper'

module Web::Controllers::Home
  describe Index do
    let(:repository) { OpenStruct.new(all: []) }
    let(:action) { Index.new(repository: repository) }

    it 'is successful' do
      response = action.call({})
      assert_equal 200, response[0],
        'expected HTTP status 200'
    end

    it 'exposes articles to the view' do
      action.call({})
      assert_same repository.all, action.exposures[:articles],
        'expected exposure to be result of repository.all'
    end
  end
end
~~~

Lotus is designed around simple objects with minimal interfaces that are easy to
test in isolation, yet still work great together. It has to be one of the
framework's most important strengths.

## 03. Creating a new, custom action

We've got an index that lists _all_ articles; now let's create a view for a
single article. We'll need a new action for that, along with a view, template
and accompanying tests. Luckily, Lotus has a generator that does just that:

    % lotus generate action web articles#show

Making this work is mostly re-using the same concepts as were used in building
the `Index` action, so refer to [e9342ff][] for the full diff.

Now we have a `Show` action, it would be nice to use our routing system to
generate URLs from the homepage to the article pages, as opposed to hard-coding
them into our templates. We can use `Lotus::Helpers::RoutingHelper` (from in
[Lotus::Helpers][lotus-helpers]), which comes included in all views by default,
to generate our URLs:

~~~ruby
# apps/web/config/routes.rb
get '/articles/:id', to: 'articles#show', as: 'article'

# apps/web/templates/home/index.html.erb
routes.article_path(id: 1) # => "/articles/1"
~~~

You can see this change applied in [d25b381][]. Lotus does not come with the
polymorphic routing system Rails provides (which would allow you to do
`link_to(article.title, article_path(article))` or even `link_to(article.title,
article)`), but this works just as well.

## 03. Using presenters for object-oriented view logic

Lotus, being a complete web framework, comes with presenters to wrap entities
with view logic, which I think works quite well. Since entities are so simple,
presenters are quite simple too: they're basically decorators with the nice
addition of auto-escaping HTML characters in their output. A Lotus presenter
might look like this:

~~~ruby
class ArticlePresenter
  include Lotus::Presenter

  def created_at
    super.strftime '%d %m %Y %H:%M'
  end
end
~~~

Articles are wrapped in presenters in [a91fc9b][]. In this commit you can also
see how methods defined in a view are automatically available for the template.

### How Lotus loads code

This commit also demonstrates (through its use of the `load_paths`
configuration) something else I like about Lotus: it does not do fancy
autoloading like Rails does. Instead, it loads all it needs to load at launch
--- which is undeniably slower in big applications, but is consistent across
environments. Lotus does, however, take care to load as little code as possible:
everything is loaded when you launch a server or console, while only the
framework and its configuration are loaded when you run unit tests. This allows
you to have simplicity _and_ speedy tests.

One thing you might have noticed in the example application is the use of
`Web::Action` and `Web::View` constants, which are not explicitly defined
anywhere in the codebase. Lotus actually takes its `Lotus::Action` and
`Lotus::View` modules, duplicates them at launch to protect them from further
accidental modification and provides these as application-local constants. This
is what allows a Lotus project to contain multiple web applications at the same
time, without interference.

## 04. Implementing comments

A blog is not a blog without comments, and a web application is not a web
application when it doesn't write data. The article show page can contain a form
to post comments to the article through a new action (no form builders here,
just plain HTML --- although form builders are under development). Rather than
rendering a view, our action will redirect back to the article page. Using the
action generator, we can generate a `comments#create` action:

    % lotus generate action web comments#create

This will give us a view and template which we have no need for, so delete them.
The generator will create a `GET` route, so let's replace it with a nicer `POST`
route:

~~~ruby
# apps/web/config/routes.rb
post '/articles/:article_id/comments', to: 'comments#create', as: 'article_comments'
~~~


### Implementing the controller

Now we can implement our new `Web::Controllers::Comments::Create` action:

~~~ruby
module Web::Controllers::Comments
  class Create
    include Web::Action

    def call(params)
      Demo::CommentRepository.create(Demo::Comment.new(params))
      redirect_to "/articles/#{params[:article_id]}"
    end
  end
end
~~~

In its simplest form, this action simply creates a new `Comment` entity and then
redirects. Testing such an action is pretty easy. Here's a condensed example:

~~~ruby
it 'is redirects to the article' do
  Demo::CommentRepository.stub :create, true do
    response = Create.new(repo).call(
      article_id: 1,
      author: 'John',
      body: 'lorem ipsum'
    )
  end
  assert_equal 302, response[0]
  assert_equal '/articles/1', response[1]['Location']
end
~~~

Since Lotus actions are "just" Rack applications, the responses they generate
are Rack's standard tuple of HTTP status, headers and body. There's no need for
special test helpers to assert an action will send a redirection header.

### Listing an article's comments

Displaying the comments is easy enough, once you know that Lotus::Model doesn't
come with associations at the moment. So, to load comments for the article, we
have to implement a method on our newly created `CommentRepository` to look up
records by `article_id`:

~~~ruby
module Demo
  class CommentRepository
    include Lotus::Repository

    def self.for_article(article)
      query do
        where(article_id: article.id)
      end
    end
  end
end
~~~

Repositories can be extended with class methods that can be chained together.
Inside, you can use regular old Sequel methods to scope your query. Now we can
use our new repository method in our `Articles::Show` action:

~~~ruby
module Web::Controllers::Articles
  class Show
    include Web::Action

    expose :article, :comments

    def call(params)
      @article = Demo::ArticleRepository.find(params[:id])
      @comments = Demo::CommentRepository.for_article(@article)
    end
  end
end
~~~

From here, we can use our exposed `comments` to render them in in the
`articles/show.html.erb` template. See the full changesets adding commenting in
[42ded30][] and [e1bce61][].

## 05. More robust commenting

Our current implementation of commenting is, of course, rather naive. First,
let's look at validating the user's input; and then present some feedback to the
user.

### Parameter validation

Lotus comes with validations and parameter white listing built into the
controller layer. First, we whitelist the parameters that we want to accept in
our action:

~~~ruby
module Web::Controllers::Comments
  class Index
    include Web::Action

    params do
      param :author
      param :body
    end

    def call(params)
      # params only contains :author and :body keys
    end
  end
end
~~~

This is similar to what Rails' strong parameters feature does. In Lotus however,
we can also validate these parameters:

~~~ruby
module Web::Controllers::Comments
  class Index
    include Web::Action

    params do
      param :author, presence: true
      param :body, presence: true
    end

    def call(params)
      if params.valid?
        # continue processing
      else
        # present error to user
      end
    end
  end
end
~~~

If validation in the controller layer seems odd to you, you might want to read
[Luca Guidi's reasoning behind the design of
Lotus::Validations][validations-design]. It nicely explains why you might want
to validate in the controller layer, or mix validations into use case objects,
rather than into the model layer.

Parameter objects can also do coercion and deal with nested parameters, but for
now this will do. See [455fc58][] for my implementation of comment validation.

### Providing user feedback

Now we have added validations, it would be useful to provide the user with some
feedback when his comment was (or wasn't) added. Lotus provides the "flash"
pattern we know from Rails, whereby we can store information in the session for
the next (and _only_ the next) request. This feature is technically still
private, so be advised it might change in the future.

For this to work, we need to enable sessions in our application configuration:

~~~ruby
# uncomment this line in apps/web/application.rb
sessions :cookie, secret: ENV['WEB_SESSIONS_SECRET']
~~~

The secret for encrypting our cookies is read from the environment, which in
turn is populated using [Dotenv][] from `config/.env`.

Next, we can set a message in our `Articles::Create` action:

~~~ruby
comment = Demo::Comment.new(params)
if params.valid? && Demo::CommentRepository.create(comment)
  flash[:notice] = 'Comment added'
else
  flash[:alert] = 'Something went wrong. Please try again.'
end
~~~

All that is left to us now is to show the contents of the flash to the user on
our page. This is where things get a little tricky --- and interesting.

### Rendering flash in the view

Your first guess would be to access `flash` in your template, but that wouldn't
work. Our views (and therefore our templates) know nothing about the flash. This
is, after all, purely a controller concern. To make the `flash` method available
in the view layer, we'll need to `expose` it. To always expose the flash to any
view, we can modify our application configuration, which contains a
`controller.prepare` block. This block will be included in our custom
`Web::Action` module, and will therefore be available in every controller
action. Let's expose our flash there:

~~~ruby
# apps/web/application.rb
controller.prepare do
  expose :flash
end
~~~

Next, we can access `flash` in our template, but building a loop around possible
keys in the `flash` is hardly a template concern. What's more, we probably want
the flash to display consistently across all our templates --- so it should
probably go into the application layout rather than an individual view. 

Let's loop over the available flash contents in our application template:

~~~eruby
# apps/web/templates/application.html.erb
<% each_flash do |style, message| %>
  <div class="flash flash--<%= style %>">
    <%= message %>
  </div>
<% end %>
~~~

...and implement the `each_flash` message in our layout view object:

~~~ruby
# apps/web/views/application_layout.rb
module Web::Views
  class ApplicationLayout
    include Web::Layout

    def each_flash
      %i(alert notice).each do |type|
        message = @scope.locals[:flash][type]
        yield type, message if message
      end
    end
  end
end
~~~

Accessing the local scope of the view from a layout with `@scope.locals` was not
particularly well documented, but easy enough to find by reading through the
source code --- a fun exercise in itself.

That nicely isolates the rendering of flash messages in our application layout,
where it belongs. You can review the full changeset in [877e608][].

## 06. Rounding up

The last few commits in the repository add some CSS and documentation, so gloss
over them if you like. Note that although there is a
[Lotus::Assets][lotus-assets] framework, with support for asset precompilation,
it does not come preconfigured with Lotus yet. In the meantime, Lotus _will_
simply render static files from an app's `public` directory (e.g.
`apps/web/public`).

If you've come this far, you've seen the most important aspects of building web
applications with Lotus, including data access, schema migrations, dealing with
HTTP requests and unit testing. Lotus comes with many more features that I could
not fit into this one guide, such as dealing with HTTP caching and mime types,
security, REST-ful resources, view partials, and interactors (a.k.a. service
objects). There's plenty more for you to discover on your own.

There's also plenty left to do around the framework. Lotus::Model works nicely
but is not as feature-complete as, say, ActiveRecord or [ROM][], and some kind
of support for static assets would be good. Also, documentation is still lacking
and the toolbelt could do with some more automation. You can follow along with
future developments on the Lotus blog, where weekly changelogs are posted. All
in all, for 0.3.0 release, I think Lotus is doing pretty damn good.

After playing around with Lotus for a while, I really like how it allows me to
build web applications by writing Ruby code. Unlike Rails, there's no question
about the dividing line between the language and the framework; it's all _just
Ruby_. As a simpler, but still complete framework, I think it fills a nice niche
between [Sinatra][] and [Rails][].

Check out [the Lotus website][Lotusrb] for more information and documentation,
and go forth and play!

[Lotusrb]: http://lotusrb.org/
[Luca Guidi]: http://lucaguidi.com/
[lotus-router]: https://github.com/lotus/router
[lotus-controller]: https://github.com/lotus/controller
[lotus-helpers]: https://github.com/lotus/helpers
[lotus-view]: https://github.com/lotus/view
[lotus-model]: https://github.com/lotus/model
[lotus-assets]: https://github.com/lotus/assets
[repo]: https://github.com/avdgaag/lotus-demo
[Mustache]: https://mustache.github.io/
[Minitest]: https://github.com/seattlerb/minitest
[Capybara]: https://github.com/jnicklas/capybara
[bb301c]: https://github.com/avdgaag/lotus-demo/commit/bb301c3ff
[64f0e7e]: https://github.com/avdgaag/lotus-demo/commit/64f0e7e
[bff69a6]: https://github.com/avdgaag/lotus-demo/commit/bff69a6
[e9342ff]: https://github.com/avdgaag/lotus-demo/commit/e9342ff
[d25b381]: https://github.com/avdgaag/lotus-demo/commit/d25b381
[a91fc9b]: https://github.com/avdgaag/lotus-demo/commit/a91fc9b
[64f0e7]: https://github.com/avdgaag/lotus-demo/commit/64f0e7
[7cd9b21]: https://github.com/avdgaag/lotus-demo/commit/7cd9b21
[e1bce61]: https://github.com/avdgaag/lotus-demo/commit/e1bce61
[42ded30]: https://github.com/avdgaag/lotus-demo/commit/42ded30
[455fc58]: https://github.com/avdgaag/lotus-demo/commit/455fc58
[877e608]: https://github.com/avdgaag/lotus-demo/commit/877e608
[Sequel]: http://sequel.jeremyevans.net/
[sequel-migrations]: http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html
[datamapper]: http://martinfowler.com/eaaCatalog/dataMapper.html
[validations-design]: http://lucaguidi.com/2014/10/23/introducing-lotus-validations.html
[Dotenv]: https://github.com/bkeepers/dotenv
[ROM]: http://rom-rb.org
[Sinatra]: http://www.sinatrarb.com/
[Rails]: http://rubyonrails.org/
