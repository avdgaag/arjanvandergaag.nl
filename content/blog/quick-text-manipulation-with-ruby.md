---
created_at: 2010-6-21 18:18
tags:
  - code
  - ruby
kind: article
title: Quick text manipulation with Ruby
---
Here's a nice trick I like to use to quickly transform some random piece of text using Ruby and Textmate:

{: .ruby }
    string = DATA.read
    # do stuff here...
    __END__
    Text to transform goes here

By using the `__END__` line you tell Ruby to not executre all that follows, but capture it in an `IO` which you can read. You can then quickly whip up a script and have Textmate run it using  ⌘R. The script's output can then be copied and pasted.

I use this all the time to transform plain text into HTML, crunch some numbers or filter some text. Think of it as a 'filter through command' (⌥⌘R) on steroids.

Here's a quick example to convert ugly plain-text fractions in an HTML page to pretty entities:

{: .ruby }
    input = DATA.read
    {
      '1/2' => '&frac12;',
      '1/4' => '&frac14;',
      '3/4' => '&frac34;'
    }.each_pair do |plain_text, html_entity|
      input.gsub!(/\b#{plain_text}\b/, html_entity)
    end
    puts input
    __END__
    1/2 an egg and 1/4 pint of milk