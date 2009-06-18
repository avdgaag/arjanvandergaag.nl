---
title: Writings by Arjan van der Gaag
layout: default
type: plain
articles:
  - filename: mensenrechten-en-islam
    title: Mensenrechten in Islamitische werelden
---

# {{ page.title }}

I try to publish as much of the writings I have produced over the years on this page. These are mostly from my academic career.
{: .leader }

Please note that I publish these works because they might help someone, some day -- they're are not to be quoted. All these writings are copyrighted. These works are mostly in Dutch. Perhaps I will some day provide English summaries, but don't hold your breath waiting for it.

## Writings by title ({{ page.articles.size }})

{% for article in page.articles %}
- [{{ article.title }}]({{article.filename }}.html "Read this article")
{% endfor %}