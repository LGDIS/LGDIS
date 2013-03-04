# encoding: utf-8
require_dependency 'welcome_controller'

module Lgdis
  module WelcomeControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        before_filter :redirect_to__projects, :only => [:index]
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      private

      # プロジェクト一覧画面にリダイレクト
      # ==== Args
      # ==== Return
      # ==== Raise
      def redirect_to__projects
        redirect_to controller: "projects", action: "index"
      end

    end
  end
end

WelcomeController.send(:include, Lgdis::WelcomeControllerPatch)

