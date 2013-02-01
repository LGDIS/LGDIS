# encoding: utf-8
require_dependency 'issues_controller'

module Lgdis
  module IssuesControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        before_filter :build_new_issue_geography_from_params, :only => [:create]
        before_filter :get_delivery_histories,
                      :only => [:show]
        before_filter :get_destination_list,
                      :only => [:show]
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      private

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
        @delivery_history = DeliveryHistory.find_by_sql(
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
    end
  end
end

IssuesController.send(:include, Lgdis::IssuesControllerPatch)
