---
title: Why I don't need Alfred App
kind: article
tags: [productivity, software]
created_at: 2011-05-24 11:00
tldr: I use global keyboard shortcuts in a bunch of other apps, so I have no need for a dedicated utility like Alfred, Quicksilver or Launchbar.
---
"Install [Quicksilver][]" was the first advice many people gave me when I first switched to a Mac. These days it's [Launchbar][] or [Alfred][]. These applications are supposedly critical for Mac power users, so I tried them all. But I use none of them.
{: .leader }
 
![Alfred quick web search](/assets/images/alfred.jpg){: .photo .right .pull }

Let's focus on [Alfred][] as an example. It's a productivity application that lets you open a command prompt with a global keyboard shortcut, so you can type commands to open files, browse the web, control iTunes and so on. It looks nice, is light-weight and works as advertised.

I have installed it several times, but never actually used it. Not because I don't need to perform these tasks, nor because I don't care about speed or prefer to use the mouse. But I've got other, dedicated services set up to handle this stuff for me. And they simple work better for me.

## My global keyboard shortcuts setup

### Spotlight

![Spotlight folder search](/assets/images/spotlight.png){: .photo .right .pull }

I use Mac OS X's own Spotlight feature both for file search and as an application launcher. It is both quick and accurate enough, assuming I use keyword-based search filters. It is quickly activated with `⌘ Space` or `⌘⌥ Space` for expanded mode.

These are my most used filters:

* `kind:folder [name]` to jump to a folder buried deeply somewhere on my filesystem;
* `kind:contact [name]` to look up information from my address book
* `kind:message [...]` to look for Mail messages
* `define:word` to look up "word" in the dictionary.

I also often use the `⌘↵` shortcut for opening the enclosing folder of a found item, rather than the item itself.

When I am looking for preference panes or just applications, I just start typing its name. Since I launch the same apps often, it usually gets it right after one or two characters.

### CoverSutra

![CoverSutra album search](/assets/images/coversutra.png){: .photo .right .pull }

I use [CoverSutra][] to control iTunes and search my iTunes library. I have set up `⌘~` to activate the search box, in which I can use tab to filter my search results to artists, albums or songs.

I still very much prefer to browse my music collection in iTunes itself -- it's easier to visually browse album covers when you haven't decided yet what you want to listen to. But when I have a particular track or album in mind, I use CoverSutra to queue it.

### Adding To Do items

I am a big fan of [Things][] as my To Do application, and I've got two keyboard shortcuts set up for quickly adding new items to my inbox. I most often use `⌃⌥ Space` for adding a new, blank item; every so often I use `⌃⇧⌥ Space` for creating a new item based on my current context.

The latter is especially useful when going through mail: having a message selected, invoking the autofill shortcut for Things will pre-populate the new item dialog with a reference to the message, any selected text and the message subject. Awesome.

### Events

![Adding event with Fantastical](/assets/images/fantastical.png){: .photo .right .pull }

I recently started using [Fantastical][], which is a wonderful little app that you can use to manage your iCal calendars. After invocation with `⌃⇧ Space` you can enter your appointment details using natural language, which Fantastical will parse and add to your calendar for you.

I am not a heavy calendar user, but this one is just too much fun to _not_ use.

### Terminal

I spend a lot of time in the terminal, so I want to be able to quickly get to my command prompt. I have installed the [Visor][] SIMBL plugin that allows me to show and hide my terminal window using a global keyboard shortcut -- with a fancy animation!

I use `⌘§` to toggle the terminal window on or off.

### Other stuff

Here are some other commonly used operations that I do not need Alfred for:

* Quickly opening a folder in the Finder: Mac OS X comes with `⌘G` for that. Works with autocomplation.
* Quickly opening a web address: I just use `⌘ Tab` and then `⌘L` to open a new Safari window with the focus on the address bar. Using `⌘⌥F` focuses on the search box.
* Searching other services: I use [GlimmerBlocker][] that sets up nice URL rewriting for me, so I can type `imdb robocop` in the address bar to quickly look up Robocop on IMDb.com.
* Calculate and spell: Spotlight already does that. Also, using `⌃⌘D` on any word in Mac OS X, in any app, will invoke a Dictionary pop-up.

## One shortcut to rule them all?

There is a case to be made that having a single global keyboard shortcut to do all this stuff is more efficient than setting up all these others. On the other hand, a single, unified interface to these vastly different services is bound to be less efficient than a dedicated one.

Moreover, there is the matter of clutter: of course, using _only_ Alfred would be neat. But Alfred does not _replace_ these other apps, it just _adds to_ them. So when you've got the others running anyway, you might as well use them, rather than adding yet another background application.

That's about enough writing about productivity, now it's time to get back to work.

[Alfred]:         http://alfredapp.com
[Quicksilver]:    http://qsapp.com/
[Launchbar]:      http://www.obdev.at/products/launchbar/index.html
[CoverSutra]:     http://sophiestication.com/coversutra/
[Things]:         http://culturedcode.com/things
[Visor]:          http://visor.binaryage.com/
[GlimmerBlocker]: http://glimmerblocker.org/
[Fantastical]:    http://flexibits.com/fantastical

