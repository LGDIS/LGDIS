# 初期データ投入(db:seed)前の事前作業

ワークフロー(フィールドに対する権限)の初期データのvolumeが大きいため、ワークフローデータの作成コマンドを実行してから、初期データ投入（db:seed）のコマンドを実行する。

## １．ワークフロー(フィールドに対する権限)の初期データのcsvを作成する

rake db:seedコマンドを実行する前に、下記のコマンドを実行する。

	cd LGDIS/plugins/lgdis/db/seeds
	ruby create_workflow.rb
	cd /home/rails/LGDIS

ワークフローの初期登録データを変更する場合は、このCSVファイルの中身を変更する。

## ２．初期データを投入する

下記のコマンドを実行する。

	rake db:seed RAILS_ENV=production

