#!/bin/bash

#. ../mml.cfg

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



