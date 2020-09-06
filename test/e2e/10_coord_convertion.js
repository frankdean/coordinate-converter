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

var helper = {
  wait: function wait(time = 400) {
    if (browser.privateConfig.browserName.toLowerCase() == 'safari') {
      browser.sleep(time);
    }
  }
};

describe('Coordinate convertion', function() {

  beforeEach(function() {
    browser.get('index.html#/convert');
    helper.wait();
  });

  it('should show the whereami button', function() {
    expect(element(by.id('btn-whereami')).isDisplayed()).toBeTruthy();
  });

  it('should not show the converted location', function() {
    expect(element(by.id('div-output-location')).isDisplayed()).toBeFalsy();
  });

  it('should not show the links to external maps', function() {
    expect(element(by.id('div-ext-links')).isDisplayed()).toBeFalsy();
  });

  it('should show the converted location once valid text has been entered', function() {
    element(by.id('input-position')).sendKeys(1,-3);
    helper.wait();
    expect(element(by.id('div-output-location')).isDisplayed()).toBeTruthy();
    expect(element(by.id('div-ext-links')).isDisplayed()).toBeTruthy();
  });

});
