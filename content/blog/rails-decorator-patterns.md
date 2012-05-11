---
title: Rails decorator patterns
kind: article
created_at: 2012-05-11 15:00
tags: [code, rails, ruby, draper, oop]
---
After spending some time refactoring a collection of decorators in a Rails app
recently, I found that most of the decorator methods followed one of a small
set of patterns.
{: .leader }

These examples use code examples based on the [Draper][] gem, but the concepts
should apply to any decorator/presenter/exhibition pattern or library.

## 1. Linking

One scenario that keeps coming up is wanting to link to an object. Rather than
constructing your own using `link_to`, the decorated model should know how to
generate a link to itself:

{: .ruby }
    post = PostDecorator.decorate(post)
    post.link # => "<a href='...'>...</a>"

This does not seem all that special for regular objects, but consider nested
resources or date-based archives requiring complex arguments:

{: .ruby }
    class PostDecorator < ApplicationDecorator
      def link
        h.link_to title_with_comments, post_path(post, archive_params)
      end

      def title_with_comments
        "#{title} (#{comments_count})"
      end

      def archive_params
        { :month => created_at.month, :year => created_at.year }
      end
    end

This logic is best kept out of your view template. It is also better suited for
a decorator than a generic helper method. Compare:

{: .ruby }
    post.link
    archive_post_link_to(post)

This becomes extra helpful when using delegation:

    class AuthorDecorator < ApplicationDecorator
      def link
        h.link_to full_name, model
      end
    end

    class PostDecorator < ApplicationDecorator
      decorates :post
      decorates_association :author
      delegate :link, :to => :author, :prefix => true
    end

    post = PostDecorator.decorate(post)
    post.author_link # => '<a href="/authors/1">Arjan</a>'
{: .ruby }

It is a good convention to always have every model be able to generate a
sensible link to itself.

## 2. Filter attribute through helper method

Most custom decorator methods apply a single helper method to the value of an
attribute, like applying `number_to_currency` to a `product.price` method.

It is easy to write a simple macro for that in the base decorator:

{: .ruby }
    class ApplicationDecorator < Draper::Base
      def self.filter_attributes(*args)
        options = args.extract_options!
        [*args].each do |attr|
          define_method attr do
            h.send(options.fetch(:with), model.send(attr))
          end
        end
      end
    end

This allows you to write a decorator like so:

{: .ruby }
    class ProductDecorator < ApplicationDecorator
      filter_attributes :price, :with => :number_to_currency
      filter_attributes :created_at,
                        :published_at,
                        :with => :relative_time_in_words
    end

This pattern allows you to write generic helper modules that can be used
anywhere containing the logic you wish to use. The decorator then takes
care of
consistently applying it.

Note that it is probably best to get rid of your `ApplicationHelper` and not
generate any helpers for your controllers either. Its best to group your
helpers in sensibly named modules rather than by controller or in one big junk
drawer.

## 3. Translate attribute values

Attributes commonly contain values that need to be localized, like a status
column (e.g. 'published', 'draft', etc.). A decorator method would then usually
look like this:

{: .ruby }
    class PostDecorator < ApplicationDecorator
      def state
        h.t('activerecord.attributes.post.states').fetch state.to_sym
      end
    end

This is pretty tedious. A macro would help clarify intent, so we can create
something like the following:

{: .ruby }
    class ApplicationDecorator < Draper::Base
      def self.translate_attributes(translations = {})
        translations.each do |attribute, key|
          define_method attribute do
            h.t(key).fetch model.send(attribute).to_s.to_sym
          end
        end
      end
    end

This allows us to declare that an attribute value should be translated:

{: .ruby }
    class PostDecorator < ApplicationDecorator
      translate_attributes {
          :state => 'activerecord.attributes.post.states'
      }
    end

With the accompanying translation file:

{: .yaml }
    nl:
      activerecord:
        attributes:
          post:
            states:
              published: Gepubliceerd
              draft: Concept
              scheduled: Gepland

## Mix and match

These macros do not cover all use cases and do not allow easy mixing and
matching. When you find yourself wanting to combine such macros on a single
attribute, you are probably better off writing an explicit method.

[Draper]: https://github.com/jcasimir/draper
