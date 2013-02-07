// The default viewport of the map.
const DEFAULT_MAP_CENTER = new google.maps.LatLng(35.702086,139.55979);//38.4342786010442, 141.30284786224365);//石巻市役所
const DEFAULT_MAP_ZOOM = 13;
const GOOGLE_FT_KEY = '1wVRsRYtnqjtYd4tMVAJt_zlS9TnOznTQdlGk9_g'; // FusionTablesのテーブルID

var ft_id = null;

// key: map_id, value: LatLng
var latlng_by_map_id = {};
// key: map_id, value: address string
var address_by_map_id = {};
// key: map_id, value: boolean
var map_initialized = {};

// Initializes a map at the canvas whose id is "map_id" and drops a marker at
// the map's center.  "center" and "zoom" may be undefined, in which case the
// default values are used.
function initMap(map_id, center_pos, zoom) {
	var map_canvas = document.getElementById(map_id);
	if (!map_canvas) return;

	// マップ、マーカ、FusionTables用レイヤ の作成
	var map = new google.maps.Map(map_canvas, {
		center : center_pos || DEFAULT_MAP_CENTER,
		zoom : zoom || DEFAULT_MAP_ZOOM,
		mapTypeId : google.maps.MapTypeId.ROADMAP
	});
	var marker = new google.maps.Marker({
		map : map,
		position : center_pos || DEFAULT_MAP_CENTER
	});
    var ftlayer = new google.maps.FusionTablesLayer({
      query: {
        select: 'kml',
        from: GOOGLE_FT_KEY,
        suppressInfoWindows: true
      }
    });
    ftlayer.setMap(map);

	return {
		map : map,
		marker : marker,
		layer : ftlayer
	};
}

// Initializes a map and a marker, using the lat/lng stored in latlng_by_map_id
// as the center.
function initMarkeredMap(map_id, zoom) {
	var latlng = latlng_by_map_id[map_id];
	if (latlng) {
		initMap(map_id, latlng, zoom);
	}
}

// Initializes a map with the default viewport and listens to click events.
// When the map is clicked, drop a marker at the clicked location, and updates
// the location text field with the lat/lng of the location. It also queries
// the geocoder to reverse geocode the lat/lng, and if successful, updates the
// text field with the reverse-geocoded address.
function initClickableMap(map_id, field_id) {
	var markered_map = initMap(map_id);
	if (!markered_map)
		return;

	markered_map.map.setOptions({
		draggableCursor : 'pointer'
	});
	markered_map.marker.setVisible(false);

	// レイヤークリックイベントリスナ登録
	google.maps.event.addListener(markered_map.layer, "click", function(event) {
		// FusionTablesLayer再描画
		ft_id = event.row.area_syo.value;
		var where = "area_syo = '" + ft_id + "'"; //ユニークに特定できるクエリ
		var mask_color = '#FF0000';
		markered_map.layer.setMap(null);
		layer = new google.maps.FusionTablesLayer({
			query : {
				select : 'kml',
				from : GOOGLE_FT_KEY,
				where : where
			},
			styles : [{
				polygonOptions : {
					fillColor : mask_color
				}
			}],
			map : markered_map.map,
	        suppressInfoWindows: true
		});
		// テキストフィールドへ適用
		var f1 = document.getElementById(field_id);
		f1.value = event.row.area_dai.value;
		var f2 = document.getElementById(field_id.substring(0, field_id.length - 1) + "1");
		f2.value = event.row.area_tyu.value;
		var f3 = document.getElementById(field_id.substring(0, field_id.length - 1) + "2");
		f3.value = event.row.area_syo.value;
	});
	}

// Toggles the visibility of an element specified by the id and returns the
// visibility of the element after the toggle.
function toggle(id) {
	var element = document.getElementById(id);
	var to_be_visible = element.style.display == 'none';
	element.style.display = to_be_visible ? '' : 'none';
	return to_be_visible;
}

// Toggles the visibility of the map and the show/hide link.
function toggleMap(map_id) {
	toggle(map_id);
	toggle(map_id + '_show_link');
	toggle(map_id + '_hide_link');
}

function toggleClickableMap(map_id, field_id) {
	toggleMap(map_id);
	if (!map_initialized[map_id]) {
		initClickableMap(map_id, field_id);
		map_initialized[map_id] = true;
	}
}

function clearMap(map_id) {
	toggleMap(map_id);
	if (map_initialized[map_id]) {
		map_initialized[map_id] = null;
	}
}
