---
title: Ruby protected methods
kind: article
created_at: 2015-07-14 12:00
tags: [ruby, code, development]
---
In addition to public and private methods, Ruby also knows protected methods.
Protected visibility does not have an obvious use case, so I thought I'd share
an example of how it could be put to use.
{: .leader }

Protected methods are mostly unavailable to outside callers, like private
methods are. The difference is is, that protected methods can be called by other
objects _of the same class_.

## Let us make a point

Consider we have defined a value object `Point`, consisting of a pair of
coordinates:

~~~ruby
class Point
  def initialize(x, y)
    @x, @y = x, y
  end
end
~~~

The two coordinates are an implementation detail of the value, so we don't
define public attribute reader methods. We can use our new point value like so:

~~~ruby
start = Point.new(3, 10)
finish = Point.new(5, 20)
line = Line.new(start, finish)
~~~

## Value object equality

Since value objects are defined by their contents, we want two points with the
same coordinates to be considered equal. This currently is not the case:

~~~ruby
Point.new(1, 1) == Point.new(1, 1)
# => false
~~~

Ruby lets us override the `#==` and `#eql?` methods to implement our own
comparison logic. For all intents and purposes, we can use the same logic in
these two methods:

~~~ruby
class Point
  def initialize(x, y)
    @x, @y = x, y
  end

  def ==(other)
    # TODO
  end
  alias_method :eql?, :==
end
~~~

Our custom `#==` method needs to compare its own coordinates to that of `other`.
The easiest solution is to expose attribute reader methods:

~~~ruby
class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def ==(other)
    self.class == other.class &&
      self.x == other.x &&
      self.y == other.y
  end
  alias_method :eql?, :==
end
~~~

This will solve our immediate problem:

~~~ruby
Point.new(1, 1) == Point.new(1, 1)
# => true
~~~

But, now we have exposed our value object's internal state to the world in order
to compare that object to another object of the same type.This is where
protected methods come into play.

## Declaring methods protected

We can use `protected` to expose our attribute readers to just other objects of
the same type:

~~~ruby
class Point
  attr_reader :x, :y
  protected :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def ==(other)
    self.class == other.class &&
      self.x == other.x &&
      self.y == other.y
  end
  alias_method :eql?, :==
end
~~~

Our custom comparison stil works, but you can no longer call the `x` and `y`
methods from outside a `Point` object:

~~~ruby
Point.new(1, 3).x
# => protected method `x' called for #<Point:0x007f7f82276678 @x=2, @y=2> (NoMethodError)
~~~

Ruby (since version 2) also reports that a `Point` object does not respond to
the `x` method:

~~~ruby
Point.new(1, 3).respond_to?(:x)
# => false
~~~

Admittedly, this use case isn't all that common in your everyday code. But if
Ruby supports it, it's good to know for that one time you actually need it.
