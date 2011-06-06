---
created_at: 2010-08-18 13:35
tags:
  - code
  - css
  - html
  - ie
  - web
kind: article
title: Internet Explorer 6 and media types
---
When trying to reduce the number of HTTP requests on a web project I was working on, I tried to combine my screen and print stylesheets into a single file. Using the `@media` declaration, one should be able to specify media-specific styles. Other browsers were ok, but as usual IE6 was playing up. My `@media print` block was completely ignored.

## The setup

First, I had only generic rules and a single print block, like so:

{: .css }
    body { font-size: 12px }
    @media print {
        body { font-size: 14pt }
    }

Then, I included the stylesheet on my page with a media type:

{: .html }
    <link rel="stylesheet" href="style.css" media="screen, projection">

As I understood the specs all generic styles (outside the `@media print` block) should apply to the media specified in the `link`, while the print-specific styles should apply only to the `print` media type.

## The solution

It seems the media type from the `link` overrides the `@media print` block in IE6, so removing that un-ignored those styles:

{: .html }
    <link rel="stylesheet" href="styles.css">

Then, in order to keep my generic styles (which are actually screen-only styles) from influencing my print styles, I used another `@media` block:

{: .css }
    @media screen {
        body { font-size: 12px }
    }
    @media print {
        body { font-size: 14pt }
    }

All was well and both my screen and print styles were picked up nicely. Now I could use one single stylesheet and remove one additional HTTP request, speeding up the site loading time.