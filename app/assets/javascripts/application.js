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

$(document).ready(function () {
    $('.fotorama').on('fotorama:showend', function (e, fotorama, extra) {
        var images = document.getElementsByTagName('img'),
            retinaImages = [],
            i, image;
        for (i = 0; i < images.length; i += 1) {
            image = images[i];
            if (!!!image.getAttributeNode('data-no-retina')) {
                retinaImages.push(new RetinaImage(image));
            }
        }
    });

    // Global
    map = L.map('map');

    map.setView([-35.30, 149.12], 4);

    L.tileLayer('https://{s}.tiles.mapbox.com/v3/doconnor.ionk423c/{z}/{x}/{y}.png', {
        attribution: '<a href="http://www.mapbox.com/about/maps/" target="_blank">Terms &amp; Feedback</a>'
    }).addTo(map);
/*
    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
*/

    $("#items-table").on("click", ".view-image", function (e) {
        e.preventDefault();
        var id = $(this).data().id;
        var project_id = $(this).data().project_id;

        $('#image').html(" ");
        $.getJSON('/projects/' + project_id + '/items/' + id + '/photo_links.json', function (data) {
            $.each(data, function (i, item) {
                $("<img>").attr("src", item).appendTo("#image");
            });
        });

        $.getJSON('/projects/' + project_id + '/items/' + id + '.geojson', function (data) {
            map.setView(data.coordinates, 15);
            //L.geoJson(data).addTo(map);
            L.marker(data.coordinates).addTo(map);

            window.location.href="#map";
        });
    });
});
