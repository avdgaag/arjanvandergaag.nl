---
title: Modular front-end code in Rails
kind: article
created_at: 2012-08-23 12:00
tags: [ruby, rails, css, sass, programming, web development]
---
Maintainable stylesheets of non-trivial size need a modular design — so much has been established by now. How can you incorporate this style of front-end coding in a typical Rails application?
{: .leader }

## Modular CSS

With 'Modular CSS' I mean a range of new ideas in front-end web development
aiming to solve some of the issues with giant catch-all .css-files, rife
with duplication and specificity conflicts. These approaches typically
revolve around defining "objects", "modules" or "components" in your
stylesheets, in order to reduce the cost of change by:

* increasing style re-use and, by extension, consistency;
* creating a shared language among team members;
* decoupling markup from styles.

To learn more about these ideas, check out [Nicole Sullivan][]'s
[Object-Oriented CSS][], [Jonathan Snook][]'s [SMACSS][], Yandex' [BEM][] and keep an eye out for [Roy Tomeij][]'s book [Modular Frontend][].

## Modular front-end code in Rails apps

Historically, Rails has "forced" many best practices on developers by
providing conventions for trivial matters (see [Yehuda Katz's RailsConf
2012 talk][katz-railsconf] for examples and background). But to properly
modularize our front-end code, we have to fight Rails a little bit and rid
ourselves of the "one controller, one stylesheet, one script" default file
layout. At the same time, Rails does provide us with some nice tools to
make our jobs easier: the [asset pipeline][], [Sass][] included by default, and `RecordTagHelper`.

**Note**: in this post I'm ignoring the Javascript aspect of front-end code on purpose. That's a story for another time.

## Marking up objects

The modularized front-end revolves around identifying the building blocks of your web pages, like a _post_, a _footer_ or a _horizontal list_. Rails' `content_tag_for` is a great help to mark these objects up:

    <%= content_tag_for(:article, @posts) do |post| %>
      <h2><%= post.title %></h2>
      <div class="content">
        <%= markdown post.body %>
      </div>
    <% end %>
{: lang="erb" }

This might generate the following output:

    <article id="post_1" class="post">
      <h2>My example post</h2>
      <div class="content">
        <p>Foo bar</p>
      </div>
    </article>
    <article id="post_2" class="post">
      <h2>Another example post</h2>
      <div class="content">
        <p>baz qux</p>
      </div>
    </article>
{: lang="html" }

Rails gives us a convention for naming and identifying objects. You would
typically provide styles for the `.post` class, and attach javascript
behaviour to individual posts using the `#post_1` and `#post_2` IDs.

**Note**: There is also a `div_for` tag, which does basically the same as
`content_tag_for` but omits the first argument and always gives you a
`div`. For more information, see the documentation on
[ActionView::Helpers::RecordTagHelper][RecordTagHelper].

If [Haml][] is more your cup of tea, you could write:

    %div[post]
      %h2= post.title
{: lang="haml" }

You will usually find yourself needing to go one step further and apply
object inheritence: a post can take many different forms on your site,
ranging from full articles, excerpts in an index or links in a sidebar.
Rails can still help us:

    <%- content_tag_for(:article, @posts, :excerpt) do |post| %>
      ...
    <% end %>
{: lang="erb" }

Will give us:

    <article id="excerpt_post_123" class="excerpt_post">
      ...
    </article>
{: lang="html" }

Although I would have preferred dashes insteads of underscores, Rails still
makes a trivial decision on how to name stuff for us, so let's stick with it.

## Partials, paths and STI

It is a natural fit to use a partial for every object you define. So, to
render blog post excerpts on your front page, you will end up with a
`posts/_excerpt_post` partial and a `modules/posts/excerpt_post.css.scss`
stylesheet. It is now trivial to render an excerpt post object anywere in
your application:

    <%= render partial: 'posts/excerpt_post', collection: @posts %>
{: lang="erb" }

Should you create custom Ruby objects — such as decorated models or
presenters that group multiple persistence objects into a single business
object — you may want to define `to_partial_path` on it to tell Rails how to
render them:

    require 'delegate'
    class ArticlePresenter < DelegateClass(Post)
      def to_partial_path
        'posts/article_post'
      end
    end
{: lang="ruby" }

Which would allow you to render an instance of `ArticlePresenter` like so:

    <%= render article_presenter %>
{: lang="erb" }

…and have it use the `posts/_article_post.html.erb` template.

Finally, Rails' Single Table Inheritance can get in your way. Consider you
have set up your models so that both `Post` and `Page` inherit from a
generic `Node` model. Using `content_tag_for` will give you `.post` and
`.page` classes. If you want to use the same styles for all `Node`
subtypes, you could apply the same styles to both classes in your
stylesheet, or you could use `ActiveRecord::Base#becomes`:

    <%= content_tag_for(:div, @post.becomes(Node)) do %>
      <h2><%= @post.title %></h2>
    <% end %>
{: lang="erb" }

`becomes` will give you a new `Node` object with all the attributes of the
`@post` object, so you will end up with the proper `.node` class on your
object. You can also use this trick to render child class using the partial
that would have been used for the parent class:

    <%= render @posts.map { |p| p.becomes(Node) } %>
{: lang="erb" }

See the [documentation on `#becomes`][becomes] and read [Henrik Nyh]'s notes on [using `becomes` with form helpers][using-becomes].

## Styling objects

Now you've got your `.post` object and various sub types, such as `.excerpt_post` set up. These are now trivial to style using Sass and the `@extend` directive:

    .post {
      h2 {
        color: #f00;
        margin: 20px 0;
      }
    }

    .excerpt_post {
	    @extend .post;
      h2 {
        margin: 0;
      }
    }
{: lang="css" }

