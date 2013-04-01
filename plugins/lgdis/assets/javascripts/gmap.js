// google maps api
var DEFAULT_MAP_ZOOM = 13;
var DEFAULT_MAP_ZOOM_UPPER_LIMIT = 17;

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
function initMap(map_id, zoom_rate, field1_id, field2_id, field3_id, type) {
	var target = createMap(map_id, DEFAULT_MAP_CENTER, zoom_rate);
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
		$("#"+field2_id).val("");
		$("#"+field3_id).val("");
		break;
	case 'tyu':
		// テキストフィールドへ適用
		$("#"+field1_id).val(event.row.area_dai.value);
		$("#"+field2_id).val(event.row.area_tyu.value);
		$("#"+field3_id).val("");
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
function showMap(map_id, zoom_rate, field1_id, field2_id, field3_id, type) {
	toggleMap(map_id);
	initMap(map_id, zoom_rate, field1_id, field2_id, field3_id, type);
	map_initialized[map_id] = true;
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
 * マップ表示(発生場所入力用)
 */
function showMapSelectPosition(map_id, zoom_rate, field_id) {
		toggleMap(map_id);
		initMapSelectPosition(map_id, zoom_rate, field_id);
		map_initialized[map_id] = true;
}

/** 
 * マップ作成・クリックイベントセット(発生場所入力用)
 */
function initMapSelectPosition(map_id, zoom_rate, field_id) {
  // マップの作成
  var map = new google.maps.Map(document.getElementById(map_id), {
    center : DEFAULT_MAP_CENTER,
    zoom : zoom_rate || DEFAULT_MAP_ZOOM,
    mapTypeId : google.maps.MapTypeId.ROADMAP
  });
  var target = {map: map};

  // 初期表示時には入力済み地名をマーカで表示する
  var text_field = $("#"+field_id);
  var text_field_value = text_field.val().replace(/(\n|\r)+$/, '');
  if (text_field_value.length > 0) {
    var marker_bounds = new google.maps.LatLngBounds();
    var addresses = text_field_value.split("\n");
    for (var i = 0; i < addresses.length; i++) {
      // 入力された住所にマーカをセットする
      addMarker(addresses[i], target, marker_bounds);
    }
  }

  // クリックイベントリスナ登録
  google.maps.event.addListener(target.map, "click", function(event) {
    addClickedAddress(event.latLng, target, field_id);
  });
}

/** 
 * マップにマーカを表示(発生場所入力用)
 */
function addMarker(address, target, marker_bounds) {
  if (!address) return;

  var geocoder = new google.maps.Geocoder();
  geocoder.geocode({'address' : address}, function(results, status){
    switch (status) {
    case google.maps.GeocoderStatus.OK:
      // 取得地点にマーカをセット
      var marker = new google.maps.Marker({
        position : results[0].geometry.location,
        map : target.map
      });
      // マップ表示をマーカ群を見渡せる範囲に拡張する
      marker_bounds.extend(results[0].geometry.location);
      target.map.panToBounds(marker_bounds);
      target.map.fitBounds(marker_bounds);
      // fitBounds()ではズームし過ぎることがあるため調整
      var fitted_zoom_rate = target.map.getZoom();
      if (fitted_zoom_rate > DEFAULT_MAP_ZOOM_UPPER_LIMIT) {
        target.map.setZoom(DEFAULT_MAP_ZOOM_UPPER_LIMIT);
      }
      break;

    case google.maps.GeocoderStatus.ZERO_RESULTS:
      break;

    default:
      console.log("ERROR:"+status);
      break;
    }
  });
}

/** 
 * 指定された地点にマーカをセットし、その地名を取得してテキストフィールドに追加(発生場所入力用)
 */
function addClickedAddress(latlng, target, field_id) {
  var geocoder = new google.maps.Geocoder();
  geocoder.geocode({'latLng' : latlng}, function(results, status){
    switch (status) {
    case google.maps.GeocoderStatus.OK:
      // クリック地点にマーカをセット
      var marker = new google.maps.Marker({
        position : latlng,
        map : target.map
      });
      // クリック地点の地名をテキストフィールドに追加
      var address = results[0].formatted_address;
      var sep_pos = address.indexOf(", ");
      if (sep_pos >= 0) {
        address = address.substr(sep_pos + 2);
      }
      var text_field = $("#"+field_id);
      var text_field_value = text_field.val().replace(/(\n|\r)+$/, '');
      text_field.val(text_field_value.length>0 ? text_field_value+"\n"+address : address);
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
}
