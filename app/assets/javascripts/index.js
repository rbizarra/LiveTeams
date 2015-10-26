var map, osmUrl, osmAttrib, osm, sidebar, cluster;
var geo_entity_ajax_finished, teams_ajax_finished;

$(document).ready(function () {
    geo_entity_ajax_finished = false;
    teams_ajax_finished = false;

    sidebar = L.control.sidebar('sidebar', {position: 'right'}).addTo(map);
    cluster = L.markerClusterGroup();

    osmUrl = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    osm = L.tileLayer(osmUrl, {maxZoom: 20});

    /* mapa principal */
    map = L.map("map", {
        zoom: 12,
        center: [38.627881, -9.161007],
        layers: [osm],
        zoomControl: false,
        attributionControl: false
    });

    var drawnItems = new L.FeatureGroup();
    map.addLayer(drawnItems);

    /* controlo do zoom do mapa  */
    new L.Control.Zoom({position: 'bottomleft'}).addTo(map);

    // cria a barra de controlos para a cria��o de entidades
    L.drawLocal.draw.toolbar.buttons.polygon = 'Desenhar um poligono';
    L.drawLocal.draw.toolbar.buttons.polyline = 'Desenhar uma linha poligonal';
    L.drawLocal.draw.toolbar.buttons.marker = 'Desenhar um marcador';
    L.drawLocal.draw.toolbar.buttons.rectangle = 'Desenhar um rectangulo';
    L.drawLocal.draw.toolbar.buttons.circle = 'Desenhar um circulo';
    var drawControl = new L.Control.Draw({
        position: 'bottomleft',
        draw: {
            polygon: {
                title: 'Pol�gono',
                allowIntersection: true,
                drawError: {
                    color: '#b00b00',
                    timeout: 1000
                },
                shapeOptions: {
                    color: '#bada55'
                },
                showArea: true
            },
            polyline: {
                metric: false
            },
            circle: {
                shapeOptions: {
                    color: '#662d91'
                }
            },
            //rectangle: false //� assim que se desativam op��es
        },
        edit: {
            featureGroup: drawnItems
        }
    });
    map.addControl(drawControl);

    // Geolocaliza��o do utilizador atrav�s do GPS
    new L.control.locate({
        position: "bottomleft",
        drawCircle: true,
        follow: true,
        setView: true,
        keepCurrentZoomLevel: false,
        markerStyle: {
            weight: 1,
            opacity: 0.8,
            fillOpacity: 0.8
        },
        circleStyle: {
            weight: 1,
            clickable: false
        },
        icon: "fa fa-location-arrow",
        metric: true,
        strings: {
            title: "Clique aqui para ativar a geolocaliza��o",
            popup: "Encontra-se a {distance} {unit} deste ponto",
            outsideMapBoundsMsg: "Parece que se encontra fora dos limites do mapa"
        },
        locateOptions: {
            maxZoom: 19,
            watch: true,
            enableHighAccuracy: true,
            maximumAge: 10000,
            timeout: 10000
        }
    }).addTo(map);

    // cria uma imagem com a inicial do nome do utilizador autenticado
    $('.profile_name').initial({
        name: 'Name', // Name of the user
        charCount: 1, // Number of characherts to be shown in the picture.
        textColor: '#ffffff', // Color of the text
        seed: 0, // randomize background color
        height: 40,
        width: 40,
        fontSize: 20,
        fontWeight: 400,
        fontFamily: 'Helvetica Neue-Light,Helvetica Neue Light,Helvetica Neue,Helvetica, Arial, Lucida Grande, sans-serif',
        radius: 25
    });

    //altera o background da lista das equipas quando o utilizador faz hover com o rato
    $("#hover_test div:first-child")
        .mouseenter(function () {
            if (!($(this).hasClass("active")))
                $(this).css("background", "#eaeaea")
        })
        .mouseleave(function () {
            if (!($(this).hasClass("active")))
                $(this).css("background", "#fff")
        });

    //faz mais ou menos o mesmo mas quando o utilizador clica numa entrada da lista
    $("div.collapsible-header").click(function (div) {
        $("div.collapsible-header").css("background", "#fff");
        $("div.collapsible-header.active").css("background", "#eaeaea");
    });

    // inicializa as dropdowns que existem na pagina!
    $('select').material_select();

    var team_icon = L.icon({
        iconUrl: 'http://freeflaticons.net/wp-content/uploads/2014/11/group-copy-1416476921gn4k8.png',
        //shadowUrl: 'leaf-shadow.png',

        iconSize: [38, 38], // size of the icon
        //shadowSize:   [50, 64], // size of the shadow
        iconAnchor: [19, 30], // point of the icon which will correspond to marker's location
        //shadowAnchor: [4, 62],  // the same for the shadow
        popupAnchor: [-1, -30] // point from which the popup should open relative to the iconAnchor
    });


    // ****************** CHAMADAS ASSINCRONAS PARA POPULAR O MAPA ******************

    // retorna todas as entidades que estao na BD
    var geo_entities = new L.GeoJSON.AJAX("/get_geo_entities.json", {
        pointToLayer: function (feature, latlng) {
            console.log(feature);
            if (feature.properties.radius > 0)
                return L.circle(latlng, feature.properties.radius);
            else
                return L.marker(latlng);
        },
        onEachFeature: function (feature, layer) {
            layer.bindPopup('<p>' + feature.properties.name + '</p>' +
                '<p>' + feature.properties.description + '</p>');
        }
    });

    // listener invocado quando a chamada ajax acima terminar!
    geo_entities.on('data:loaded', function () {
        console.log("finish");
        cluster.addLayer(geo_entities);
        //console.log(geo_entities);
        map.addLayer(cluster);
    });

    // TODO: as coordenadas das equipas estao erradas!!! trocar esta cena
    $.getJSON("/teams", function (json) {
        var i, item, popup_content, coords_arr, marker;
        for (i = 0; i < json.length; i++) {
            item = json[i];
            //console.log(item);

            if (item.latlon != null) {
                coords_arr = parsePointCoordinates(item.latlon);

                popup_content = "<p>" + item.name + "<br/>Latitude:" +
                    coords_arr[0] + "<br/> Longitude:" + coords_arr[1] + "</p>";
                marker = L.marker([coords_arr[1], coords_arr[0]], {icon: team_icon});
                marker.bindPopup(popup_content);

                cluster.addLayer(marker);
            }
        }
        //teams_ajax_finished = true;
        //enableMarkerCluster();
        map.addLayer(cluster);
    });


//$.ajax({
//    type: "GET",
//    url: '/get_geo_entities',
//    dataType: 'json',
//    success: function (data) {
//        //console.log(data);
//        geojson = L.geoJson(data, {
//            onEachFeature: function (feature, layer) {
//                //console.log("EACH FEATURE");
//                //console.log(feature);
//                //console.log("EACH FEATURE");
//
//                //var c_arr = feature.geometry.coordinates;
//                console.log(feature.geometry.type + ": " + feature.properties.radius);
//                console.log(feature);
//
//                if (feature.geometry.type === "Point") {
//                    var c_arr = feature.geometry.coordinates;
//                    console.log(c_arr);
//                    var latlon = L.latLng(c_arr[1], c_arr[0]);
//                    console.log(latlon);
//
//                    if (feature.properties.radius > 0)
//                        L.circle(latlon, feature.properties.radius).addTo(map);
//                    else {
//                        if (feature.geometry.type === "Point") {
//                            var m = L.marker(latlon);
//                            // apenas os marcadores vao para o cluster
//                            cluster.addLayer(m);
//                        }
//                    }
//                }
//
//
//                //var latlon = L.LatLng(c_arr[1], c_arr[0]);
//                //console.log(latlon);
//
//
//                popupOptions = {maxWidth: 600};
//                //layer.bindLabel('<h4>' + feature.properties.name + '</h4>');
//                //sidebar.setContent('<h4>'+feature.properties.musno+'</h4><br>'+'<h4>'+feature.properties.exchange_name+'</h4><br>'+feature.properties.pcp, popupOptions);
//                layer.bindPopup('<p>' + feature.properties.name + '</p>' +
//                    '<p>' + feature.properties.description + '</p>', popupOptions);
//            }
//        }).addTo(map);
//
//        cluster.addLayer(g);
//
//        geo_entity_ajax_finished = true;
//        enableMarkerCluster();
//    },
//
//    //geojson.addTo(map);
//    //console.log(geojson);
//    error: function (err) {
//        console.log(err);
//    }
//});


// ****************** LISTENERS PARA A CRIA��O/EDI��O DE ENTIDADES ******************

    /* listener invocado quando � criada uma feature */
    map.on('draw:created', function (e) {
        console.log(e);
        var name = "", desc = "", coords = "", user_id = "",
            radius = 0, type = e.layerType, layer = e.layer;

        // ta porreiro
        if (type === 'marker' || type === 'circle') {
            if (type === 'circle')
                radius = e.layer._mRadius;
            else
                radius = 0;

            layer.bindPopup('NOVO ' + type + '!');
            console.log(e.layer);

            coords = "POINT(" + e.layer._latlng.lng + " " + e.layer._latlng.lat + ")";
            desc = "[" + type + "] olha uma infowindow, ta engrassade.";
            name = type + " porreiro";

            //console.log(e.layer._mRadius);
        }
        // ta porreiro
        else if (type === 'polyline') {
            layer.bindPopup('NOVA LINHA POLIGONAL!');
            console.log(e.layer._latlngs);

            coords = "LINESTRING(";
            var c_arr = e.layer._latlngs;
            $.each(c_arr, function (i, elem) {
                coords += elem.lng + " " + elem.lat;
                if (i < c_arr.length - 1)
                    coords += ",";
            });
            coords += ")";
            desc = "[Polyline] olha uma infowindow, ta engrassade.";
            name = "Linha poligonal porreira";
            radius = 0;

            console.log(coords);
        }
        // ta porreiro
        else if (type === 'rectangle' || type === 'polygon') {
            layer.bindPopup('NOVO ' + type + '!');
            console.log(e.layer._latlngs);

            coords = "POLYGON((";
            var c_arr = e.layer._latlngs;
            $.each(c_arr, function (i, elem) {
                coords += elem.lng + " " + elem.lat;
                if (i < c_arr.length - 1)
                    coords += ",";
            });
            coords += "))";
            desc = "[" + type + "] olha uma infowindow, ta engrassade.";
            name = type + " porreiro";
            radius = 0;
        }

        // envia a entidade para o servidor
        $.ajax({
            type: "POST",
            url: "/geo_entities",
            dataType: "json",
            data: {
                geo_entity: {
                    name: name,
                    entity_type: type,
                    radius: radius,
                    description: desc,
                    latlon: coords,
                    user_id: "1"
                }
            },
            success: function (data) {
                console.log("MARCADOR ADICIONADO COM SUCESSO");
            },
            error: function (err) {
                console.log("erro a adicionar o marcador");
                console.log(err);
            }
        });

        drawnItems.addLayer(layer);
    });

    /* listener invocado quando se edita uma feature */
    map.on('draw:edited', function (e) {
        var layers = e.layers;
        layers.eachLayer(function (layer) {
            //do whatever you want, most likely save back to db
        });
    });
})
;


