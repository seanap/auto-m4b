#!/bin/bash
# set m to 1
m=1
#variable defenition
inputfolder="${INPUT_FOLDER:-"/temp/merge/"}"
outputfolder="${OUTPUT_FOLDER:-"/temp/untagged/"}"
originalfolder="${ORIGINAL_FOLDER:-"/temp/recentlyadded/"}"
fixitfolder="${FIXIT_FOLDER:-"/temp/fix"}"
backupfolder="${BACKUP_FOLDER:-"/temp/backup/"}"
binfolder="${BIN_FOLDER:-"/temp/delete/"}"
m4bend=".m4b"
logend=".log"

#ensure the expected folder-structure
mkdir -p "$inputfolder"
mkdir -p "$outputfolder"
mkdir -p "$originalfolder"
mkdir -p "$fixitfolder"
mkdir -p "$backupfolder"
mkdir -p "$binfolder"

#fix of the user for the new created folders
username="$(whoami)"
userid="$(id -u $username)"
groupid="$(id -g $username)"
chown -R $userid:$groupid /temp 

#adjust the number of cores depending on the ENV CPU_CORES
if [ -z "$CPU_CORES" ]
then
      echo "Using all CPU cores as not other defined."
	  CPUcores=$(nproc --all)
else
      echo "Using $CPU_CORES CPU cores as defined."
	  CPUcores="$CPU_CORES"
fi

#adjust the interval of the runs depending on the ENV SLEEPTIME
if [ -z "$SLEEPTIME" ]
then
      echo "Using standard 1 min sleep time."
	  sleeptime=1m
else
      echo "Using $SLEEPTIME min sleep time."
	  sleeptime="$SLEEPTIME"
fi

#change to the merge folder, keeps this clear and the script could be kept inside the container
cd "$inputfolder" || return

# continue until $m  5
while [ $m -ge 0 ]; do

	#copy files to backup destination
	if [ "$MAKE_BACKUP" == "N" ]; then
		echo "Skipping making a backup"
	else
		echo "Making a backup of the whole $originalfolder"
		cp -Ru "$originalfolder"* $backupfolder
	fi

	#make sure all single file mp3's & m4b's are in their own folder
	echo "Making sure all books are in their own folder"
	for file in "$originalfolder"*.{m4b,mp3}; do
		if [[ -f "$file" ]]; then
			mkdir "${file%.*}"
			mv "$file" "${file%.*}"
		fi
	done

	#Move folders with multiple audiofiles to inputfolder
	echo "Moving folders with 2 or more audiofiles to $inputfolder "
	find "$originalfolder" -maxdepth 2 -mindepth 2 -type f \( -name '*.mp3' -o -name '*.m4b' -o -name '*.m4a' \) -print0 | xargs -0 -L 1 dirname | sort | uniq -c | grep -E -v '^ *1 ' | sed 's/^ *[0-9]* //' | while read i; do mv -v "$i" $inputfolder; done

	#Move folders with nested subfolders to fixitfolder for manual fixing
	echo "Nested subfolders are BAD moving to $fixitfolder"
	find "$originalfolder" -maxdepth 3 -mindepth 3 -type f \( -name '*.mp3' -o -name '*.m4b' -o -name '*.m4a' \) -exec sh -c '
		for f do
			gp="$(basename "$(dirname "$(dirname "$f")")")"
			printf "%s\n" "$gp"
		done
	' sh-find {} + | sort | uniq -d | while read j; do mv -v "$originalfolder$j" $fixitfolder; done

	#Move single file mp3's to inputfolder
	echo "Moving single file mp3's to $inputfolder "
	find "$originalfolder" -maxdepth 2 -type f \( -name '*.mp3' \) -printf "%h\0" | xargs -0 mv -t "$inputfolder"

	#Moving the single m4b files to the untagged folder as no Merge needed
	echo "Moving all the single m4b books to $outputfolder "
	find "$originalfolder" -maxdepth 2 -type f \( -iname \*.m4b -o -iname \*.mp4 -o -iname \*.m4a -o -iname \*.ogg \) -printf "%h\0" | xargs -0 mv -t "$outputfolder"

	# clear the folders
	rm -r "$binfolder"* 2>/dev/null

	if ls -d */ 2>/dev/null; then
		echo Folder Detected
		for book in *; do
			if [ -d "$book" ]; then
				mpthree=$(find "$book" -maxdepth 2 -type f \( -name '*.mp3' -o -name '*.m4b' \) | head -n 1)
				m4bfile="$outputfolder$book/$book$m4bend"
				logfile="$outputfolder$book/$book$logend"
				chapters=$(ls "$inputfolder$book"/*chapters.txt 2> /dev/null | wc -l)
				if [ "$chapters" != "0" ]; then
				        echo "Merging chapters file found in directory named "$book" into media file."
          				mp4chaps -i "$inputfolder$book"/*$m4bend
					mv "$inputfolder$book" "$outputfolder"
				else
					echo Sampling $mpthree
					bit=$(ffprobe -hide_banner -loglevel 0 -of flat -i "$mpthree" -select_streams a -show_entries format=bit_rate -of default=noprint_wrappers=1:nokey=1)
					echo Bitrate = $bit
					echo The folder "$book" will be merged to "$m4bfile"
					echo Starting Conversion
					m4b-tool merge "$book" -n -q --audio-bitrate="$bit" --skip-cover --use-filenames-as-chapters --no-chapter-reindexing --audio-codec=libfdk_aac --jobs="$CPUcores" --output-file="$m4bfile" --logfile="$logfile"
					mv "$inputfolder$book" "$binfolder"
				fi
				echo Finished Converting
				#make sure all single file m4b's are in their own folder
				echo Putting the m4b into a folder
				for file in $outputfolder*.m4b; do
					if [[ -f "$file" ]]; then
						mkdir "${file%.*}"
						mv "$file" "${file%.*}"
					fi
				done
				echo Deleting duplicate mp3 audiobook folder
			fi
		done
	else
		echo No folders detected, next run $sleeptime min...
		sleep $sleeptime
	fi
done
