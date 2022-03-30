#!/bin/bash
# set n to 1
n=1
# variable defenition
inputfolder="/temp/mp3merge/"
outputfolder="/temp/untagged/"
originalfolder="/temp/recentlyadded/"
backupfolder="/temp/backup/"
binfolder="/temp/delete/"
m4bend=".m4b"
logend=".log"

#change to the merge folder, keeps this clear and the script could be kept inside the container
cd "$inputfolder" || return

# continue until $n  5
while [ $n -ge 0 ]; do

	#make sure all single file mp3's & m4b's are in their own folder
	echo "Making sure all books are in their own folder"
	for file in $originalfolder*.{m4b,mp3}; do
		if [[ -f "$file" ]]; then
			mkdir "${file%.*}"
			mv "$file" "${file%.*}"
		fi
	done

	echo "Read the mp3 files for movement."
	readarray -d '' songfile < <(find "$originalfolder" -type f -iname \*.mp3 -print0)
	IFS='/' read -r -a parts <<<"${songfile[0]}"

	echo "Making a backup of the whole input/original folder."
	#copy files to backup destination 
	cp -Ru "$originalfolder"* $backupfolder

	#Calculating the place bookfolder for mp3s
	len=${#parts[@]}
	lenpath=$len-1

	#Moving the first book to the merge directory
	echo "Moving ${parts[lenpath]} to merge it."
	bookpath=${songfile/"${parts[lenpath]}"}
	mv "$bookpath" $inputfolder

	#Moving the m4b files to the untagged folder as no Merge needed
	echo "Moving all the m4b books to untagged."
	find "$originalfolder" -type f \( -iname \*.m4b -o -iname \*.mp4 -o -iname \*.m4a -o -iname \*.ogg \) -exec mv -f "{}" "$outputfolder" \;

	# clear the folders
	rm -r "$binfolder"* 2>/dev/null
	find "$originalfolder"* -type f -size -200k -delete
	find "$originalfolder"* -type d -exec rmdir {} + 2>/dev/null

	if ls -d */ 2>/dev/null; then
		echo Folder Detected
		for book in *; do
			if [ -d "$book" ]; then
				mpthree=$(find "$book" -maxdepth 2 -type f -name "*.mp3" | head -n 1)
				m4bfile=$outputfolder$book$m4bend
				logfile=$outputfolder$book$logend
				echo Sampling $mpthree
				bit=$(ffprobe -hide_banner -loglevel 0 -of flat -i "$mpthree" -select_streams a -show_entries format=bit_rate -of default=noprint_wrappers=1:nokey=1)
				echo Bitrate = $bit
				echo The folder "$book" will be merged to "$m4bfile"
				echo Starting Conversion
				m4b-tool merge "$book" -n -q --audio-bitrate="$bit" --skip-cover --use-filenames-as-chapters --audio-codec=libfdk_aac --jobs=4 --output-file="$m4bfile" --logfile="$logfile"
				mv "$inputfolder""$book" "$binfolder"
				mv "$outputfolder""$book".chapters.txt "$outputfolder"chapters
				echo Finished Converting
				echo Deleting duplicate mp3 audiobook folder
			fi
		done
	else
		echo No folders detected, next run 5min...
		sleep 5m
	fi
done
