#!/bin/bash
file=~/.vimrc
echo set nocompatible >> $file
echo set number >> $file
echo set noexpandtab >> $file
echo set smartindent >> $file
echo set shiftround >> $file
echo set autoindent >> $file
echo let s:tabwidth=3 >> $file
echo "exec 'set tabstop='    .s:tabwidth" >> $file
echo "exec 'set shiftwidth=' .s:tabwidth" >> $file
echo "exec 'set softtabstop='.s:tabwidth" >> $file
