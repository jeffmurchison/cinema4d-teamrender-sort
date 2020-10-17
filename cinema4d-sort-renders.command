#!/bin/zsh

# Script Name: cinema4d-sort-renders.sh
# Author: Jeff Murchison
# Description: Cinema4D's Teamrender likes to render all frames from every pass to a single folder, instead of separating them
# into individual folders so this script takes care of sorting the rendered files into individual folders based on the pass name.
#
# Contact: jeff@jeffmurchison.com
# Date: October 15, 2020
# Version: 0.1
#
# License:
# This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
# http://creativecommons.org/licenses/by-nc-sa/3.0/

directoryCheck() {
	# check if the folder is a directory / exists
	if [[ ! -d "$1" ]]; then
		echo -e "ERROR: $2 directory doesn't exist!\n"
		if [[ $2 == "Source" ]]; then
			sourceDir=""
		elif [[ $2 == "Destination" ]]; then
			destDir=""
		fi
	else
		# find directories and warn
		if [[ `find $1 -type d -maxdepth 1 -mindepth 1` ]]; then
			echo "Found directories in $2 directory - double check that you have the correct"
			echo "source folder before continuing. Press Return to continue or"
			echo "Control + C to exit."
			read continue
		fi
	fi
}

set -e
clear

echo " "
echo " --------------------------------------"
echo "|  Cinema4D TeamRender Results Sorter  |"
echo " --------------------------------------"
echo " "
echo "This script currently supports the following naming format:"
echo " "
echo "       [example_project]_[passname][framenumber].[extension]"
echo " "
echo "You will now be prompted for the folder path of the source directory which "
echo "contains the results you wish to sort, and then you will be prompted for "
echo "the folder path of the directory you wish to move the sorted results to. "
echo "If left blank, the results will be sorted and left in the source folder."
echo " "
echo "To get the folder paths, you can select the folder in Finder and press "
echo "Command + Option + C to copy it to the clipboard and then paste it here, "
echo "or you can drag the folder from Finder into this window."
echo " "
echo "Press Control + C to exit. Press Return to continue."

# prompt the user to enter the source folder
read continue
echo -e "-------------------------------------------------------------------\n"

while [[ $sourceDir == "" ]]; do
	# prompt the user to enter the source folder
	echo "Please enter the folder path of the results folder:"
	read sourceDir

	# ensure the source directory isn't blank
	if [[ $sourceDir == "" ]]; then
		echo -e "ERROR: Source directory cannot be blank!\n"
	else
		directoryCheck $sourceDir "Source"
	fi
done

while [[ $destDir == "" ]]; do
	# prompt the user to enter the destination folder
	echo -e "\nPlease enter the folder path of the folder you wish to move the files to"
	echo "or hit Return to sort them in their source folder:"
	read destDir

	# if the destination directory is blank, just sort the files in the source directory
	if [[ $destDir == "" ]]; then
		destDir=$sourceDir
	else
		directoryCheck $destDir "Destination"
	fi
done

# handle all files in the source directory
cd "$sourceDir"
for files in *; do
	# remove file extension and the frame number to get the folder name each file will be sorted into
	name=`echo "$files" | sed -e 's/\.[^./]*$//' -e 's/[0-9]*$//'`
	# if the last character is an underscore, remove it (for objects/beauty pass)
	if [[ "$name" =~ '_'$ ]]; then
  		name=`echo "$name" | sed -e 's/.$//' `
	fi
  dir="$destDir/$name"
	# echo $name
  mkdir -p "$dir"
  mv -v "$files" "$dir"
done
