# Geographical Coordinate Converter

This is a JavaScript based application using the AngulerJS web application
framework.

It parses free text input, converting to and from the following formats:

- latitude/longitude decimal degrees
- latitude/longitude degrees with decimal minutes
- latitude/longitude degrees, minutes and seconds
- [OpenLocationCode][olc] a.k.a. Plus Codes
- Ordnance Survey GB 1936 (British National Grid)
- Irish Grid
- Irish Transverse Mercator

[olc]: https://en.wikipedia.org/wiki/Open_Location_Code
[trip-web-client]: https://github.com/frankdean/trip-web-client

## Docker

The application can be run in Docker as follows:

	$ docker run --name convert-coord --publish 8000:80 \
	-d fdean/convert-coord:latest

Stop the container with:

	$ docker container stop convert-coord

Start the container with:

	$ docker container rm convert-coord

It is also possible to develop the application using a Docker
container, by working in the directory containing the current source
code, and peforming a bind mount of the source folder with the
`/webapp` folder in the container.

**Note:** the container will already have a copy of the source code in
the `/webapp` folder.  The bind mount will bind over that folder,
hiding its contents with the current source directory on the host
machine.

To build a new container:

	$ docker build  -f Dockerfile-dev -t convert-coord-dev docker .

To run the container, and mount the current directory at `/webapp`:

	$ docker run --name convert-coord-dev -e CHROME_BIN=/usr/bin/chromium \
	--mount type=bind,source="$(pwd)",target=/webapp \
	--shm-size=128m --publish 8000:8000 -d convert-coord

To start and connect to a Bash shell in the running container:

	$ docker exec -it convert-coord-dev bash -il

Then, in the container, run the tests:

	$ cd /webapp
	$ yarn
	$ yarn run lint
	$ yarn run test-single-run
	$ yarn run protractor

Alternatively, run the test directly from the host:

	$ docker exec -it -w /webapp convert-coord-dev yarn run test-single-run
