// google maps api
var DEFAULT_MAP_CENTER = new google.maps.LatLng(35.702086,139.55979);//38.4342786010442, 141.30284786224365);//石巻市役所
var DEFAULT_MAP_ZOOM = 13;
var GOOGLE_FT_KEY = '1wVRsRYtnqjtYd4tMVAJt_zlS9TnOznTQdlGk9_g'; // FusionTablesのテーブルID

// key: map_id, value: boolean
var map_initialized = {};

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

/**
 * マップ、マーカをハッシュで取得
 */
function createMap(map_id, center_pos, zoom) {
	if (!map_id) return;

	// マップ、マーカ、FusionTables用レイヤ の作成
	var map = new google.maps.Map(document.getElementById(map_id), {
		center : center_pos || DEFAULT_MAP_CENTER,
		zoom : zoom || DEFAULT_MAP_ZOOM,
		mapTypeId : google.maps.MapTypeId.ROADMAP
	});
	var marker = new google.maps.Marker({
		position : center_pos || DEFAULT_MAP_CENTER,
		map : map,
        visible : false
	});
    var layer = new google.maps.FusionTablesLayer({
	    query: {
	        select : 'kml',
	        from : GOOGLE_FT_KEY
		},
		styles : [{
			polygonOptions : {
				fillColor : '#FFFFFF',
				fillOpacity : 0.0 // 透明度：1.0=透過なし
			}
		}],
		map : map,
	    suppressInfoWindows : true
    });

	return {
		map : map,
		marker : marker,
		layer : layer
	};
}

/** 
 * マップにクリックイベントセット
 */
function initMap(map_id, field1_id, field2_id, field3_id, type) {
	var target = createMap(map_id);
	if (!target) return;

	// レイヤークリックイベントリスナ登録
	google.maps.event.addListener(target.layer, "click", function(event) {
		setNewLayer(event, target, field1_id, field2_id, field3_id, type);
	});
}

/** 
 * マップクリックイベント
 */
function setNewLayer(event, target, field1_id, field2_id, field3_id, type) {
	// FusionTablesLayer再描画
	var where, fill_color;
	switch (type) {
	case 'dai':
		where = "area_dai = '" + event.row.area_dai.value + "'";
		fill_color = '#00FF00';
		break;
	case 'tyu':
	    //where = "area_dai = '" + event.row.area_dai.value + "' AND area_tyu = '" + event.row.area_tyu.value + "'";
		where = "area_tyu = '" + event.row.area_tyu.value + "'";
		fill_color = '#FF0000';
		break;
	case 'syo':
	    //where = "area_dai = '" + event.row.area_dai.value + "' AND area_tyu = '" + event.row.area_tyu.value + "' AND area_syo = '" + event.row.area_syo.value + "'";
		where = "area_syo = '" + event.row.area_syo.value + "'";
		fill_color = '#FFFF00';
		break;
	default:
		return;
	}
	target.layer.setMap(null);
	var layer = new google.maps.FusionTablesLayer({
		query: {
			select : 'kml',
			from : GOOGLE_FT_KEY,
			where : where
		},
		styles : [{
			polygonOptions : {
				fillColor : "#FF0000",
				fillOpacity : 0.5 // 透明度：1.0=透過なし
			}
		}],
		suppressInfoWindows : true
	});
	layer.setMap(target.map);

	switch (type) {
	case 'dai':
		// テキストフィールドへ適用
		$("#"+field1_id).val(event.row.area_dai.value);
		break;
	case 'tyu':
		// テキストフィールドへ適用
		$("#"+field1_id).val(event.row.area_dai.value);
		$("#"+field2_id).val(event.row.area_tyu.value);
		break;
	case 'syo':
		// テキストフィールドへ適用
		$("#"+field1_id).val(event.row.area_dai.value);
		$("#"+field2_id).val(event.row.area_tyu.value);
		$("#"+field3_id).val(event.row.area_syo.value);
		break;
	}
}

/** 
 * マップ表示
 */
// map_id: element-id of google-map
// fieldn_id: element-id of text field
// type: "dai", "tyu", "syo"
function showMap(map_id, field1_id, field2_id, field3_id, type) {
	toggleMap(map_id);
	if (!map_initialized[map_id]) {
		initMap(map_id, field1_id, field2_id, field3_id, type);
		map_initialized[map_id] = true;
	}
}

/** 
 * マップ非表示
 */
function clearMap(map_id) {
	toggleMap(map_id);
	if (map_initialized[map_id]) {
		map_initialized[map_id] = null;
	}
}

/** 
 * 住所からエリア取得
 */
var geocoder = new google.maps.Geocoder();
function getArea(address_id, field1_id, field2_id, field3_id) {
	var address = $("#"+address_id).val();
	var latlng = null;
	geocoder.geocode({'address' : address}, function(results, status){
		switch (status) {
		case google.maps.GeocoderStatus.OK:
		    latlng = results[0].geometry.location;
		    get_gft_address(latlng, field1_id, field2_id, field3_id);
		    break;
		case google.maps.GeocoderStatus.ZERO_RESULTS:
		    alert("エリアを特定できません");
		    break;
		default:
		    console.log("ERROR:"+status);
		    alert("エリアを特定できません");
		    break;
		}
	    });
	return latlng;
}