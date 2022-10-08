find /PATH/TO/temp/untagged/ -mindepth 1 -type d -prune -exec sh -c '[ $(du -s "$1" | awk "{print \$1}") -lt 1000 ] && rm -Rf "$1"' _ {} \;
