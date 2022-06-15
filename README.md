# Auto-M4B
This container is mostly based on the powerful [m4b-tool](https://github.com/sandreas/m4b-tool) made by sandreas  
This repo is my fork of the fantastic [docker-m4b-tool](https://github.com/9Mad-Max5/docker-m4b-tool) created by 9Mad-Max5. 

This is a docker container that will watch a folder for new books, auto convert mp3 books to chapterized m4b, and move all m4b books to a specific output folder, this output folder is where the [beets.io audible plugin](https://github.com/seanap/beets-audible) will look for audiobooks and use the audible api to perfectly tag and organize your books.

## Intended Use
This is meant to be an automated step between aquisition and tagging.
* Install via docker-compose 
* Save new audiobooks to a /recentlyadded folder.
* All multifile m4b/mp3/m4a/ogg books will be converted to a chapterized m4b and saved to an /untagged folder  
* This script will watch `/temp/recentlyadded` and automatically move mp3 books to `/temp/merge`, then automatically put all m4b's in the output folder `/temp/untagged`.  It also makes a backup incase something goes wrong.

Use the [beets.io audible plugin](https://github.com/seanap/beets-audible) to finish the tagging and sorting.

## Known Limitations

* The chapters are based on the mp3 tracks. A single mp3 file will become a single m4b with 1 chapter, also if the mp3 filenames are garbarge then your m4b chapternames will be terrible as well.  See section on Chapters below for how to manually adjust.
* Right now book folders with nested subfolders will be moved to a /fix folder for manual filename/folder fixing.  It should be possible to modify the auto-m4b-tool.sh script to automatically prefix the subfoldername and move the files up a level, let me know if you know how to do this.
* There's no options or config file.  Things like cpu cores, the actual m4b-tool run command, and directories would be nice to have in a config file.  Right now it runs like a black box (tho default settings should be all you need).
* The conversion process actually strips some tags and covers from the files, which is why you need to use a tagger (mp3tag or beets.io) before adding to Plex.


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

### Installation

1. Creat a `temp` folder, and create all the sub folders `recentlyadded`, `merge`, `untagged`, `delete`, `fix`, `backup` like above
2. Install docker https://docs.docker.com/engine/install/ubuntu/
3. Manage docker as non-root https://docs.docker.com/engine/install/linux-postinstall/
4. Install docker-compose https://docs.docker.com/compose/install/
5. Create the compose file:  
    `nano docker-compose.yml`
6. Paste the yaml code below into the compose file, and change the volume mount locations
7. Put a test mp3 in the /temp/recentlyadded directory.
8. Start the docker (It should convert the mp3 and leave it in your /temp/untagged directory. It runs automatically every 5 min)  
    `docker-compose up -d`
### Example docker-compose.yml
*  Replace the `/path/to/...` with your actual folder locations, but leave the `:` and everything after:  
*  Replace the PUID and PGID with your user ( [?](https://www.carnaghan.com/knowledge-base/how-to-find-your-uiduserid-and-gidgroupid-in-linux-via-the-command-line/) )
#### docker-compose.yml
```yaml
version: '3.7'
services:
  auto-m4b:
    image: seanap/auto-m4b
    container_name: auto-m4b
    volumes:
      - /path/to/config:/config
      - /path/to/temp:/temp
    environment:
      - PUID=1000
      - PGID=1000
      - CPU_CORES=2
```

## To Manually Set Chapters:
1. Put a folder with mp3's in the `/temp/recentlyadded` and let the script process the book like normal
2. In the output folder ( `/temp/untagged` ) there will be a book folder that includes the recently converted *.m4b and a *.chapters.txt file.
3. Open the chapters file and edit/add/rename, then save
4. Move the book folder (which contains the m4b and chapters.txt files) to `/temp/merge`
5. When the script runs it will re-chapterize the m4b and move it back to `/temp/untagged`

## Advanced Options
You shouldn't need to change any options, but if you want to you will need to exec into the docker container. By default only vim text editor is installed, you will need to do a `apt-get update && apt-get install nano` if you want to use nano to edit the scipt.  
* `docker exec -it auto-m4b sh -c 'vi auto-m4b-tool.sh'`  

The script will automatically use all CPU cores available, to change the amount of cpu cores for the converting change the `--jobs` flag in the m4b-tool command, but do not set it higher than the amount of cores available.  

More m4b-tool options https://github.com/sandreas/m4b-tool#reference
