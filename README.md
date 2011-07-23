Malm
====
Easy SMTP server for local development
--------------------------------------
Malm is a super simple SMTP trap that will catch everything sent to it, not forward it on, but instead display on a local web server.

This is useful for when you're doing local development that requires your app to send mail, but you don't want to go through all the hassle of setting up a full featured mail server (and then pointing your mail client at it).

Install
-------
    gem install malm

Basic Usage
-----------
The following command starts Malm up. Running on it's defaults of listening for SMTP on port 2525, client web app running on port 4567, and starting as a process in the foreground

    malm

If you want to start up on regular SMTP port 25, you'll probably need to run it as sudo

    sudo malm -p 25

For more info try

    sudo malm --help

Viewing Messages
----------------
Once it's up and running, it works just like any other SMTP server - your app sends it mail, then happily goes about it's business. To view the mail messages Malm has picked up, point your web browser at [http://localhost:4567](http://localhost:4567)

Who the hell?
-------------
I blame [@madlep](https://twitter.com/#!/madlep)

Contributing
------------
Fork + pull request. Nice and easy.