Which would result in something like:

    .post h2, .excerpt_post h2 {
      color: #f00;
      margin: 20px 0;
    }
    .excerpt_post h2 {
      margin: 0;
    }
{: lang="css" }

With Sass 3.2, you might even keep the base `.post` class from the final style sheet — since you will most probably never use it on its own. Just use a placeholder selector:

    %post {
      color: #333;
    }
    .excerpt_post {
      @extend %post;
      font-size: 12px;
    }
    .article_post {
      @extend %post;
      font-size: 14px;
    }
{: lang="css" }

This leads to the base class not being output, only the extensions:

    .excerpt_post, .article_post {
      color: #333;
    }
    .excerpt_post {
      font-size: 12px;
    }
    .article_post {
      font-size: 14px;
    }
{: lang="css" }

## Catches

Much like object-oriented programming, we can define generic styles for all post objects, and add special styles to special instances. Also much like object-oriented programming, note that  that you 'child'-objects should not differ too much from your 'parent'-object; even though you are technically displaying a post object, it may be a better idea to classify your sidebar link item as a "link" rather than a "post". Here, Rails leaves you on your own and you will have to write your markup yourself:

    <li id="link_<%= post.id -%>" class="link">
      <%= link_to post.title, post %>
    </li>
{: lang="erb" }

This is a nuisance, but it would be trivial to write a helper method for it.
I haven't come across it much in practice.

## Don't forget about mixins

Regardless, it is clear it makes sense to think about your object hierarchy
before your build it. Also, as Ruby itself shows us with its modules, not
everything is modelled best with a hieriarchical structure. Consider mixins to
share styles across object types:

    @mixin sidebar_link {
      font-weight: bold;
    }
    .link_post {
      @include sidebar_link;
    }
    .link_comment {
      @include sidebar_link;
    }
{: lang="css" }

## Organising your files

Using the aforementioned techniques, you will quickly end up with a bunch of
styled objects. It is probably best to abandon Rails' convention of
one-stylesheet-per-controller and keep each in a separate file using the module
pattern:

    app/
    |--assets/
    |  |--stylesheets/
    |  |  |--application.css
    |  |  |--layout.css.scss
    |  |  |--elements.css.scss
    |  |  |--modules/
    |  |  |  |--post.css.scss
    |  |  |  |--excerpt_post.css.scss
    |  |  |  |--link_post.css.scss

**Tip**: When using Rails generators, you can provide the `--no-assets` or
`--no-stylesheets` flag (along with `--no-helper`) to not generate the regular
asset files you are not going to use anyway.

Your modules directory quickly clutters up so you had better group them in
subdirectories:

    app/
    |--assets/
    |  |--stylesheets/
    |  |  |--application.css
    |  |  |--layout.css.scss
    |  |  |--elements.css.scss
    |  |  |--modules/
    |  |  |  |--posts/
    |  |  |  |  |--post.css.scss
    |  |  |  |  |--excerpt_post.css.scss
    |  |  |  |  |--link_post.css.scss
    |  |  |  |--comments/

## Concatenating assets

With so many files lying around, it would of course be great if you could
include them all in one fell swoop, rather than importing each by hand in the
`application.css` manifest file. Sprockets can do that for you:

    /*
     * in app/assets/stylesheets/application.css
     * require_tree .
     */
{: lang="css" }

Done! But Sprockets, alas, will first compile every file and _then_ concatenate
them together. Now Sass will no longer be able to use mixins and variables from
one file in another. This is a disappointment, so you will have to bypass
Sprockets for concatenation and let Sass handle it for you. Rename
`application.css` to `application.css.scss` and let the [sass-rails][] gem
handle the importing for your:

    // in app/assets/stylesheets/application.css.scss
    @import "modules/**/*"
{: lang="css" }

This approach imports your modules sorted alphabetically, which is a great way
to foce yourself to write truly independent modules that do not depend on the
order in which they are defined. In practice, this might not work out, in which
case you will have to revert to importing every module by hand in your manifest
stylesheet.

## Conclusion

There's a little bit of friction when adopting these methods in your Rails
application, but for the most part it is easy to get started and Rails has some
nice convenience methods for us to use. With a little bit of discipline you can
set up a very neat and organised front-end codebase — just make sure your
approach is documented so all your team members are on the same page with you.

If you have any other tips, [let me know on Twitter][twitter]!

[Modular Frontend]: http://modular-frontend.com
[Nicole Sullivan]: http://www.stubbornella.org
[Jonathan Snook]: http://snook.ca
[Object-Oriented CSS]: http://oocss.org
[SMACSS]: http://smacss.com
[BEM]: http://bem.github.com/bem-method/pages/beginning/beginning.en.html
[Roy Tomeij]: http://roytomeij.com
[katz-railsconf]: http://www.confreaks.com/videos/907-railsconf2012-rails-the-next-five-years
[RecordTagHelper]: http://api.rubyonrails.org/classes/ActionView/Helpers/RecordTagHelper.html
[becomes]: http://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-becomes
[using-becomes]: http://henrik.nyh.se/2012/08/rails-sti-and-form-for/
[Henrik Nyh]: http://henrik.nyh.se
[sass-rails]: https://github.com/rails/sass-rails
[asset pipeline]: http://guides.rubyonrails.org/asset_pipeline.html
[Sass]: http://sass-lang.com
[twitter]: http://twitter.com/avdgaag
[Haml]: http://haml.info
