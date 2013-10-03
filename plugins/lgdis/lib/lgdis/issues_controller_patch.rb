# encoding: utf-8
require_dependency 'issues_controller'

module Lgdis
  module IssuesControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        before_filter :find_issue_wrapper, :only => [:request_delivery]
        alias_method_chain :authorize, :skip
        before_filter :build_new_issue_geography_from_params, :only => [:create]
        before_filter :get_watchers_by_group, :only => [:create]
        before_filter :init, :only => [:show, :request_delivery]
        before_filter :get_delivery_histories, :only => [:show, :request_delivery]
        before_filter :get_destination_list, :only => [:show, :request_delivery]
        before_filter :set_znettown_cookie, :only => [:new, :show]
        after_filter  :geocode_create, :only => [:create]
        after_filter  :geocode_update, :only => [:update]
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      SYSTEM_TRACKER_ID = [1, 2, 16, 18]

      # 外部配信要求処理(手動配信)
      # 外部配信要求受付け処理を行います
      # ==== Args
      # ==== Return
      # ==== Raise
      def request_delivery
        # 情報の配信対象地域のコード値の配列を","区切のstring に変換
        issue_attr = build_issue_attributes_for_request_delivery(params[:issue])
        @issue.assign_attributes(issue_attr)

        if (@ext_out_target = params[:ext_out_target]).blank?
          flash.now[:error] = l(:notice_delivery_unselected)

        elsif @issue.request_delivery(@ext_out_target)
          flash[:notice] = l(:notice_delivery_request_successful)
          redirect_back_or_default({:action     => 'show',
                                    :id         => @issue})
          return
        else
          flash.now[:error] = @issue.errors.full_messages.join("<br />")
        end

        # @issueの再構築
        find_issue
        @issue.assign_attributes(issue_attr)
        show  # IssuesController#showメソッドに委譲
      end

      # チケット新規登録時に事象の発生場所が入力されてたらissue_geographiesのレコードを更新
      # issueのcreateのアクション時にジオコーディングして座標値を取得する
      # ==== Args
      # ==== Return
      # ==== Raise
      def geocode_create
        #住所の項目が空じゃなければgeocode を読み取る
        begin
          unless @issue.custom_field_value(30).blank?

            address = @issue.custom_field_value(30)
            addresses = address.split("\r\n")

            addresses.each do |ad|
              unless ad.blank?
                hash = geocode(ad)

                @issue_geography = IssueGeography.new
                @issue_geography.point = hash['lng'].to_s + "," + hash['lat'].to_s
                # 手動入力された事象の発生場所を識別するため
                @issue_geography.remarks = "事象の発生場所"

                Rails.logger.info("--issue--")
                Rails.logger.info(@issue)
                Rails.logger.info("--issue--")

                @issue_geography.issue_id = @issue.id

                @issue_geography.save
              end
            end
          end
        rescue => e
          Rails.logger.info("---IssueGeography_update---")
          Rails.logger.info(e.message)
          Rails.logger.info("---IssueGeography_update---")
        end
      end

      # チケットの更新時にissue_geographiesのレコードを更新
      # issueのupdateのアクション時にジオコーディングして座標値を取得する
      # ==== Args
      # ==== Return
      # ==== Raise
      def geocode_update
        #住所の項目が空じゃなければgeocode を読み取る
        begin
          # 手動入力された対象レコードを削除
          IssueGeography.where("remarks = ?", "事象の発生場所").where("issue_id = ?", @issue.id).destroy_all

          unless @issue.custom_field_value(30).blank?

            address = @issue.custom_field_value(30)
            addresses = address.split("\r\n")

            addresses.each do |ad|
              unless ad.blank?
                hash = geocode(ad)

                @issue_geography = IssueGeography.new
                @issue_geography.point = hash['lng'].to_s + "," + hash['lat'].to_s
                # 手動入力された事象の発生場所を識別するため
                @issue_geography.remarks = "事象の発生場所"

                Rails.logger.info("--issue--")
                Rails.logger.info(@issue)
                Rails.logger.info("--issue--")

                @issue_geography.issue_id = @issue.id

                @issue_geography.save
              end
            end
          end
        rescue => e
          Rails.logger.info("---IssueGeography_update---")
          Rails.logger.info(e.message)
          Rails.logger.info("---IssueGeography_update---")
        end
      end

      private

      # 既存のコールバック処理（find_issue）のラッパー
      # 既存のコールバックに影響しないようにするための措置
      # ==== Args
      # ==== Return
      # 既存のコールバック処理（find_issue）の実行結果
      # ==== Raise
      def find_issue_wrapper
        find_issue
      end

      # 既存のコールバック処理（authorize）のスキップ処理
      # 既存のコールバックに影響しないようにするための措置
      # ==== Args
      # ==== Return
      # * issues#request_deliveryリクエストの場合
      # true:既存のコールバック処理（authorize）のスキップ
      # * 上記以外の場合
      # 既存のコールバック処理（authorize）の実行結果
      # ==== Raise
      def authorize_with_skip(ctrl = params[:controller], action = params[:action], global = false)
        return true if ctrl = "issues" && action = "request_delivery"
        return authorize_without_skip(ctrl, action, global)
      end

      # 共通初期処理
      # ==== Args
      # ==== Return
      # ==== Raise
      def init
        if @issue.mail_subject.blank?
          @issue.mail_subject = @issue.subject
        end

        if @issue.summary.blank?
          @issue.summary = @issue.description
        end
        @issue_const = Constant::hash_for_table(Issue.table_name)

        @area = {}
        area_code = DST_LIST["custom_field_list"]["area"]["id"]
        areas = IssueCustomField.find_by_id(area_code).possible_values
        areas.each do |area|
          key, value = area.split(":")
          @area.store(key, area)
        end
      end

      # リクエストパラメータから、登録用のチケット地理データを構築します
      # ==== Args
      # ==== Return
      # ==== Raise
      def build_new_issue_geography_from_params
        return true if !params[:issue] || !params[:issue][:issue_geographies]
        params[:issue][:issue_geographies].each do |issue_geography|
          @issue.issue_geographies.build(issue_geography)
        end
      end

      # watcherをgroup_idsからuser_idsにばらします
      def get_watchers_by_group
        if params[:watcher_groups].is_a?(Hash) && request.post?
          user_ids = []
          group_ids = params[:watcher_groups][:group_ids].presence || []
          group_ids.each do |group_id|
            user_ids.concat(Group.find(group_id).users.map(&:id))
          end
          @issue.watcher_user_ids = user_ids.uniq
        end
      end

      def get_delivery_histories
        @delivery_histories = DeliveryHistory.find_by_sql(
          ["select * from delivery_histories
                                    where issue_id = :issue_id
                                    order by updated_at desc",
            {:issue_id=>@issue.id}])
      end

      def get_destination_list
        begin
          role_ids = []
          User.current.roles_for_project(@issue.project).each do |r|
            role_ids.push r.id
          end

          # 複数のロールを保持していることを考慮
          @destination_list = nil
          role_ids.each do |role_id|
            list = DST_LIST['destination'][role_id][@issue.tracker_id]
            unless @destination_list.blank?
              list.each do |map|
                if @destination_list.index(map).blank?
                  @destination_list.push map
                end
              end
            else
              @destination_list = list
            end
          end
          # 新規登録画面で【システム】トラッカーのチケットを登録した場合、公共コモンズとRSSの配信先を除外する。
          if SYSTEM_TRACKER_ID.include?(@issue.tracker_id) && @issue.xml_body.blank? && @destination_list.present?
            removelist = []
            @destination_list.each do |map|
              unless (map["id"] == 1 || map["id"] == 9)
                removelist.push map 
              end
            end
            @destination_list = removelist
          end
        rescue => e
          # TODO
          # error 処理
          p $!
        end
      end

      # 外部配信要求受付け時のチケット更新用の項目値ハッシュの再構築処理
      # ==== Args
      # _issue_attr_ :: Issueの属性値ハッシュ
      # ==== Return
      # 再構築したIssueの属性値ハッシュ
      # ==== Raise
      def build_issue_attributes_for_request_delivery(issue_attr)
        if issue_attr['delivered_area'].present?
          code_str = issue_attr['delivered_area'].delete_if{|o| o.blank?}.join(',')
          issue_attr['delivered_area'] = code_str
        end
        issue_attr
      end

      # ZNET TOWN(住宅地図)サービス用に認証済みCookieを発行する
      # ==== Args
      # ==== Return
      # ==== Raise
      def set_znettown_cookie
        begin
          if ZNETTOWNService.enable?
            znt = ZNETTOWNService.login
            znt[:cookies][:cookie].each do |cookie_name, cookie_value|
              cookie_options = {
                :value => cookie_value,
                :expires => Time.at(znt[:cookies][:expires].to_i),
                :path => znt[:cookies][:path],
                #:secure => true,
                :httponly => false,
                :domain => nil,
              }
              cookies[cookie_name] = cookie_options
            end if znt
          end
        rescue ZNETTOWNService::LoginError
          nil # 何もしない
        end
      end

      # 受け取った住所からジオコーディングして座標値を取得する
      # ==== Args
      # ==== Return
      # ==== Raise
      def geocode(address)
        begin
          require 'rubygems'
          require 'net/http'
          require 'json'

          address = URI.encode(address)
          hash = Hash.new
          baseUrl = "http://maps.google.com/maps/api/geocode/json"
          reqUrl = "#{baseUrl}?address=#{address}&sensor=false&language=ja"
          response = Net::HTTP.get_response(URI.parse(reqUrl))
          status = JSON.parse(response.body)
          hash['lat'] = status['results'][0]['geometry']['location']['lat']
          hash['lng'] = status['results'][0]['geometry']['location']['lng']

          Rails.logger.info(hash)

          return hash

        rescue => e
          Rails.logger.info("geocode-error")
          Rails.logger.info(e.message)
          Rails.logger.info("geocode-error")
        end
      end

    end
  end
end

IssuesController.send(:include, Lgdis::IssuesControllerPatch)

