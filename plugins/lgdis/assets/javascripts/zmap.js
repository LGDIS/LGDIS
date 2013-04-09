/** 
 * マップ表示
 */
function z_showMap(map_id) {
  //toggleMap(map_id);
  z_initMap(map_id);
}

/** 
 * マップ作成
 * ※ブラウザ上に認証承認ID(ADI)cookie群が存在する前提
 */
function z_initMap(map_id) {
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
}
