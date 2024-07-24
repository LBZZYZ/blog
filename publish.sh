#!bin/bash

rm ./blog.tar
rm -rf ./public
hugo --theme=typo --baseURL="https://www.libingzhi.top/" --buildDrafts
tar -cvf blog.tar ./public/
scp blog.tar simon@119.23.255.199:/home/simon
ssh simon@119.23.255.199 "sh /home/simon/blog.sh"
rm ./blog.tar
rm -rf ./public