---
created_at: 2009-08-21 10:03
tags:
  - code
  - javascript
  - development
kind: article
title: Internet Explorer and base elements
---
Internet Explorer treats the base element a bit diffently from other browser. I ran into the issue when trying to change the current page's hash through javascript:

{: lang="js" }
    window.location.hash = 'some_value';

Internet explorer took the entire base URL and prepended it to the hash, resulting in an URL like `http://domain.tld/http://domain.tld/#some_value`. That's clearly not my intention.

The trick lies in the `href` attribute for links. This actually points to the faulty long url, while its actual attribute value is only the hash:

{: lang="html" }
    <a id="link" href="#some_value">...</a>
    <script>
    // IE: http://domain.tld/#some_value
    // other browser: #some_value
    $('#link').attr('href');
    </script>

The trick is to replace anything before the pound when reading the `href` value, like so:

{: lang="js" }
    $('#link').attr('href').replace(/^.*(?=#)/, '');

And when trying to find links pointing at `#some_value` to not be too restrictive with your selector:

{: lang="js" }
    // finds 1 in other browsers, nothing in IE
    $('a[href="#some_value"]')
    // works like expected in all browsers; Note the *
    $('a[href*="#some_value"]')

Tricky stuff!
