/** 
 * マップ表示
 * ※ブラウザ上に認証承認ID(ADI)cookie群が存在する前提
 */
function showZMapSelectPosition(map_id, zoom_rate, field_id) {
  toggleMap("z", map_id);
  initZMapSelectPosition(map_id, zoom_rate, field_id);
  map_initialized[map_id] = true;
}

function initZMapSelectPosition(map_id, zoom_rate, field_id) {
  // ログインしていなかったら処理終了
  if(ZntAuth.getStatus() != ZntAuth.STATUS_LOGIN) {
    return;
  }

  // マップ作成用パラメータ指定
  var w = '600';
  var h = '480';
  var opts = new ZntMapOptions();

  // 緯度経度を指定する
  opts.initPos = new ZntPoint(zmap_lng, zmap_lat);
  // 地図サイズを指定する
  opts.size = new ZntSize(w,h);
  // 地図倍率を指定する
  opts.initZoomLevel = zmap_zoom;
  // 地図表示モードを指定する
  opts.viewMode = zmap_view;
  // マウスドラッグモードを指定する
  opts.dragMode = Number(zmap_drag);
  // ８方向ボタンを指定する
  opts.scrollButton = true;
  // 虫めがねを指定する
  if(zmap_loupe == "1") {
    opts.loupe = true;
    opts.loupeOpen = true;
  } else if(zmap_loupe == "2") {
    opts.loupe = true;
    opts.loupeOpen = false;
  } else {
    opts.loupe = false;
  }
  // 広域ミニマップを指定する
  if(zmap_submap == "1") {
    opts.subMap = true;
    opts.subMapOpen = true;
  } else if(zmap_submap == "2") {
    opts.subMap = true;
    opts.subMapOpen = false;
  } else {
    opts.subMap = false;
  }

  //地図の初期化と表示
  var map = new ZntMap();
  map.initialize(document.getElementById(map_id), opts);
  var target = {map: map};

  // 初期表示時には入力済み地名をマーカで表示する
  var text_field = $("#"+field_id);
  var text_field_value = text_field.val().replace(/(\n|\r)+$/, '');
  if (text_field_value.length > 0) {
    var marker_bounds = null;
    var addresses = text_field_value.split("\n");
    for (var i = 0; i < addresses.length; i++) {
      // 入力された住所にマーカをセットする
      addZMarker(addresses[i], target, marker_bounds);
    }
  }

  // クリックイベントリスナ登録
  target.map.addEventListener("click", function(event) {
    addClickedZAddress(event.pos, target, field_id);
  });
}

/** 
 * マップにマーカを表示(発生場所入力用)
 */
function addZMarker(address, target, marker_bounds) {
  if (!address) return;

  // 検索オブジェクトと検索条件指定オブジェクトを生成する
  var sear = new ZntAddressSearch();
  var opts = new ZntAddressSearchSettings();

  // 検索ワードを指定する
  opts.freeWord = address;
  // 都道府県コードを指定する
  opts.prefCode = ""; // 全国
  // 行政単位コードを指定する
  opts.matchLv = "6"; // 6:枝版
  // 上限数を指定する
  opts.limit = "1";
  // 部品図を指定する
  opts.partMap = "false"; // false:含めない
  // 開始位置を指定する
  opts.startPos = "1";
  // 最大件数を設定する
  opts.maxCount = "1";

  sear.addEventListener("receive", function(r){
    var result = r.result;
    if (result.status == "30200000") {
      if (result.itemsAddr.length > 0) {
        // 取得地点にマーカをセット
        putMarker(target, result.itemsAddr[0].pos);
        // マップ表示をマーカ群を見渡せる範囲に拡張する
        marker_bounds = extendRect(marker_bounds, result.itemsAddr[0].pos);
        target.map.moveToRect(marker_bounds, new ZntSize(20, 20));
      } else {
        // 成功だけど結果0件
        console.log("no result retrieved.");
      }
    } else {
      console.log("ERROR:"+result.status);
    }
  }, 0);
  sear.search(opts);
}

/** 
 * 指定された地点にマーカをセットし、その地名を取得してテキストフィールドに追加(発生場所入力用)
 */
function addClickedZAddress(latlng, target, field_id) {
  // クリック地点の地名を取得
  var sear = new ZntAddressStringSearch();
  var opts = new ZntAddressStringSearchSettings();
  opts.pos = latlng;
  // マッチングさせる行政単を設定する
  opts.matchLv = 6; // 6： 枝番までの住所文字列を取得する。

  sear.addEventListener("receive", function(r){
    var result = r.result;
    switch(result.status){
    case "30400000":
      // クリック地点にマーカをセット
      putMarker(target, latlng);
      // クリック地点の地名をテキストフィールドに追加
      var text_field = $("#"+field_id);
      var text_field_value = text_field.val().replace(/(\n|\r)+$/, '');
      text_field.val(text_field_value.length>0 ? text_field_value+"\n"+result.address : result.address);
      break;
    case "30411009":
      alert("エリアを特定できません");
      break;
    default:
      console.log("ERROR:"+result.status);
      alert("エリアを特定できません");
      break;
   }
  }, 0);
  sear.search(opts);
}

function putMarker(target, latlng) {
  var marker_option;
  marker_opts = new ZntMarkerOptions();
  marker_opts.icon = '/plugin_assets/lgdis/images/red-dot.png';
  marker_opts.visible = true;
  marker_opts.opacity = 1.0;
  marker_opts.zIndex = 0;
  marker_opts.iconOffset = new ZntPoint(2, -10); // 画像に応じたオフセット量を指定
  var marker = new ZntMarker(latlng, marker_opts);
  target.map.addGeometry(marker);
}

function extendRect(bounds, point) {
  if (bounds) {
    if (bounds.min > point) {
      bounds.min = point;
    }
    if (bounds.max < point) {
      bounds.max = point;
    }
  } else {
    bounds = new ZntRect(point, point);
  }
  return bounds;
}
