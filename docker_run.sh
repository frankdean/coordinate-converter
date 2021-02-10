#/bin/sh
# Run on Docker [play][] with:
#
# docker run --publish 8000:80 -d fdean/convert-coord:latest
#
# [play]: https://labs.play-with-docker.com "Play with Docker"
#
# Run locally with:
sudo docker container run --publish 8000:80 --name cc -d fdean/convert-coord:latest
sudo docker exec -it cc ls -l /usr/share/nginx/html/
