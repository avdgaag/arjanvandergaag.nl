---
title: Use your editor to write simpler code
kind: article
created_at: 2016-03-20 12:00
tags:
 - ruby
 - editor
 - programming
 - software
---
I like simple software. But that does not mean that's always what is easiest to write. Here are a few ways in which you can use your editor and related tools to make it easier to write simple software.
{: .leader }

## Using snippets to write better code

### The problem: boilerplate in Ruby class definitions

Ruby is a very dynamic programming language. Its meta-programming capabilities allow developers to extend the language with custom constructs. For example, here's a simple class definition:

~~~ ruby
class Invoice
  def initialize(customer, total_amount)
    @customer = customer
    @total_amount = total_amount
  end

  private

  attr_reader :customer, :total_amount
end
~~~

Some people see this and think: "This is ugly. I know, I'll use a struct!"

~~~ ruby
Invoice < Struct.new(:customer, :total_amount)
~~~

True, `Struct.new` will give you a class with an initializer with positional arguments. But is your invoice really a value object, as `Struct` implies? I doubt it. Do you want to enumerate over an `Invoice`'s properties using `#each`? Unlikely. Also, your reader methods are no longer private.

If you install the [attr_extras][] gem, you can shorten this to the following:

~~~ ruby
class Invoice
  pattr_initialize :customer, :total_amount
end
~~~

You've even got private reader methods back! The objective of attr_extras is to "take some boilerplate out of Ruby, lowering the barrier" to create more, smaller classes. Both the use of structs and attr_extras is presented as better than the original class, because it is fewer lines of code. Fewer lines of code means fewer bugs and easier comprehension, right?

I, personally, very much prefer the original full-length code example. I find it perfectly acceptable to read, with all lines serving a purpose and being on the same level of abstraction. I do admit it is more lines of code to type. That's a nuisance, but any decent editor can help with that.

### The power of smart snippets

Here's snippet I have set up in my editor (currently [Emacs][emacs-snippet], but I also had this in [Vim][vim-snippet]):

![Animation of snippet expansion](/images/snippet.gif)

The snippet is triggered using the `class` keyword in Ruby files, and does a couple of things:

1. it generates a new class name by converting the file name from snake case to camelCase;
2. it has a placeholder for a parent class, that can be deleted with a single keystroke;
3. it generates a default `initialize` method, because you were probably going to write one anyway;
4. when you customize the initializer arguments, changes are mirrored to both the initializer body (setting instance variables of the same name) and to the class body (defining private reader methods);
5. finally, it provides a default comment block to provide a class description.

In this case, generating a new class with an initializer, instance variable assignments and defining reader methods is pure convenience: it saves me from typing what I would have typed anyway. The class comment block and the repeated calls to `attr_reader` and `private` are nudging me into the right direction: I most likely would not have written the code like this without the snippet, even though this code is easier to document and refactor than the more concise alternative; and I most likely would have forgotten about the comment block. In this case I am using my editor to write good code, without the need for metaprogramming and DSLs.

I like metaprogramming. And I've written some libraries in the past the used metaprogramming or DSLs to "reduce some boilerplate". I've almost always thrown them out shortly after introducing them. Code is read way more often than it is written, so I've come to be skeptical about write-time optimizations that make code actually harder to read.

## Templating languages: Haml/Slim or Erb?

### The problem: minimalist markup

[Haml][] and [Slim][] are template languages that introduce an alternative syntax for HTML, aimed at reducing boilerplate (there it is again!) in the notoriously verbose HTML. Compare this Slim template:

~~~ slim
.invoice
  h1 Invoice #{@invoice.number}
  p
    Customer:
    = @invoice.customer.name
  p
    Total amount:
    = @invoice.total_amount
~~~

...to this Erb template (HTML with embedded Ruby):


~~~ rhtml
<div class="invoice">
  <h1>Invoice <%= @invoice.number %></h1>
  <p>Customer: <%= @invoice.customer.name %></p>
  <p>Total amount: <%= @invoice.total_amount %></p>
</div>
~~~

The Slim template is definitely fewer characters. But is it easier to read? I actually find it harder to parse, since there is no clear indication where any particular element ends (explicit closing tags are easier to read a difference in whitespace), or that both `.invoice` and `h1` are HTML opening tags. I have to spend more mental cycles on reading the Slim code transforming it into HTML in my head, than I have to with Erb, which is already HTML, but with some interpolated Ruby code.

### On writing HTML

But writing Slim is so much easier than writing HTML! All those extra characters are such a chore! Again, editors are your friend. The structured nature of HTML makes it rather easy to edit; any half-decent editor has facilities for removing tags, wrapping selections in tags, changing tags (both opening and closing tags) and so forth. An editor is also perfectly capably of automatically inserting closing tags for you, and indenting your code. And with an extension like [Emmet][], available for many editors, even writing HTML code is easy:

![Emmet demo](/images/html.gif)

Emmet allows you to write a CSS-style selector and generate HTML code from it, additionally supporting repeating, attributes and text values.

