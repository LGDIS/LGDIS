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
        before_filter :get_delivery_histories, :only => [:show]
        before_filter :get_destination_list, :only => [:show]
        before_filter :set_issue_geography_data, :only => [:show]
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

      # google map 表示用のチケット地理データをインスタンス変数に格納します
      # ==== Args
      # ==== Return
      # ==== Raise
      def set_issue_geography_data
        issue_geographies =
          IssueGeography.find(:all,
                              :conditions=>["issue_id=?",params[:id].to_i])
        if issue_geographies.blank?
          points = [{"points" => [MAP_VALUES['ishi_lat'], MAP_VALUES['ishi_lon']],  "remarks" => MAP_VALUES['ishi_addr']}]
        else
          points = set_points(issue_geographies)
          lines  = set_lines(issue_geographies)
          polygons  = set_polygons(issue_geographies)
        end
        @points   = points
        @lines    = lines.blank? ? [] : lines
        @polygons = polygons.blank? ? [] : polygons
      end

      # google map 表示用のチケット地理データ(位置座標)を返却します
      # ==== Args
      # ==== Return
      # ==== Raise
      def set_points(issue_geographies)
        points=[]
        issue_geographies.each do |geo|
          unless geo.point.blank?
            point_remark = Hash.new
            point_ary = geo.point.gsub(/[()]/,"").split(',').map(&:to_f).reverse
            point_remark.store('points',point_ary)
            point_remark.store('remarks',geo.remarks)
            points.push point_remark
          end
        end
        return points
      end

      # google map 表示用のチケット地理データ(線形座標)を返却します
      # ==== Args
      # ==== Return
      # ==== Raise
      def set_lines(issue_geographies)
        lines=[]
        issue_geographies.each do |geo|
          unless geo.line.blank?
            line_remark = Hash.new
            line_ary = Array.new
            ary = geo.line.gsub(/[()]/,"").split(',').map(&:to_f).reverse
            num = 0
            ary.length.to_i.times do
              break if ary[num].blank?
              line_ary.push [ary[num], ary[num+1]]
              num += 2
            end
            line_remark.store('points',line_ary)
            line_remark.store('remarks',geo.remarks)
            lines.push line_remark
          end
        end
        return lines
      end

      # google map 表示用のチケット地理データ(多角形座標)を返却します
      # ==== Args
      # ==== Return
      # ==== Raise
      def set_polygons(issue_geographies)
        polygons=[]
        issue_geographies.each do |geo|
          unless geo.polygon.blank?
            polygon_remark = Hash.new
            polygon_ary = Array.new
            ary = geo.polygon.gsub(/[()]/,"").split(',').map(&:to_f).reverse
            num=0
            ary.length.to_i.times do
              break if ary[num].blank?
              polygon_ary.push [ary[num], ary[num+1]]
              num+=2
            end
            polygon_remark.store('points',polygon_ary)
            polygon_remark.store('remarks',geo.remarks)
            polygons.push polygon_remark
          end
        end
        return polygons
      end
    end
  end
end

IssuesController.send(:include, Lgdis::IssuesControllerPatch)
