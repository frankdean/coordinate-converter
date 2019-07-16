module.exports = function(config){
  config.set({

    basePath : '../',

    files : [
      'app/node_modules/angular/angular.js',
      'app/node_modules/angular-messages/angular-messages.js',
      'app/node_modules/angular-route/angular-route.js',
      'app/node_modules/angular-resource/angular-resource.js',
      'app/node_modules/angular-mocks/angular-mocks.js',
      'app/node_modules/angular-animate/angular-animate.js',
      'app/node_modules/angular-ui-bootstrap/dist/ui-bootstrap.js',
      'app/node_modules/open-location-code/js/src/openlocationcode.min.js',
      'app/node_modules/proj4/dist/proj4.js',
      'app/js/**/*.js',
      'test/unit/**/*.js'
    ],

    autoWatch : true,

    frameworks: ['jasmine'],

    _browsers : ['Chrome', 'Firefox', 'Safari'],
    browsers : ['Chrome'],

    logLevel: config.LOG_INFO,

    browserConsoleLogOptions: {
      level: 'debug',
      format: '%b [%T] %m',
      terminal: true
    },

    plugins : [
            'karma-chrome-launcher',
            'karma-firefox-launcher',
            'karma-safari-launcher',
            'karma-jasmine',
            'karma-junit-reporter'
            ],

    junitReporter : {
      outputFile: 'test_out/unit.xml',
      suite: 'unit'
    }

  });
};
