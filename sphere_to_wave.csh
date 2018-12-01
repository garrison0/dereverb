#!/bin/csh 
set sphere_file = $1
set wave_file   = $2
set tmp_file    = $2.tmp

#set sphere_dir  = /data/work3/marc/REVERB_CHALLENGE/old/trunk/tools/SPHERE/nist/bin
set sphere_dir  = ./bin

#$sphere_dir/w_decode -f -o short_01 $sphere_file $tmp_file
$sphere_dir/w_decode -f -o pcm $sphere_file $tmp_file
$sphere_dir/h_strip $tmp_file $wave_file
rm -f $tmp_file
