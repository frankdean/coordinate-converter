/**
 * @license Coordinate Converter
 * (c) 2016, 2017 Frank Dean <frank@fdsd.co.uk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
'use strict';

angular.module('myApp.convert.coords.controller', [])

  .controller(
    'ConvertCtrl',
    ['$scope',
     '$routeParams',
     '$log',
     '$window',
     'UtilsService',
     function ($scope,
               $routeParams,
               $log,
               $window,
               UtilsService) {
       var DEFAULT_COORD_FORMAT = '%d\u00b0%M\u2032%S\u2033%c';
       var DEFAULT_POSITION_FORMAT = 'lat-lng';
       angular.extend($scope, {
         data: {
           highAccuracy: true
         },
         geolocationEnabled: "geolocation" in $window.navigator,
         coordFormat: DEFAULT_COORD_FORMAT,
         positionFormat: DEFAULT_POSITION_FORMAT,
         georefFormats: [
           {"key":"%d°%M′%S″%c","value":"DMS+"},
           {"key":"%d°%M′%c","value":"DM+"},
           {"key":"%d°%c","value":"D+"},
           {"key":"%i%d","value":"D"},
           {"key":"%p%d","value":"±D"},
           {"key":"plus+code","value":"OLC plus+code"},
           {"key":"osgb36","value":"OS GB 1936 (BNG)"},
           {"key":"%dd%M'%S\"%c","value":"Proj4"},
           {"key":"%c%D° %M","value":"QLandkarte GT"},
           {"key":"%c%d°%M′%S″","value":"+DMS"},
           {"key":"%c%d°%M′\\","value":"+DM"},
           {"key":"%c%d°","value":"+D"},
           {"key":"%d° %M′ %S″ %c","value":"D M S +"},
           {"key":"%d° %M′ %c","value":"D M +"},
           {"key":"%d° %c","value":"D +"},
           {"key":"%c %d° %M′ %S″","value":"+ D M S"},
           {"key":"%c %d° %M′","value":"+ D M"},
           {"key":"%c %d°","value":"+ D"},
           {"key":"%d %m %s%c","value":"Plain DMS+"},
           {"key":"%d %m%c","value":"Plain DM+"},
           {"key":"%d%c","value":"Plain D+"},
           {"key":"%c%d %m %s","value":"Plain +DMS"},
           {"key":"%c%d %m","value":"Plain +DM"},
           {"key":"%c%d","value":"Plain +D"},
           {"key":"IrishGrid","value":"Irish Grid"},
           {"key":"ITM","value":"Irish Transverse Mercator"}]
       });
       if ($routeParams.text) {
         $scope.data.position = decodeURIComponent($routeParams.text);
       }
       $scope.updatePosition = function(form) {
         var options = {
           enableHighAccuracy: $scope.data.highAccuracy,
           timeout: 10000,
           maximumAge: 0
         };
         if ($window.navigator && $window.navigator.geolocation) {
           UtilsService.getLocation(options).then(function(positionText) {
             $scope.data.position = positionText;
           });
         } else {
           $log.error('geolocation service is not available in the browser');
         }
       };
     }])

  .directive(
    'position',
    ['$q', 'UtilsService', '$log', function($q, UtilsService, $log) {

      function link(scope, element, attrs, ctrl) {
        ctrl.$asyncValidators.position = function(modelValue, viewValue) {
          var def = $q.defer();
          var coord = UtilsService.parseTextAsDegrees(modelValue);
          if (isFinite(coord.lat) && isFinite(coord.lng) && coord.lat >= -90 && coord.lat <= 90 && coord.lng >= -180 && coord.lng <= 180) {
            def.resolve();
          } else {
            def.reject();
          }
          return def.promise;
        };
      }

      return {
        require: 'ngModel',
        restrict: 'A',
        link: link
      };
    }])

  .directive(
    'tlLatLng',
    ['coordFilter', 'UtilsService', '$log', function(coordFilter, UtilsService, $log) {

      function link(scope, element, attrs) {
        scope.$watch(attrs.tlLatLng, function(value) {
          if (value) {
            var coord = UtilsService.parseTextAsDegrees(value);
            scope.$eval(attrs.lat + ' = ' + coord.lat);
            scope.$eval(attrs.lng + ' = ' + coord.lng);
            scope.$emit('TL_POSITION_UPDATED', {lat: coord.lat, lng: coord.lng});
          }
        });
      }

      return {
        restrict: 'A',
        link: link
      };
    }])

  .directive(
    'tlCoordFormat',
    ['coordFilter', 'UtilsService', '$log', function(coordFilter, UtilsService, $log) {

      var myElement, format, formatPosition;

      function link(scope, element, attrs) {
        scope.$watch(attrs.tlCoordFormat, function(value) {
          if (value) {
            myElement = element;
            format = value;
            element.text(UtilsService.convertToFormat(scope.$eval(attrs.lat), scope.$eval(attrs.lng), format, formatPosition));
            scope.$emit('TL_COORD_FORMAT_CHANGED', format);
          } else {
            element.text('');
          }
        });
        scope.$watch(attrs.positionFormat, function(value) {
          if (value) {
            formatPosition = value;
            if (format) {
              element.text(UtilsService.convertToFormat(scope.$eval(attrs.lat), scope.$eval(attrs.lng), format, formatPosition));
            }
            scope.$emit('TL_POSITION_FORMAT_CHANGED', formatPosition);
          } else {
            element.text('');
          }
        });
      }

      return {
        restrict : 'A',
        controller : ['$scope', function($scope) {
          $scope.$on('TL_POSITION_UPDATED', function(e, data) {
            if (myElement && format) {
              myElement.text(UtilsService.convertToFormat(data.lat, data.lng, format, formatPosition));
              // http://wiki.openstreetmap.org/wiki/Permalink
              // http://www.openstreetmap.org/?mlat=54.908&mlon=-6.185#map=6/54.908/-6.185
              $scope.data.osmurl='http://www.openstreetmap.org/' +
                '?mlat=' +
                encodeURIComponent(data.lat) +
                '&mlon=' +
                encodeURIComponent(data.lng) +
                '#map=15/' +
                encodeURIComponent(data.lat) +
                '/' +
                encodeURIComponent(data.lng);
              // https://developers.google.com/maps/documentation/urls/guide
              $scope.data.googleurl='https://www.google.com/maps/search/?api=1&map_action=map&query=' +
                encodeURIComponent(data.lat + ',' + data.lng);
            }
          });
        }],
        link : link
      };
    }]);
