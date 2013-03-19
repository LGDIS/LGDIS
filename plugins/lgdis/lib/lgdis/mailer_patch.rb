# -*- coding: utf-8 -*-
require_dependency 'mailer'

module Lgdis
  module MailerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        alias_method_chain :register, :custom_message
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def register_with_custom_message(token)
        set_language_if_valid(token.user.language)
        @token = token
        @url = url_for(:controller => 'account', :action => 'activate', :token => token.value)
        mail :to => token.user.mail,
          :subject => l(:lgdis_mail_subject_register, Setting.app_title)
      end
    end
  end
end

Mailer.send(:include, Lgdis::MailerPatch)
