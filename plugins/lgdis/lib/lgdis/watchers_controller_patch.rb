# encoding: utf-8
require_dependency 'watchers_controller'

module Lgdis
  module WatchersControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        alias_method_chain :create, :groups
        alias_method_chain :append, :groups
        alias_method_chain :destroy, :groups
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      private

      def create_with_groups
        if params[:watcher_groups].is_a?(Hash) && request.post?
          user_ids = []
          group_ids = params[:watcher_groups][:group_ids].presence || []
          group_ids.each do |group_id|
            user_ids.concat(Group.find(group_id).users.map(&:id))
          end
          user_ids.uniq.each do |user_id|
            Watcher.create(:watchable => @watched, :user_id => user_id)
          end
        end
        respond_to do |format|
          format.html { redirect_to_referer_or {render :text => 'Watcher added.', :layout => true}}
          format.js
        end
      end

      def append_with_groups
        if params[:watcher_groups].is_a?(Hash) && request.post?
          user_ids = []
          group_ids = params[:watcher_groups][:group_ids].presence || []
          group_ids.each do |group_id|
            user_ids.concat(Group.find(group_id).users.map(&:id))
          end
          @users = User.active.find_all_by_id(user_ids.uniq)
        end
      end

      def destroy_with_groups
        if params[:watcher_groups].is_a?(Hash) && request.post?
          user_ids = []
          group_ids = params[:watcher_groups][:group_ids].presence || []
          group_ids.each do |group_id|
            user_ids.concat(Group.find(group_id).users.map(&:id))
          end
          user_ids.uniq.each do |user_id|
            @watched.set_watcher(User.find(user_id), false)
          end
        end
        respond_to do |format|
          format.html { redirect_to :back }
          format.js
        end
      end

    end
  end
end

WatchersController.send(:include, Lgdis::WatchersControllerPatch)

