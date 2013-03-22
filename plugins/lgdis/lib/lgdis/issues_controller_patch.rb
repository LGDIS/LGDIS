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
        before_filter :init, :only => [:show, :request_delivery]
        before_filter :get_delivery_histories, :only => [:show, :request_delivery]
        before_filter :get_destination_list, :only => [:show, :request_delivery]
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      class ParamsException < StandardError; end
      class RecordInvalid < StandardError; end

      # 外部配信要求処理(手動配信)
      # 外部配信要求受付け処理を行います
      # ==== Args
      # ==== Return
      # ==== Raise
      def request_delivery
        issue_map = params[:issue]
        # 情報の配信対象地域のコード値の配列を","区切のstring に変換
        issue_map = build_issue_attributes_for_request_delivery(issue_map)

        @ext_out_target = params[:ext_out_target]
        begin
          raise ParamsException, l(:notice_delivery_unselected) if @ext_out_target.blank?
          ActiveRecord::Base.transaction do
            # イベント・お知らせ のxml_body 部を生成
            if DST_LIST['general_info_ids'].include?(@issue.tracker_id) &&
                @ext_out_target.include?(DST_LIST['delivery_place'][1]['id'].to_s)
              issue_map.store('xml_body', @issue.create_commons_event_body)
            end

            @issue.update_attributes(issue_map)
            error_messages = @issue.errors.full_messages.join("\n")
            raise RecordInvalid, error_messages if error_messages.present?

            deliver_historires =  DeliveryHistory.create_for_history(@issue, @ext_out_target)
            error_messages = error_messages_for_request_delivery(deliver_historires)
            raise RecordInvalid, error_messages if error_messages.present?

            # チケットへの配信要求履歴書き込み
            ExtOut::JobBase.register_issue_journal_request(@issue, @ext_out_target, User.current)

            flash[:notice] = l(:notice_delivery_request_successful)
            redirect_back_or_default({:action     => 'show',
                                      :id         => @issue})
            return
          end
        rescue RecordInvalid => e
          flash.now[:error] = e.message.gsub(/\r\n|\r|\n/, "<br />")
        rescue ParamsException => e
          flash.now[:error] = e.message
        end
        # @issueを再構築
        find_issue
        @issue.assign_attributes(issue_map)
        # IssuesController#showメソッドに委譲
        show
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

      def get_delivery_histories
        @delivery_histories = DeliveryHistory.find_by_sql(
          ["select * from delivery_histories
                                    where issue_id = :issue_id",
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
        rescue => e
          # TODO
          # error 処理
          p $!
        end
      end

      # 外部配信要求受付け時のエラーメッセージ作成処理
      # ==== Args
      # _objects_ :: 配信履歴配列
      # ==== Return
      # エラーメッセージ
      # ==== Raise
      def error_messages_for_request_delivery(*objects)
        messages = ""
        errors   = nil
        objects.each do |object|
          errors = object.map do |o|
            o.errors.full_messages.map do |m|
              "#{l('delivery_place')}が\"#{DST_LIST['delivery_place'][o.delivery_place_id]['name']}\"の場合は、#{m}"
            end
          end.flatten
        end
        if errors.any?
          errors.each do |error|
            messages << "#{error}\n"
          end
        end
        return messages
      end

      # 外部配信要求受付け時のチケット更新用の項目値ハッシュの再構築処理
      # ==== Args
      # _issue_attr_ :: Issueの属性値ハッシュ
      # ==== Return
      # 再構築したIssueの属性値ハッシュ
      # ==== Raise
      def build_issue_attributes_for_request_delivery(issue_attr)
        if issue_attr['delivered_area'].present?
          code_str = issue_attr['delivered_area'].join(',')
          issue_attr['delivered_area'] = code_str
        end
        issue_attr
      end

    end
  end
end

IssuesController.send(:include, Lgdis::IssuesControllerPatch)

