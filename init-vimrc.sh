#!/bin/bash
file=~/.vimrc
echo set nocompatible >> $file
echo set number >> $file
echo set tabstop=3 >> $file
echo set softtabstop=3 >> $file
echo set expandtab >> $file
echo set autoindent >> $file

