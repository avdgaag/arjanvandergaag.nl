---
created_at: 2010-03-10 10:33
tags:
  - sysadmin
  - apache
kind: article
title: Test Apache configuration syntax
---
Recently my Mac OS X stock install of Apache failed to launch properly. The regular system preferences interface stopped and started Web Sharing without complaining, but I could not find `httpd` actually running using `ps -ax | grep httpd` in the terminal.

I was at a loss to explain why, until I found this little gem that you can use to syntax-test your configuration files with: `apachectl -t` will report on any errors in httpd.conf or any of your other included files.

It appeared that some time ago when I was attempting a manual upgrade of my Subversion install to 1.6.9 some Apache modules were corrupted. As I have no use for them I disabled them.

That did the trick, and now I've got my local development environment up and running again.