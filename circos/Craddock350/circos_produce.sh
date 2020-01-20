#!/bin/bash


for file in $(find ./ -name "*Craddock350.links.txt"); do
	echo $file
	name=$(echo $file | cut -d'-' -f 1)
	name2="${name:12:2}"
	name3=$(echo "Craddock350_$name2.svg")
	#echo $name3
	command=$(perl parsemap -map map_Power.txt -links $file);
	
	sed -i -e 's/-r//g' ./data/links.txt
	cp segment.order.conf ./etc/segment.order.conf
	cp segments.txt ./data/segments.txt
	cp structure.label.txt ./data/structure.label.txt
	circos
	command2=$(mv circos.svg $name3);
	eval $command2
done
