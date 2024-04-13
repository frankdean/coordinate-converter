// -*- mode: js2; fill-column: 80; indent-tabs-mode: nil; c-basic-offset: 2; -*-
// vim: set tw=80 ts=2 sts=0 sw=2 et ft=js norl:
/*
    This file is part of Trip Server 2, a program to support trip recording and
    itinerary planning.

    Copyright (C) 2022-2023 Frank Dean <frank.dean@fdsd.co.uk>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import { LocationParser } from 'location-service.js';

class App {
  constructor() {
    this.haveLocation = false;
    const parser = new LocationParser({
      sourceElementId: 'input-position',
      targetElementId: 'position-text',
      formatElementId: 'input-coord-format',
      formatStyleDivId: 'position-style-div',
      formatStyleElementId: 'position-separator',
      lngElementId: 'input-lng',
      latElementId: 'input-lat',
    });

    const self = this;
    parser.on('clear-location', event => {
      self.locationClearedHandler(event);
    });

    parser.on('set-location', event => {
      self.locationSetHandler(event);
    });

    document.getElementById('btn-whereami').addEventListener('click', this.handleGetLocation.bind(this), false);
  }

  locationSetHandler(event) {
    document.getElementById('div-ext-links').className = 'd-block';
    document.getElementById('osm-link').setAttribute('href', `https://www.openstreetmap.org/?mlat=${event.detail.lat}&mlon=${event.detail.lng}#map=15/${event.detail.lat}/${event.detail.lng}`);
    document.getElementById('google-link').setAttribute('href', `https://www.google.com/maps/search/?api=1&map_action=map&query=${event.detail.lat}%2C${event.detail.lng}`);
    this.haveLocation = true;
  }

  locationClearedHandler() {
    if (!this.haveLocation)
      return;
    document.getElementById('div-ext-links').className = 'd-none';
    this.haveLocation = false;
  }

  positionSuccess(position) {
    const lng = position.coords.longitude;
    const lat = position.coords.latitude;
    const e = document.getElementById('input-position');
    e.value = `${lat.toFixed(6)},${lng.toFixed(6)}`;
    e.dispatchEvent(new Event('input'));
  }

  positionFailure(error) {
    console.error(error);
    const div = document.getElementById('geolocation-denied');
    div.className = "alert alert-danger mx-5 my-3 d-block";
    setTimeout(() => {
      div.className = "d-none";
    }, 5000);
  }

  handleGetLocation() {
    if ('geolocation' in navigator) {
      const g = navigator.geolocation;
      g.getCurrentPosition(
        this.positionSuccess,
        this.positionFailure,
        {
          enableHighAccuracy: true,
        });
    }
  }

}

new App();
