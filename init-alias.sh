#!/bin/bash
file=~/.bash_aliases

echo "alias home='cd ~'" >> $file
echo "alias ealias='vi ~/.bash_aliases'" >> $file
echo "alias ra='. ~/.bash_aliases'" >> $file

. ~/.bashrc
