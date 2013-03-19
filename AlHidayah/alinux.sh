#!/bin/bash
/usr/bin/rsync -avz --delete dhanuxe@ssi.alinux.web.id:~/www/alinux/ /home/deanet/www/alinux/
/usr/bin/rsync -avz --delete /home/deanet/www/alinux/ deanet@nabawiy.com:~/www/alinux/
