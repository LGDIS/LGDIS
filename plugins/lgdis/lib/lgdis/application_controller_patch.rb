# encoding: utf-8
require_dependency 'application_controller'

module Lgdis
  module ApplicationControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        alias_method_chain :require_login, :external_auth
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      # memcacheされた値を取得・加工
      # === Args
      # _key_name_ :: キャッシュされているハッシュのキー名
      # === Return
      # _constant_list_ :: {code => name}
      # ==== Raise
      def get_cache(key_name)
        constant_list = {}
        constant = Rails.cache.read(key_name)
        constant.each do |c|
          constant_list[c[0]] = c[1]["name"]
        end
        return constant_list
      end
      #
      def require_login_with_external_auth
        return false if Setting.plugin_lgdis[:enable_external_auth]
        require_login_without_external_auth
      end
    end
  end
end

ApplicationController.send(:include, Lgdis::ApplicationControllerPatch)
