// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require fotorama
//= require retina
//= require jquery_ujs
//= require ink-all
//= require autoload
//= require html5shiv
//= require leaflet
//= require jquery.dynatable
//= require_tree .

$(document).ready(function(){
  $('.fotorama').on('fotorama:showend', function (e, fotorama, extra) {
    var images = document.getElementsByTagName('img'), retinaImages = [], i, image;
    for (i = 0; i < images.length; i += 1) {
      image = images[i];
      if (!!!image.getAttributeNode('data-no-retina')) {
          retinaImages.push(new RetinaImage(image));
      }
    }
  });
});
