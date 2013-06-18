# encoding: utf-8
require_dependency 'watchers_helper'

module Lgdis
  module WatchersHelperPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def project_member_groups(project)
        groups = Project.find(project).principals.find(:all, :conditions => [ 'type = ?', 'Group' ], :order => 'lastname')
        return groups
      end

      def watcher_users_group(object)
        watcher_users_groups = []
        object.watcher_users.each do |user|
          watcher_users_groups.concat(user.groups.map {|group| group.id })
        end
        return watcher_users_groups.uniq
      end

      def watchers_group_list(object)
        member_groups = project_member_groups(object.project)
        watcher_groups = watcher_users_group(object)
        if member_groups.present? && watcher_groups.present?
          remove_allowed = User.current.allowed_to?("delete_#{object.class.name.underscore}_watchers".to_sym, object.project)
          content = ''.html_safe
          member_groups.each do |group|
            if watcher_groups.include?(group.id)
              s = ''.html_safe
              s << group.lastname
              user_ids = group.users.map(&:id) & object.watcher_users.map(&:id)
              if remove_allowed
                url = {:controller => 'watchers',
                       :action => 'destroy',
                       :object_type => object.class.to_s.underscore,
                       :object_id => object.id,
                       :watcher_groups => {"group_ids"=>[group.id]}}
                s << ' '
                s << link_to(image_tag('delete.png'), url,
                             :remote => true, :method => 'post', :style => "vertical-align: middle", :class => "delete")
              end
              content << content_tag('li', s)
            end
          end
        end
        content.present? ? content_tag('ul', content) : content
      end

      def watcher_groups_checkboxes(project)
        member_groups = project_member_groups(project)
        if member_groups.present?
          content = ''.html_safe
          content << content_tag('label', l(:label_issue_watcher_groups))
          member_groups.each do |group|
            s = check_box_tag "watcher_groups[group_ids][]", group.id, false, :id => nil
            content << content_tag('label', "#{s} #{h(group.lastname)}".html_safe,
                                   :id => "issue_watcher_group_ids_#{group.id}",
                                   :class => "floating")
          end
        end
        content
      end

      def addable_watcher_groups_checkboxes(object)
        member_groups = project_member_groups(object.project)
        watcher_groups = watcher_users_group(object)
        if member_groups.present?
          content = ''.html_safe
          member_groups.each do |group|
            unless watcher_groups.include?(group.id)
              s = check_box_tag "watcher_groups[group_ids][]", group.id, false, :id => nil
              content << content_tag('label', "#{s} #{h(group.lastname)}".html_safe,
                                     :id => "issue_watcher_group_ids_#{group.id}")
            end
          end
        end
        if content.present?
          s = submit_tag( l(:button_add), :name => nil, :onclick => "hideModal(this);" )
          s << submit_tag( l(:button_cancel), :name => nil, :onclick => "hideModal(this);", :type => 'button' )
        else
          content = content_tag('label', l(:no_addable_issue_watcher_groups))
          s = submit_tag( l(:button_back), :name => nil, :onclick => "hideModal(this);", :type => 'button' )
        end
        content = content_tag('div', content, :id => "users_for_watcher")
        content << content_tag('p', "#{s}".html_safe, :class => "buttons")
        content
      end
    end
  end
end
WatchersHelper.send(:include, Lgdis::WatchersHelperPatch)
