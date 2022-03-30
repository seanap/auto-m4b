# Auto-M4B-Tool
This container is mostly based on the powerful m4b-tool made by sandreas
https://github.com/sandreas/m4b-tool
This repo is my fork of the fantastic docker-m4b-tool created by 9Mad-Max5 https://github.com/9Mad-Max5/docker-m4b-tool.  

The differences between this fork and 9Mad-Max5's are subtle; I have cleaned up the temp folders needed, and I've added a few lines to make sure all single file books are put inside their own folder. This is important for integration with the Audible Beets.io plug-in https://github.com/Neurrone/beets-audible

## Intended Use
This docker assumes all untagged books (mp3 & m4b) start their journey in a "recentlyadded" folder.  Every 5min this will monitor that "recentlyadded" folder for mp3 books, then automatically convert them to a chapterized m4b.  The chapters are based on the mp3 tracks. Then it will output all m4b books to a specific output folder where they wait to be tagged. This fork is intended to work seamlessly with my fork of the audible beets.io plugin https://github.com/seanap/beets-audible

This is NOT needed if:
* All your books are already m4b
* You actually want mp3's

Using torrents and need to preserve seeding?
* In the settings of your client add this line to "Run external program on torrent completion"
  * `cp -r "%F" "path/to/temp/recentlyadded"`

## How to use
This docker assumes the following folder structure:

```
temp   
│
└───recentlyadded
│   │   book1.m4b
│   |   book2.mp3
|   └───book3
│       │   01-book3.mp3
│       │   ... 
└───mp3merge
│   └───book2
│       │   01-book2.mp3
│       │   ...
│   └───book3
│       │   01-book3.mp3
│       │   ...
└──-untagged
│   └───book4
│       │   book4.m4b
└───delete
|
└───backup
    └───book2
        │   01-book2.mp3
        │   ... 
    └───book3
        │   01-book3.mp3
        │   ...
```

This script will watch `/temp/recentlyadded` and automatically move mp3 books to `/temp/mp3merge`, and put all m4b's in the output folder `/temp/untagged`.  It also makes a backup incase something goes wrong.

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
