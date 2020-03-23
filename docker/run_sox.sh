ocker run -v ~/projects/Shots/docker:/mnt/ -it bigpapoo/sox /bin/bash
# inside container
sox /mnt/0.aiff /mnt/0_slow.aiff tempo 0.5