// o parametro "coords" � da forma -> "POINT(33.333 11.111)"
// retorna um vector com 2 posi�oes, uma para cada coordenada
function parsePointCoordinates(coords) {
    var split_res = coords.split("(");
    var new_split_res = split_res[1].split(" ");

    var res = [];
    res.push(new_split_res[0]); //latitude
    res.push(new_split_res[1].split(")")[0]); //longitude

    return res;
}

// so coloca o cluster no mapa quando as duas chamadas terminarem
function enableMarkerCluster() {
    if (geo_entity_ajax_finished && teams_ajax_finished) {
        map.addLayer(cluster);
        geo_entity_ajax_finished = false;
        teams_ajax_finished = false;
    }
}

/*
 * workaround para inicializar o mapa correspondente,
 * uma vez que se o mapa do modal fosse inicializado no document.ready,
 * como a largura do modal � inexistente, o mapa fica com tamanho bastante reduzido e
 * s� ficava correcto com o resize do viewport
 */
//function initMap() {
//    osm2 = L.tileLayer(osmUrl, {maxZoom: 18});
//
//    if (map_to_init == 1) {
//        //alert("criar equipa");
//        /* mapa apresentado na modal para criar equipa */
//        create_team_map = L.map("create_team_map", {
//            zoom: 12,
//            center: [38.627881, -9.161007],
//            layers: [osm2],
//            zoomControl: true,
//            attributionControl: false
//        });
//    }
//    else if (map_to_init == 2) {
//        //alert("editar equipa");
//        /* mapa apresentado na modal para editar equipa */
//        create_team_map = L.map("edit_team_map", {
//            zoom: 12,
//            center: [38.627881, -9.161007],
//            layers: [osm2],
//            zoomControl: true,
//            attributionControl: false
//        });
//    }
//    map_to_init = -1;
//}

/*
 * o parametro indica se estamos a editar ou a criar uma equipa nova
 * dps verifica se o mapa ja esta desenhado ou se � necessario inicializar
 */
//function drawMapOnModal(number) {
//    if (number == 1) {
//        if (typeof create_team_map === "undefined") {
//            map_to_init = number;
//            setTimeout(initMap, 500);
//        }
//    }
//    else if (number == 2) {
//        if (typeof edit_team_map === "undefined") {
//            map_to_init = number;
//            setTimeout(initMap, 500);
//        }
//    }
//}


//$(window).resize(function () {
//
//});

//$(document).on("mouseover", ".feature-row", function (e) {
//    //highlight.clearLayers().addLayer(L.circleMarker([$(this).attr("lat"), $(this).attr("lng")], highlightStyle));
//});
