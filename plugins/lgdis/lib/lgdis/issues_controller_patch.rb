# encoding: utf-8
require_dependency 'issues_controller'

module Lgdis
  module IssuesControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        before_filter :get_delivery_histories,
                      :only => [:index,:show]
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      private

      def get_delivery_histories
        @status = DeliveryHistory.all
      end
    end
  end
end

IssuesController.send(:include, Lgdis::IssuesControllerPatch)
