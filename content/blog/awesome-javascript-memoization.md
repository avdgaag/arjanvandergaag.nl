---
tags:
  - code
  - javascript
created_at: 2009-08-13 9:05
kind: article
title: Awesome Javascript memoization
---
Here's an easy way to memoize expensive Javascript functions. It introduces slightly obscure code and an extra function call, but if your operation is expensive enough to memoize, it is probably worth the extra overhead:

{: .js }
    this.foo = function(){
        var foo = expensive_operation();
        return (this.foo = function() { return foo; })();
    };

What this function does is redefine itself, so on subsequent calls it only returns a static value. Neat.