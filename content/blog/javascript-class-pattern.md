---
title: The Javascript Class Pattern
created_at: 2011-10-03 12:00
kind: draft
tags: [javascript]
---
## The constructor function

The most important part is the actual object that represents our class: the constructor function. This is the function you will invoke with the `new` keyword to create a new instance.

    function MyClass() {}
    var instance = new MyClass();

Behind the scenes, the following is happening:

1. Create a new object.

2. Execute the constructor function in the context of that object -- e.g. in
the constructor function `this` refers to the new instance.

3. Give the new object a `constructor` property, referring to the `MyClass`
function.

The body of the constructor function is the initializer method, that should take care of setting up a valid object. You can assign properties to the new instance:

    function MyClass(arg) {
        this.arg = arg;
    }
    var inst = new MyClass('foo');
    console.log(inst.arg); // => 'foo'

## Instance methods and properties

The next step would be adding methods to our class, so all instances can share them. One way would be to define a property as a function in the constructor:

    function MyClass() {
        this.greet = function() {
            console.log('Hello!');
        };
    }
    var inst = new MyClass();
    inst.greet(); // => 'Hello!'

The downside here is that every instance of our class will contain a new copy of this method. We would like them all to share the same method. This is where the prototype comes in. The prototype is just an another object. Every object keeps a reference to its prototype. When asking an object for the value of a property, it first looks at itself, and then at its prototype, to get a value. Because multiple objects can use the same prototype, we can define properties on the prototype of our class and have them shared amon all instances of our class. Since a function is just an object, we declare our properties on the constructor function itself:

    function MyClass() {}
    MyClass.prototype.greet = function() {
        console.log('Hello!');
    };
    var inst = new MyClass();
    inst.greet(); // => 'Hello!'

Now our program has only a single copy of the `greet` function, while many objects can use it. Note that `this` refers to the current object in the prototype function, not the prototype object it has been defined on. So we could use it to define and access instance properties:

    function MyClass(foo) {
        this.foo = foo;
    }
    MyClass.prototype.getFoo = function() {
        return this.foo;
    };
    MyClass.prototype.setFoo = function(foo) {
        this.foo = foo;
    };
    var inst = new MyClass('bar');
    inst.getFoo(); // => 'bar'
    inst.setFoo('baz');
    inst.getFoo(); // => 'baz'

Note that the prototype properties can hold any value you like -- not just functions.

## Property visibility

Javascript does not support property visibility. When you have an object, you can read and write all its properties. This is not a problem, but there is a trick to simulate private properties using a closure.

A closure is simple: it is an execution context that knows about its own context, but does not export itself. So a closure can access variables in the same context as it has been defined, but variables defined inside the closure are not accessible outside the closure.

A closure is essentially a function, so in order to be able to use variables only inside our class, we need to wrap it in a closure:

    var MyClass = (function() {
        var multiplier = 10;
        function MyClass(n) {
            this.n = n * multiplier;
        }
        return MyClass;
    })();

Here, we define our class in an anonymous function, that is immediately executed. The function returns our class, the constructor function, into the outer variable `MyClass`. Note how inside the class definition the variable `multiplier` exists. We can use it in the constructor function, because the `MyClass` function knows about its surroundings. But our anonymous function does not export anything to its surrounding apart from what is explicitly `return`ed. It only returns the `MyClass` function, so outside the closure `multiplier` does not exist.

An added benefit is that the wrapping closure function is a neat way of organizing our entire class definition into a single block of code.

## Inheritance

To make one class subclass another class, we could simply assign the parent class as the prototype object of the child class. Normal javascript property lookup will then try to find properties in the child class, and then up the prototype chain into the parent class. The effect is that the child class inherits all the properties of the parent class. It looks good. But note what happens when we do that:

    function Parent() {
        this.foo = 'bar';
        this.baz = 'qux';
    }
    function Child() {
        this.foo = 'bla';
    }
    var p = new Parent();
    console.log(p.foo); // => 'bar';
    var c = new Child();
    c.prototype = p;
    console.log(c.foo); // => 'bla';
    console.log(c.baz); // => 'qux';
    console.log(p.foo); // => 'bla';

Note how changing properties of `c` also changed the property in `p`: it is actually the very same property. That is no good, so we need to do better.

We can solve this problem by creating an intermediary prototype, a ghost object that no one knows about. This ghost object will share its prototype with the `Parent`, so it shares all properties of the `Parent`. But when we set the prototype of `Child` to an instance of our new ghost class, changing a prototype property on `Child` will trigger a change in that single instance, and not its protype. Hence, the original `Parent` prototype remains intact.

To get this to work, we need a helper function that takes care of the heavy lifting for us:

    function inherits(child, parent) {
        function ghost() {}
        ghost.prototype = parent.prototype;
        child.prototype = new ghost();
    }

Now, we can apply inheritance as follows:

    var Parent = (function() {
        function Parent() {
            this.foo = 'bar';
        }
    })();
    var Child = (function() {
        inherits(Child, Parent);
        function Child() {
            this.foo = 'baz';
        }
    })();
    var p = new Parent();
    var c = new Child();
    console.log(c.foo); // => 'baz'
    console.log(p.foo); // => 'bar'

There is one problem: if we ask an instance of `Child` about its type using `typeof`, it will tell us it's an instance of `ghost`, not of `Child`. We don't want that. Luckily, we can explicitly set what should be considered the constructor function in our object:

    function inherits(child, parent) {
        function ghost() { this.constructor = child; }
        // code omitted...
    }

