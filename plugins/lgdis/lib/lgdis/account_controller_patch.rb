# encoding: utf-8
require_dependency 'account_controller'

module Lgdis
  module AccountControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        alias_method_chain :register_by_email_activation, :custom_message
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      private
      # Register a user for email activation.
      #
      # Pass a block for behavior when a user fails to save
      def register_by_email_activation_with_custom_message(user, &block)
        token = Token.new(:user => user, :action => "register")
        if user.save and token.save
          Mailer.register(token).deliver
          flash[:notice] = l(:lgdis_notice_account_register_done)
          redirect_to signin_path
        else
          yield if block_given?
        end
      end
    end
  end
end

AccountController.send(:include, Lgdis::AccountControllerPatch)
