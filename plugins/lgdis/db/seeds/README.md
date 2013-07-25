# 初期データ投入(db:seed)前の事前作業

ワークフロー(フィールドに対する権限)の初期データのvolumeが大きいため、ワークフローデータの作成コマンドを実行してから、初期データ投入（db:seed）のコマンドを実行する。

## １．ワークフロー(フィールドに対する権限)の初期データのcsvを作成する

rake db:seedコマンドを実行する前に、下記のコマンドを実行する。

	cd LGDIS/plugins/lgdis/db/seeds
	bundle exec ruby create_workflow.rb
	cd /home/rails/LGDIS

ワークフローの初期登録データを変更する場合は、このCSVファイルの中身を変更する。

## ２．初期データを投入する

下記のコマンドを実行する。

	bundle exec rake db:seed RAILS_ENV=production


# Fusion Tablesの初期設定

事象の発生場所で使用するFusion Tablesを作成する

## １．Fusion Tablesを作成する。

自己のGoogleアカウントでログインし、下記のアドレスからFusion Tablesを作成するボタンをクリックする。

	http://www.google.com/drive/apps.html#fusiontables

以下の項目で、Fusion Tablesを作成し、共有設定をweb上で一般公開に設定する。

|Name     |Type     |Remarks       |
|:--------|:--------|:-------------|
|area_dai |Text     |地区大域名    |
|area_tyu |Text     |地区中域名    |
|area_syo |Text     |地区小域名    |
|kml      |Location |ポリゴンデータ|

CSVファイル等で、地区のポリゴンデータを作成し、作成したFusion Tablesへimportする。

	csvの例)
	  area_dai,area_tyu,area_syo,kml
	  地区大,地区中,地区小,"<Polygon><outerBoundaryIs><coordinates>
	  139.544435542658,35.70438073130079,0
	  139.5446345761617,35.70213828273126,0
	  139.544435542658,35.70438073130079,0</coordinates></outerBoundaryIs></Polygon>"

Fusion Tablesのデータを修正する場合には、下記のアドレスから編集画面へ遷移する。アドレスのXXXXXXXXXXの箇所は、作成したtableのIDを指定

	https://www.google.com/fusiontables/data?docid=XXXXXXXXXX

##　２．設定ファイルにFusionテーブルのテーブルIDを設定する。

custom_field_connection.ymlの以下のXXXXXXXXXXの欄に、テーブルIDを設定する。

	Google Fusion Tables
	　 テーブルの識別子
	google_fusion_tables:
	  id: XXXXXXXXXXX

custom_field_connection.ymlを修正した場合は、unicornの再起動が必要になります。
