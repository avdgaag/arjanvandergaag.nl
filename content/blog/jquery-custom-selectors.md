---
created_at: 2009-10-12 9:52
tags:
  - code
  - javascript
  - jquery
kind: article
title: jQuery custom selectors
---
I like writing jQuery plugins, so I can separate functionality into distinct units. But _applying_ the plugin sometimes requires some logic I'd rather have in my plugin itself.

## Example code

Say I want to create a plugin that creates a lightbox-style image zooming effect. I want to apply it to all links pointing at an image:

{: lang="html" }
    <a href="/images/photo1.jpg"><img src="/images/photo1.jpg"></a>

Here's how I might call my awesome plugin in my main javascript file:

{: lang="js" }
    $(function() {
        // One option: create complex inline selectors:
        $('a[href$="jpg"], a[href$="png"]').awesome_plugin();

        // Second option: filtering
        $('a').filter(function() {
            $(this).attr('href').match(/\.(png|gif|jpe?g)$/);
        }).awesome_plugin();
    });

These both might work, but they move typical plugin logic to my javascript initializer. That's not what I want.

## Custom selector

The solution is so obvious I wonder why I did not think of it before: **write a custom jQuery selector**:

{: lang="js" }
    $(function() {
        $('a:to_image').awesome_plugin();
    });

Awesome: concise and with clear intent. Here's one way to implement it:

{: lang="js" }
    // Somewhere in my plugin
    $.expr[':'].to_image = function(obj, index, meta, stack) {
        return $(obj).attr('href').match(/\.(png|gif|jpe?g)$/);
    };

Now all the logic is nicely tucked away in my plugin.