## CoffeeScript, ES6 and JavaScript

### The problem: JavaScript... well, JavaScript.

Take CofeeScript, which is a little language that compiles to JavaScript. It aims to take the Java out of JavaScript. Its golden rule is "it's just JavaScript". So it doesn't actually give you anything new in terms of functionality, it just gives you prettier JavaScript (a lofty goal, for sure). It allows you to replace this:

~~~ js
function Invoice(customer, total_amount) {
  this.customer = customer;
  this.total_amount = total_amount;
}

Invoice.defaultCurrency = 'EUR';

Invoice.prototype.customerName = function() {
  return this.customer.name;
}
~~~

with this:

~~~ coffee
class Invoice
  constructor: (@customer, @total_amount) ->

  @defaultCurrency = 'EUR'

  customerName: ->
    @customer.name
~~~

It sure it fewer lines and characters of code, although there's nothing here that couldn't be solved with a good editor snippet. CoffeeScript replaces some explicit boundary markers (curly braces, semicolons) with significant whitespace, which I don't like for the same reasons I did not like it in Haml and Slim. CoffeeaScript allows you to define classes where arguments are immediately set as properties on the new object. As with significant whitespace, it replaces _explicit_ code with _implicit_ code -- leading to more mental cycles spent on translating _what's on the screen_ to _what will be run_.

### Changing the programming model

Also consider the `@defaultCurrency`: it looks like an "instance variable", but actually is a property on the constructor function. This makes perfect sense, as long as you remember that `@` in CoffeeScript is simply replaced by `this.`. It really is just JavaScript. But such subtle differences are quickly obscured by significant whitespace when indented more than one level deep.

Why do you need to consider such differences at all? Because you are not writing CoffeeScript, you are writing JavaScript with a different syntax. Compare that to, for example, ClojureScript: it may get compiled down to JavaScript in the end, but you are not dealing with the semantics or constructs of JavaScript at all. With CoffeeScript, you do -- and it's the more confusing for it.

How about transpiling ES6 using Babel to JavaScript then? I'm fine with that, for the most part. When you use `const` instead of `var`, you actually use a different construct that wasn't there before in JavaScript (even though it is only enforced at compile time). As with ClojureScript, transpiling ES6 to JavaScript actually gives _something_ new, albeit not much. Consequently, I personally tend to use the "new" stuff in ES6 (modules and imports, `const` and `let`) more than the new syntax (classes, arrow functions).

## Favor code generation over framework configuration

### The problem: writing lots of (seemingly) duplicate code

Finally, back to Ruby and Rails in particular. Consider the case of gems such as [ActiveAdmin][]: they aim to provide an out-of-the-box administration interface to your application data. It is a highly configurable library that helps you avoid the tedious effort of writing the same old CRUD-interfaces over and over again. I hope that by now, you will not be surprised by my stance towards libraries like this: you are better off writing this code yourself.

![ActiveAdmin DSL](/images/activeadmin.png)

Note how libraries like ActiveAdmin help you avoid writing the same old CRUD-interfaces over and over again. It saves you time because you have to _write_ less code. But _writing_ code isn't that hard or time-consuming; understanding and maintaining it _is_. With ActiveAdmin, you introduce a complex DSL and configurable sub-application into your own application to do something so simple, it's boring to do it yourself. But the dichotomy between boring and magic complexity is a false one. Remember, if there is one thing in the world that a framework like Ruby on Rails is particularly well suited for, it's generating extensive, boring CRUD-applications: `rails generate scaffold`, anyone?

### Rails generators to the rescue

Unlike most, I'm actually quite fond of Rails generators. They help you generate a bunch of code that is mostly the same, and then make it easy to customize it -- no configuration involved. True, Rails' own scaffold generator isn't all that great. That's why you can (and _should_) customize it: add styles, tables, navigation, search, filtering, sorting, you name it! You can override all the templates Rails uses to generate controllers, models, helpers, views and assets. This is a powerful but underrated feature in the Rails community.

As a reminder, here's part of a controller that Rails generates by default when you invoke the scaffold generator:

~~~ ruby
# POST /invoices
# POST /invoices.json
def create
  @invoice = Invoice.new(invoice_params)

  respond_to do |format|
    if @invoice.save
      format.html { redirect_to @invoice, notice: 'Invoice was successfully created.' }
      format.json { render :show, status: :created, location: @invoice }
    else
      format.html { render :new }
      format.json { render json: @invoice.errors, status: :unprocessable_entity }
    end
  end
end
~~~

This output is probably generated using one of Rails' own templates, or one provided by gems. In this case, it was generated using the [Jbuilder controller template][]. To customize this code for all subsequent generator calls, copy the source file to your project in `lib/templates/rails/scaffold_controller/controller.rb`:

