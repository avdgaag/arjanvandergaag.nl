---
tags:
  - code
  - javascript
created_at: 2010-02-05 11:50
kind: article
title: Javascript typeof Nodelist
---
Beware of Javascript’s quirky `typeof`:

{: .js }
    typeof document.getElementsByTagName('p')

This will return `'function'`, which I did not expect. What _is_ returned is a `NodeList`, which behaves like an array, identifies itself as a function, but really is neither.

If you want to detect a `NodeList` you're better off with feature detection:

{: .js }
    var isNodelist = (typeof myvar.length != 'undefined &&
      typeof myvar.item != 'undefined')

Do note that this makes it probable you're dealing with a `NodeList` -- but you can't be sure.