It works like a charm. But we're not there yet.

## Accessing the parent class from the child class

When a child class does not implement a property, it will be looked for in the parent class. That's how inheritance works. But when we do implement it in the child, the parent function is completely sidestepped. How can we (easily) access that function?

We need to set a special property on our child class that refers to the original parent's prototype. We'll do that in our `inherits` function:

    function inherits(child, parent) {
        function ghost() {}
        ghost.prototype = parent.prototype;
        child.prototype = new ghost();
        child._super = parent.prototype;
    }

By setting the `_super` property, the child class can now access its conceptual parent's properties (remember, the technical 'parent' is the ghost object) using the `_super` property on the constructor function.

    var Child = (function() {
        function Child() {
            Child._super.constructor.call();
        }
    })();

Note that we explicitly name the `Child` class to access its `_super` property. We could use a slightly more obscure but flexible way:

    this.constructor._super.constructor.call();

## Class properties

Our `_super` property has introduced us to what you could call class properties, or 'static' properties. Remember, a function is just an object, so we can assign properties on it. So `Child._super` is a single property available on a single object, our `Child` 'class' i.e. constructor function.

In order to implement a no-surprises inheritance model, we need to make sure child classes inherit these properties as well from their parents. We simply need to copy any property of the parent constructor function to the child constructor function. Easy enough:

    function inherits(child, parent) {
        for(property in parent) {
            if(parent.hasOwnProperty(property)) {
                child[property] = parent[property];
            }
        }
        // code omitted...
    }

Note how we check if the property is actually defined on the parent constructor function itself, an not in its prototype chain. This helps us not override existing, native function properties such as `length`.

## Bonus: mixins

Copying the properties from one object to another sounds a lot like another incredibly useful idiom: mixins. Mixins allow us to add properties to an object, without implying a 'kind of' relationship.

A good example of this would be the observer pattern. We could want to have multiple objects with the capability to accept observers and trigger events, but there is no such thing as an 'observable' object -- being observable is a trait, not an identity.

Mixing in one object into another is what we're doing when we're copying class properties from the parent to the child, so we can abstract that into a separate function a re-use it:

    function mixin(child, parent) {
        for(property in parent) {
            if(parent.hasOwnProperty(property)) {
                child[property] = parent[property];
            }
        }
    }
    function inherits(child, parent) {
        mixin(child, parent);
        function ghost() {}
        ghost.prototype = parent.prototype;
        child.prototype = new ghost();
        child._super = parent.prototype;
    }

This allows us to enhance an individual object with new propertiesmethods. Such a collection is usually called a module, but in javascript it is just another object. Say we have a module for making any object capable of saying 'Hello, world!':

    var hello_module = {
        speak: function() {
            alert('Hello, world!');
        }
    };

We could mix this into any object we've got individually:

    var inst = new MyClass();
    mixin(inst, hello_module);

Since our constructor function prototype is also just an object, we could mix it into that to have the module mixed into any instance of our class:

    var MyClass = (function() {
        mixin(MyClass.prototype, hello_module);
        function MyClass() {}
    })();
    var c = new MyClass();
    c.speak(); // alerts 'Hello, world!'

## Wrap-up

So, with only two helper methods and some convention, we have built a fully-functional class system, including inheritance, private properties and mixins. This should make a great starting point for any javascript program.

Here are the two helper methods, slightly rewritten:

    function mixin(c, p) {
        for(k in p) if(p.hasOwnProperty(k)) c[k] = p[k];
    }

    function inherits(c, p) {
        mixin(c, p);
        function f() { this.constructor = c; };
        f.prototype = c._super = p.prototype;
        c.prototype = new f();
    }

Drop these into your script somewhere and you're ready to go. Here's a quick example of all the features discussed here:

    var Car = (function() {
        function Car(seats, wheels) {
            this.seats = seats;
            this.wheels = wheels;
        }
        Car.description = 'car';
        Car.prototype.describe = function() {
            console.log('This ' + this.constructor.description + ' is pretty cool.');
        };
        Car.prototype.drive = function() {
            console.log('Vroom, vroom goes the car with ' + this.seats + ' seats and ' + this.wheels + ' wheels.');
        };
        return Car;
    })();

    var Ferrari = (function() {
        inherits(Ferrari, Car);
        function Ferrari() {
            args = Array.prototype.slice.call(arguments);
            Ferrari._super.constructor.apply(this, [2].concat(args));
        }
        function warn() {
            console.log('Getting ready...');
        }
        Ferrari.description = 'awesome car';
        Ferrari.prototype.drive = function() {
            warn();
            this.constructor._super.drive.call(this);
        };
        return Ferrari;
    })();

    var f = new Ferrari(3);
    f.describe();
    f.drive();
    f.warn();

The output for this progam is as follows:

    This awesome car is pretty cool.
    Getting ready...
    Vroom, vroom goes the car with 2 seats and 3 wheels.

Then, it will throw an exception as there is no `warn` property defined on the `f` object -- it is defined as a private function inside the class closure.

I have found this pattern to be very useful for organizing my javascript code. It enables clean object-oriented design -- not least because of mixins -- and is simple enough to not need any complex helper functions for defining classes. It is all just plain, vanilla javascript with two helper methods.
