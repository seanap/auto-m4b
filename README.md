# Auto-M4B
This container is mostly based on the powerful [m4b-tool](https://github.com/sandreas/m4b-tool) made by sandreas
This repo is my fork of the fantastic [docker-m4b-tool](https://github.com/9Mad-Max5/docker-m4b-tool) created by 9Mad-Max5. 

This is a docker container that will watch a folder for new books, auto convert mp3 books to chapterized m4b, and move all m4b books to a specific output folder, this output folder is where the [beets.io audible plugin](https://github.com/seanap/beets-audible) will look for audiobooks and use the audible api to perfectly tag and organize your books.

## Intended Use
This docker assumes all untagged books (mp3 & m4b) start their journey in a "recentlyadded" folder.  Every 5min this will monitor that "recentlyadded" folder for mp3 books, then automatically convert them to a chapterized m4b.  The chapters are based on the mp3 tracks. Then it will output all m4b books to a specific output folder where they wait to be tagged. This fork is intended to work seamlessly with my fork of the audible beets.io plugin https://github.com/seanap/beets-audible

## Using torrents and need to preserve seeding?
In the settings of your client add this line to `Run external program on torrent completion`, it will copy all finished torrent files to your "recentlyadded" folder:
* `cp -r "%F" "path/to/temp/recentlyadded"`

## How to use
This docker assumes the following folder structure:

<pre>
<b>temp</b>
│
└───<b>recentlyadded</b> # Input folder Add new books here
│   │     book1.m4b
│   |     book2.mp3
|   └─────book3
│         │   01-book3.mp3
│         │   ... 
└───<b>mp3merge</b> # folder the script uses to combine mp3's
│   └─────book2
│         │   01-book2.mp3
│         │   ...
│   └─────book3
│         │   01-book3.mp3
│         │   ...
└───<b>untagged</b> # Output folder where all m4b's wait to be tagged
│   └─────book4
│         │   book4.m4b
└───<b>delete</b> # needed by the script
|
└───<b>backup</b> # Backups incase anything goes wrong
    └─────book2
          │   01-book2.mp3
          │   ... 
    └─────book3
          │   01-book3.mp3
          │   ...
</pre>

This script will watch `/temp/recentlyadded` and automatically move mp3 books to `/temp/mp3merge`, then automatically put all m4b's in the output folder `/temp/untagged`.  It also makes a backup incase something goes wrong.

## Set up the Container

### docker-compose.yml
~~~
version: '3.7'
services:
  auto-m4b:
    image: seanap/auto-m4b
    container_name: auto-m4b
    volumes:
      - /path/to/config:/config
      - /path/to/temp:/temp
~~~
