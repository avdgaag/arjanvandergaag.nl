---
title: Rake task to ping Google
created_at: 2009-06-10 12:00
kind: article
tags: [ruby, rake, google, ping, automation, blog, blogging, script]
---
Creating and publishing a sitemap XML file helps search engines find and index
all of your content. Most CMS alert Google to come check out your sitemap
file, but here's a Rake task to do it yourself.
{: .leader }

This site is generated using Jekyll, a static website generator. I've got [a
sitemap file set up][1] to include links to all my pages and posts. All I need
now is to tell Google the file has changed -- and do that every time I push
changes to my server.

## Rake to the rescue

I've set up the following Rake task to handle pinging Google for me:

{:.ruby}
    desc 'Notify Google of the new sitemap'
    task :sitemap do
        require 'net/http'
        require 'uri'
        Net::HTTP.get(
            'www.google.com',
            '/webmasters/tools/ping?sitemap=' +
            URI.escape('http://domain.com/sitemap.xml')
        )
      end
    end

Running `rake sitemap` is now enough to let Google know that my sitemap has
changed. I have chained this task in my publication process, so that every
time I run `rake publish` my site will be re-generated and published, and
Google will be notified.

I've also set up a task to ping [ping-o-matic][2]. You see
[my entire `Rakefile` at Github][3].

*[XML]: eXtensible Markup Language
*[CMS]: Content Management System

[1]: http://github.com/avdgaag/arjanvandergaag.nl/blob/cbc47e03d4cf766278f2982bfe79862cb251fd34/sitemap.xml "View my sitemap file on Github"
[2]: http://pingomatic.com/ "Ping-o-Matic pings a lot of services for you"
[3]: http://github.com/avdgaag/arjanvandergaag.nl/blob/28539bc736a05b28f2aa4ef81e4f61f3f91375a0/Rakefile "See my project's Rakefile"