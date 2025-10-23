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

		$ docker container run --publish 8080:80 --name cc -d docker.io/fdean/convert-coord

1.  Once the application is running a link titled `8080` will be shown next to
    the `OPEN PORT` button at the top of the page.  Click on the `8080` link
    to open a new browser window to the running web server.  If the port
    number doesn't show up, click on `OPEN PORT` and enter the port number as
    `8080`.

## Building

The application can be built using either [Vite][] or [Rollup][].  [Rollup][]
provides a simple build solution.  [Vite][] uses [Rollup][] under the hood,
simplifies the development process and the build supports
[cache-busting](https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching#cache_busting).

[Vite]: https://vite.dev/ "Next Generation Frontend Tooling"
[Rollup]: https://rollupjs.org "The JavaScript module bundler"

The following commands are executed in the root of the project directory.

Install the required packages:

	$ npm install
	$ yarn

Run the application using [Vite][]for development:

	$ npm run dev
	$ yarn dev

### Creating a Release with Docker/Podman

The release contains only those artifacts that are required to deploy the
application.  A new release is only needed if there is a change to any of the
non-dev dependencies, which can be listed with:

	$ npm ls --all --omit dev

This builds the release using [Vite][].

1.  Build and run the release:

	Either using docker compose:

		$ docker compose -f docker-compose-dev.yaml up -d --build

	or manually:

		$ docker build -f Dockerfile-dev -t convert-coord-dev .
		$ docker volume create web_node_modules
		$ docker run --publish 8080:5173 \
		--publish 8081:4173 --publish 8090:80 \
		-v .:/convert-coord \
		-v web_node_modules:/convert-coord/node_modules \
		--name convert-coord_web_1 \
		-d convert-coord-dev

2.  Monitor the build:

		$ docker logs -f convert-coord_web_1

	Nginx is configured with `dist` as it's root directory.  Navigate to
    <http://localhost:8090/> to view the application.

3.  The distribution files are created in the project's root directory on the
    host.

		$ ls convert-coord-release-*

	The files built under `dist` can be deployed using a static web-server
	such as Apache or Nginx.

4.  Re-build the release (using [Rollup][]):

		$ docker exec -it convert-coord_web_1 bash
		$ npm run rollup-build-release

5.  Build the release using [Vite][]:

		$ npm run vite-build-release

	The [Vite][] files created under `dist` can be previewed with:

		$ npm run preview -- --host

	Navigate to <http://localhost:8081/> to view the application preview.

6.  To develop using [Rollup][]:

		$ docker exec -it convert-coord_web_1 bash
		$ npm run lint
		$ npm audit
		$ npm outdated
		$ npm run rollup-build

After making any edits to the application, re-run the build and refresh the
browser page at <http://localhost:8090/>.

7.  To develop using Vite:

		$ docker exec -it convert-coord_web_1 bash
		$ npm run lint
		$ npm audit
		$ npm outdated
		$ npm run dev -- --host

	Navigate to <http://localhost:8080/> to view the application.

	If changes to the code are not recognised, press the `r` key to restart
    the Vite server.

8.  To stop the container, optionally including the `-v` switch to remove the
    volume used to hold the required npm packages:

	If using docker compose:

		$ docker compose -f docker-compose-dev.yaml down -v

	Otherwise:

		$ docker container rm -f convert-coord_web_1

## Building Docker Images for Release

1.  Rebuild the images with:

		$ mv package-lock.json package-lock.json~
		$ docker build --platform=linux/amd64 -t fdean/convert-coord:latest-amd64 .
		$ mv package-lock.json~ package-lock.json
		$ docker build --platform=linux/arm64 -t fdean/convert-coord:latest-arm64 .

2.  Optionally start the container and browse to <http://localhost:8090/> to
    view the running application.

		$ docker compose up -d

3.  Stop the running container with:

		$ docker compose down

4.  Push the releases:

		$ docker push fdean/convert-coord:latest-amd64
		$ docker push fdean/convert-coord:latest-arm64
		$ docker image rm localhost/fdean/convert-coord:latest
		$ docker manifest create fdean/convert-coord:latest \
		fdean/convert-coord:latest-amd64 fdean/convert-coord:latest-arm64
		$ docker push fdean/convert-coord:latest

5.  Tag and push the versioned release:

		$ docker tag fdean/convert-coord:latest fdean/convert-coord:$VERSION
		$ docker push fdean/convert-coord:$VERSION

## Issues

### Fails to build amd64 images on arm64 with Fedora 42

MacPorts podman 5.6.1_0

Fedora 41 and 42 use versions of QEMU 9. on which the [Go garbage collector
crashes](https://gitlab.com/qemu-project/qemu/-/issues/2560).

Fedora 40.20241006.3.0 is OK.  Create the machine with:

	$ podman machine init fedora40 --image \
	$ https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/40.20241006.3.0/aarch64/fedora-coreos-40.20241006.3.0-applehv.aarch64.raw.gz
	$ export CONTAINER_CONNECTION=fedora40

Also Fedora 39 is OK.  Create the machine with:

	$ podman machine init fedora39 --image \
	$ https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20240407.3.0/aarch64/fedora-coreos-39.20240407.3.0-applehv.aarch64.raw.gz
	$ export CONTAINER_CONNECTION=fedora39
