---
tags:
  - code
  - javascript
created_at: 2009-08-13 9:05
kind: article
title: Awesome Javascript memoization
---
## Regular memoization

Here's an easy way to memoize expensive Javascript functions. It introduces slightly obscure code and an extra function call, but if your operation is expensive enough to memoize, it is probably worth the extra overhead:

{: .language-js }
    this.foo = function(){
        var foo = expensive_operation();
        return (this.foo = function() { return foo; })();
    };

What this function does is redefine itself, so on subsequent calls it only returns a static value. Neat.

## Argument-specific memoization

There is another way of memoizing expensive operations in Javascript, which is also fit for argument-specific results:

{: .language-js }
    base._fooCache = {};
    base.foo = function(arg) {
        if(base._fooCache[arg] === undefined) {
            base. _fooCache[arg] = ...expensive operation...
        }
        return base. _fooCache[arg];
    };


This just keeps a local key/value cache of the result of the expensive operation for the given argument. This only works for a single argument right now, but I guess it could be extended to multiple arguments.
