# Geographical Coordinate Converter

This is a JavaScript application to convert between some common geographical
coordinate formats.

It parses free text input, converting to and from the following formats:

- latitude/longitude decimal degrees
- latitude/longitude degrees with decimal minutes
- latitude/longitude degrees, minutes and seconds
- [OpenLocationCode][olc] a.k.a. Plus Codes
- Ordnance Survey GB 1936 (British National Grid)
- Irish Grid
- Irish Transverse Mercator

[olc]: https://en.wikipedia.org/wiki/Open_Location_Code

## Using Play with Docker to Preview the Application

[play]: https://labs.play-with-docker.com "Play with Docker"

The application can be run in the [Play-with-docker][play] environment.

1.  Navigate to [Play with Docker][play] and login using a Docker ID.  If you
	do not have one, you will see the option to sign up after clicking `Login`
	then `Docker`.

1.  Click `+ ADD NEW INSTANCE`

1.  Run the container with:

		$ docker container run --publish 8080:80 --name cc -d fdean/convert-coord

1.  Once the application is running a link titled `8080` will be shown next to
    the `OPEN PORT` button at the top of the page.  Click on the `8080` link
    to open a new browser window to the running web server.  If the port
    number doesn't show up, click on `OPEN PORT` and enter the port number as
    `8080`.

## Building

The application is built using [Vite](https://vitejs.dev/).

The following commands are executed in the root of the project directory.

Install the required packages:

	$ npm install
	$ yarn

Run the application for development:

	$ npm run dev
	$ yarn dev

Build release files:

	$ npm run build
	$ yarn build

The object files are created under `./dist`.

Preview using the files under `./dist`:

	$ npm run preview
	$ yarn preview

The files built under `dist` can be deployed using a static web-server such as
Apache or Nginx.

### Creating a Release with Docker/Podman

1.  Build the release:

		$ docker compose -f docker-compose-dev.yaml up -d --build

	When running `podman`, if you get errors like `Error: statfs
    .../convert-coord: no such file or directory`, try restarting the Podman
    machine.

2.  Monitor the build:

		$ docker logs -f convert-coord_web_1

	Navigate to <http://localhost:8090/> to view the application.

3.  The distribution files are created in the project's root directory on the
    host.

		$ ls convert-coord-release-*

4.  Re-build the release:

		$ docker exec -it convert-coord_web_1 bash
		$ cd /convert-coord
		$ npm run build-release

5.  To develop using Vite:

		$ docker exec -it convert-coord_web_1 bash
		$ cd /convert-coord
		$ npm run lint
		$ npm audit
		$ npm outdated
		$ npm run dev -- --host

	Navigate to <http://localhost:8080/> to view the application.

	If changes to the code are not recognised, press the `r` key to restart
    the Vite server.

6.  To stop the container, optionally including the `-v` switch to remove the
    volume used to hold the required npm packages:

		$ docker compose -f docker-compose-dev.yaml down -v

## Building Docker Image for Release

1.  Rebuild the image with:

		$ podman compose up -d --build --no-cache --force-recreate

	or:

		$ docker build --no-cache -t fdean/convert-coord .
		$ docker compose up -d

2.  Optionally browse to <http://localhost:8090/> to view the running
    application.

3.  Stop the running container with:

		$ docker compose down

4.  Tag the release:

		$ docker tag fdean/convert-coord:latest fdean/convert-coord:$VERSION

5.  Push the release:

		$ docker push fdean/convert-coord:$VERSION
		$ docker push fdean/convert-coord:latest
