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

## Building

The application is built using [Vite](https://vitejs.dev/).

The following command are executed in the root of the project directory.

Run the application for development:

	$ npm run dev
	$ yarn dev

Build a release:

	$ npm run build
	$ yarn build

Preview the release:

	$ npm run preview
	$ yarn preview

Build a release with a different configuration:

	$ npm run build -- --config ./vite.config.prod.js
	$ yarn build --config ./vite.config.prod.js

The files built under `dist` can be deployed using a static web-server such as
Apache or Nginx.  The default build requires the files to be in the root
folder of the web-server.  Modify and build with the `./vite.config.prod.js`
configuration to use a sub-directory on the host.
