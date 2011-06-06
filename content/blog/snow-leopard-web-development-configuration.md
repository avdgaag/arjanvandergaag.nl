---
tags:
  - apache
  - osx
  - development
created_at: 2009-08-29 12:20
kind: article
title: Snow Leopard web developemnt configuration
---
After installing Snow Leopard on my iMac I found I had to tweak some settings before I could continue my daily web development workflow. First, you should note Snow Leopard now comes with PHP 5.3 and it will overwrite your custom Apache configuration.

Here's what I did to get up and running:

1. Moved `/etc/php.ini.default` to `/etc/php.ini`.
2. Edited `php.ini` (using search/replace) so that `display_errors = On` and `mysql.default_port = /tmp/mysql.sock`.
3. I also set a default timezone (search `php.ini` for 'timezone') to suppress warnings about server timezone being unreliable.
4. Restored my `vhosts.conf` file from a back-up to bring back my various *.dev virtual hosts.
5. I replaced all my PHP short tags with their longer equivalents (`<?=` to `<?php echo`) as these are deprecated in PHP 5.3.

After these rather simple steps I was back up and running, although they took a a little time and googling. Overall, I was surprised how little installing Snow Leopard messed up my system.