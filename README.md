# Auto-M4B
This container is mostly based on the powerful [m4b-tool](https://github.com/sandreas/m4b-tool) made by sandreas  
This repo is my fork of the fantastic [docker-m4b-tool](https://github.com/9Mad-Max5/docker-m4b-tool) created by 9Mad-Max5. 

This is a docker container that will watch a folder for new books, auto convert mp3 books to chapterized m4b, and move all m4b books to a specific output folder, this output folder is where the [beets.io audible plugin](https://github.com/seanap/beets-audible) will look for audiobooks and use the audible api to perfectly tag and organize your books.

## Intended Use
Install via docker-compose
This is meant to be an automated step between aquisition and tagging.
* Save new audiobooks to a /recentlyadded folder.
* All multifile m4b/mp3/m4a/ogg books will be converted to a chapterized m4b and saved to an /untagged folder  

Use the [beets.io audible plugin](https://github.com/seanap/beets-audible) to finish the tagging and sorting.

## Why

Single file books are much easier on your system, I've noticed significant improvements in windows file explorer, plex library refresh times, app library scroling, etc.  A lot of apps can choke on large number of files, this is an automated way to keep your filecount as low as possible.
The beets plugin requires all books files to be inside a folder.

## Known Limitations

* The chapters are based on the mp3 tracks. A single mp3 file will become a single m4b with 1 chapter, also if the mp3 filenames are garbarge then your m4b chapternames will be terrible as well.
* Right now book folders with nested subfolders will be moved to a /fix folder for manual filename/folder fixing.  It should be possible to modify the auto-m4b-tool.sh script to automatically prefix the subfoldername and move the files up a level, let me know if you know how to do this.
* There's no options or config file.  Things like cpu cores, the actual m4b-tool run command, and directories would be nice to have in a config file.  Right now it runs like a black box (tho default settings should be all you need).


## Using torrents and need to preserve seeding?
In the settings of your client add this line to `Run external program on torrent completion`, it will copy all finished torrent files to your "recentlyadded" folder:
* `cp -r "%F" "path/to/temp/recentlyadded"`

## How to use
This docker assumes the following folder structure:

```sh
temp
│
└───recentlyadded # Input folder Add new books here
│     │     book1.m4b
│     |     book2.mp3
|     └─────book3
│           │   01-book3.mp3
│           │   ... 
└───merge # folder the script uses to combine mp3's
│     └─────book2
│           │   01-book2.mp3
│           │   ...
└───untagged # Output folder where all m4b's wait to be tagged
│     └─────book4
│           │   book4.m4b
└───delete # needed by the script
|
└───fix # Manually fix books with nested folders
|
└───backup # Backups incase anything goes wrong
      └─────book2
            │   01-book2.mp3
            │   ... 
```

This script will watch `/temp/recentlyadded` and automatically move mp3 books to `/temp/merge`, then automatically put all m4b's in the output folder `/temp/untagged`.  It also makes a backup incase something goes wrong.

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
