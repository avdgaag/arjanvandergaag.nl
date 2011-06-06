---
tags:
  - code
  - javascript
created_at: 2009-08-13 12:48
kind: article
title: Argument-specific memoization in Javascript
---
There is another way of memoizing expensive operations in Javascript, which is also fit for argument-specific results:

{: .js }
    base._fooCache = {};
    base.foo = function(arg) {
        if(base._fooCache[arg] === undefined) {
            base. _fooCache[arg] = ...expensive operation...
        }
        return base. _fooCache[arg];
    };


This just keeps a local key/value cache of the result of the expensive operation for the given argument. This only works for a single argument right now, but I guess it could be extended to multiple arguments.