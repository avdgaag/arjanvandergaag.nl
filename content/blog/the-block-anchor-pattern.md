---
title: The a.block pattern
kind: article
created_at: 2011-03-23 10:00
tags: [html, css]
tldr: I explain how I use HTML anchors as block-level elements.
---
Wrapping block-level HTML elements inside an anchor (`<a>`) element has always worked fine, but used to be frowned upon. Standards dictated you should not put block-level elements inside inline elements. HTML5 has changed this, and now explicitly allows anchors to contain block-level elements.
{:.leader}

Before HTML5 we _could_ wrap, say, a `<div>` with an `<a >`, but it was considered invalid. Yet the wish remained to make entire areas clickable, rather than just a "Read more"-line. A larger clickable area improves CTR and reduces user mistakes.

## The problem

Given a typical 'story' element, where a headline, thumbnail and short introduction text would link the user to a full article, here's the effect you'd want to achieve:

{: .language-html }
    <div class="article">
        <a href="/story"><img src="pic.jpg" alt="Story thumbnail"></a>
        <h3><a href="/story">Story title</a></h3>
        <p><a href="/story">Lorem ipsum dolor sit amet</a></p>
        <a href="/story">Continue reading&hellip;</a>
    </div>

## Script-based solutions

That sort of markup is terrible to write -- let alone maintain. Javascript-solutions were concocted to keep markup clean, but still make the entire story-element respond to user clicks:

{: .language-html }
    <div class="article">
        <img src="pic.jpg" alt="Story thumbnail">
        <h3>Story title</h3>
        <p>Lorem ipsum dolor sit amet</p>
        <a href="/story" class="bigtarget">Continue reading&hellip;</a>
    </div>

And the script:

{: .language-js }
    // dummy javascript code
    $('.bigtarget').parent('div').click(function() {
        document.location = $('.bigtarget', this).attr('href');
    });

## The HTML5 way

With HTML5 it is now considered alright to do the following:

{: .language-html }
    <div class="article">
        <a href="/story">
            <img src="pic.jpg" alt="Story thumbnail">
            <h3>Story title</h3>
            <p>Lorem ipsum dolor sit amet</p>
            <span>Continue reading&hellip;</span>
        </a>
    </div>

That's clearly the best-looking code, without repetition or confusion of intent.

However, doing so introduces a problem with styles, as we probably don't want our image, heading and paragraph to look like links (you know, blue text, underlined, etc.). I therefore used the following pattern to counter this.

**First**, I introduce a class name to designate this is a special kind of anchor element:

{: .language-html }
    <div class="article">
        <a href="/story" class="block">
            <img src="pic.jpg" alt="Story thumbnail">
            <h3>Story title</h3>
            <p>Lorem ipsum dolor sit amet</p>
            <span>Continue reading&hellip;</span>
        </a>
    </div>

Using the `block` class, I can now reset the anchor's contents styles. I could do so manually for maximum compatibility, but if you target only modern browsers[^1] you could use `inherit`:

{: .language-css }
    a.block { display: block; }
    a.block, a.block * {
        text-decoration: inherit;
        color: inherit;
    }
    
…or something along those lines, depending on how you style your links.

**Second**, I want to give users a *visual cue* on the story's affordance of clicking. Therefore, we need something that looks like a link, and the story element in its entirety needs the same interaction as a link — i.e. `hover`, `focus`, `visited` and `active` states.

I only want to style part of the story as a link, but I'm not sure which part. Maybe a "read more"-line at the bottom, or the heading… Since this might differ from case to case, I chose to use a generic class to indicate the link target:

{: .language-html }
    <div class="article">
        <a href="/story" class="block">
            <img src="pic.jpg" alt="Story thumbnail">
            <h3>Story title</h3>
            <p>Lorem ipsum dolor sit amet</p>
            <span class="target">Continue reading&hellip;</span>
        </a>
    </div>

I could just add the `target` class to any of the other elements as well.

I style the target-element the same as my regular links:

{: .language-css }
    a.block .target {
        color: #009;
        text-decoration: underline;
    }

Now, the block looks like traditional content with a simple link at the bottom, but the user gets a nice surprise when hovering over the story thumbnail or title also activates the link.

Of course, you could also implement this same effect using just descendent selectors, like so:

{: .language-css }
    div.article a:first-child {
        display: block;
    }
    div.article a:first-child > span:last-child {
        text-decoration: underline;
    }

…but this is clearly not as neat as throwing in some reusable class names. I have found the `a.block` pattern to be helpful in keeping my markup and styles uncluttered.

*[CTR]: Click-Through Rate
*[HTML]: HyperText Markup Language
*[CSS]: Cascading StyleSheets
*[HTML5]: HyperText Markup Language 5

[^1]: Internet Explorer is known to not properly support the 'inherit' keyword.