~~~ ruby
# POST <%= route_url %>
# POST <%= route_url %>.json
def create
  @<%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>

  respond_to do |format|
    if @<%= orm_instance.save %>
      format.html { redirect_to @<%= singular_table_name %>, notice: <%= "'#{human_name} was successfully created.'" %> }
      format.json { render :show, status: :created, location: <%= "@#{singular_table_name}" %> }
    else
      format.html { render :new }
      format.json { render json: <%= "@#{orm_instance.errors}" %>, status: :unprocessable_entity }
    end
  end
end
~~~

**Side note** actually finding the right source file to customize can be tricky. Rails has its own templates, and gems listed in your Gemfile may provide alternatives. Anyway, Rails' own templates are a good enough starting point. You can find them all in [`lib/rails/generators` in the railties gem][railties-generators].

Tweak it to your heart's content. When you are done and run the generator again, Rails will prompt you to replace the already existing files:

~~~
      invoke  active_record
   identical    db/migrate/20160320130336_create_invoices.rb
   identical    app/models/invoice.rb
      invoke    test_unit
   identical      test/models/invoice_test.rb
   identical      test/fixtures/invoices.yml
      invoke  resource_route
       route    resources :invoices
      invoke  scaffold_controller
    conflict    app/controllers/invoices_controller.rb
  Overwrite /path/to/project/app/controllers/invoices_controller.rb (enter "h" for help) [Ynaqdh]
~~~

You can confirm with `y` to do wholesale replacement, or use `d` to inspect a diff between the existing file and the newly generated file. Easy peasy!

### The case _for_ "duplication"

The thing is, generating code feels icky to most developers because it gives you a lot of code that _looks_ the same. And most developers' initial reaction to code that looks the same is that _is_ the same: it's duplication that should be removed. It's only a small step from "these two controller actions look very much alike" and ActiveAdmin. But, of course, they are _not_ the same. Different parts of a standard CRUD administration panel do different things, change at different rates and need to be refactored in different ways. This is easy when the code is right there, in front of you. It gets increasingly hard to try and make an administration framework accommodate it.

Perhaps unsurprisingly, in every project I ever worked on that used ActiveAdmin, it was eventually replaced by a hand-rolled admin interface. Not only does using ActiveAdmin hardly give you any speed gains (you are mostly optimizing the one thing that was already quick and easy anyway), it actively hurts team velocity and code maintenance efforts required in the longer run.

### Updating lots of similar code

"But," I hear you complain, "what if we want to tweak the design of the entire admin interface? There's so much almost-duplicated code that we need to change! It would be so much easier if all of it was shared code, and we only had to update it in a single place!" This is of course, a mostly valid argument. But:

1. Do not overestimate the time it takes to change 40 view templates to add a single class name to an HTML element, just to name an example. It sounds very, very inefficient to go in and change all those files by hand (and it is!), but in the end it will only take you half an hour. That's nothing compared to the hours spent debugging why specific monkey patches or customizations of an admin-framework have unintended side effects. Don't confuse _inefficient_ with _time-consuming_.
2. Again, your editor can help. With project-wide regular expression-powered search and replace you can fix a lot of stuff. What's important to note here, is that for any given problem, you can probably write a regex-based replacement operation that covers 80% of your use case in ten minutes (especially when you use something like the [second-order Git diff trick][]. Getting it foolproof may take much more time, or may not even be possible at all without more advanced tools, but you don't _need_ to get it foolproof: you need to get the job done as quickly as possible. It's fine to get it mostly right with some scripting, and completely right with some manual fixes.
3. Finally, remember that you can always re-run your generators. Code is not sacred and can be thrown out. At times, when I wanted to introduce some changes to how automatically generated Rails controllers worked, I just tweaked the templates and regenerated the whole lot. Sure, it removed some of the customizations I had made to some of the controllers, but those were easy to restore using my version control system.

## Conclusion

There is a trend toward writing as little code as possible, replacing explicit but boring or superficially similar code with metaprogramming magic, libraries and implicit conventions. This introduces unnecessary complexity in your code base and makes the code harder to read for the human developer. And you are just shaving off a couple of seconds or minutes from the part of software development process that was already the quickest and easiest to begin with. As developers we have powerful tools at our disposal, that we can us to produce simpler code. In effect, we shift the complexity from our code base into our tooling, leaving us with an end product that is simpler and clearer as a result.

[attr_extras]: https://github.com/barsoom/attr_extras
[ActiveAdmin]: https://github.com/activeadmin/activeadmin
[Jbuilder controller template]: https://github.com/rails/jbuilder/blob/master/lib/generators/rails/templates/controller.rb
[railties-generators]: https://github.com/rails/rails/tree/4-2-stable/railties/lib/rails/generators/rails
[emacs-snippet]: https://github.com/avdgaag/dotfiles
[vim-snippet]: https://github.com/avdgaag/dotfiles
[Haml]: http://haml.info
[Slim]: http://slim-lang.com
[Emmet]: https://en.wikipedia.org/wiki/Emmet_(software)
[Second-order Git diff trick]: http://blog.moertel.com/posts/2013-02-18-git-second-order-diff.html
