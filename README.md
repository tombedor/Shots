this should work: 

https://marcelog.github.io/articles/static_sox_transcoding_lambda_mp3.html

sox inside a lambda



# docker sox works:
docker run -v ~/projects/Shots/docker:/mnt/ -it bigpapoo/sox /bin/bash

need now to publish this image to aws and use ECR to be able to call it

ECr troubleshooting https://us-west-2.console.aws.amazon.com/ecr/repositories/party-jams-dot-biz/?region=us-west-2
