#!/bin/bash


#init config
. $(ls /etc/mml/mml.cfg ~/mml/mml.cfg /opt/mml.cfg ../mml.cfg 2> /dev/null  | cut -f 1)
. $mml_work/scripts/_functions.sh


for templdir in `find $mml_work/templates -type d`
do 
	echo mkdir -p $templdir | sed s,templates,puppet,g |bash
done

for templpath in `find $mml_work/templates -type f | egrep -v "(*.sh$|*.swp$)" `
do
	realpath=$(echo $templpath | sed s,templates,puppet,g)
	cat $templpath | \
		sed "s,__MML_WORK__,$mml_work,g" | \
		sed "s,__MML_OPT__,$mml_opt,g" | \
		sed "s,/\+,\/,g"  > $realpath
done



