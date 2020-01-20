#!/bin/bash


for file in $(find ./ -name "*Brainnetome.links_AFNI.txt"); do
	echo $file
	name=$(echo $file | cut -d'-' -f 1)
	name2="${name:6:2}"
	name3=$(echo "Brainnetome_AFNI_$name2.svg")
	command=$(perl parsemap -map map_Power_solid.txt -links $file);
	eval $command
	circos
	command2=$(mv circos.svg $name3);
	eval $command2
done
