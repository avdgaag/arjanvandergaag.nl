---
created_at: 2010-6-24 13:53
tags:
  - code
  - javascript
kind: article
title: Using relatedTarget in Javascript event handlers
---
Here's a nice trick for working with mouse events in a web page. Given a simple drop down menu, I used to use a timer to delay the closing of a submenu while the mouse travels from the menu title to the sub menu (where it nog longer hovers over the menu title, that had the original event handler). The timer going off would hide the submenu, unless the mouse entering the submenu fired a new event handler that would reset the timer.

So, yeah, that wasn't ideal.

I learned the other day that, given **adjacent element** you can actually use `event.relatedTarget` to get to the element the mouse travels _to_ when _leaving_ the element that fired the `mouseout` event. Neat!

Now you can check for the target element and do all kinds of nifty stuff, and get rid of all timers. They sucked anyway.

Example jQuery code:

{: .js }
    $('nav a').mouseout(function(e) {
        var submenu = $('.submenu', this.parentNode);
        if(e.relatedTarget != submenu) {
            submenu.slideUp();
        }
    });