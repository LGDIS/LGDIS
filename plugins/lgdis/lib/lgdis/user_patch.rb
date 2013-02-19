# -*- coding: utf-8 -*-
module Lgdis
  module UserPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
      end
    end

    module ClassMethods
      # 認可プロバイダ識別子
      GOOGLE_IDENTIFIER = 'google'
      TWITTER_IDENTIFIER = 'twitter'
      FACEBOOK_IDENTIFIER = 'facebook'

      class InvalidAuthProvider < StandardError; end
      class ExternalAuthDisabled < StandardError; end

      # OpenIDで認可されたユーザを取得する
      # ==== Args
      # _access_token_ :: openidアクセストークン
      # _signed_in_resource_ :: RESERVED
      # ==== Return
      # Userオブジェクト ※新規ユーザの場合は未save
      # ==== Raise
      # InvalidAuthProvider :: 想定しないプロバイダによる認可のとき
      # ExternalAuthDisabled :: プラグイン設定で機能が無効化されているとき
      def find_for_open_id(access_token, signed_in_resource=nil)
        raise InvalidAuthProvider, "illegal authorizer: #{access_token.provider}" unless access_token.provider == 'google'
        if !(Setting.plugin_lgdis.present? && Setting.plugin_lgdis[:enable_external_auth])
          raise ExternalAuthDisabled, "currently disabled sign-in via #{access_token.provider}"
        end
        user = self.find_or_initialize_by_provider_and_uid(GOOGLE_IDENTIFIER, access_token.uid)
        user.login = access_token.info['email']
        return user
      end

      # OAuthで認可されたユーザを取得する
      # ==== Args
      # _access_token_ :: oauthアクセストークン
      # _signed_in_resource_ :: RESERVED
      # ==== Return
      # Userオブジェクト ※新規ユーザの場合は未save
      # ==== Raise
      # InvalidAuthProvider :: 想定しないプロバイダによる認可のとき
      # ExternalAuthDisabled :: プラグイン設定で機能が無効化されているとき
      def find_for_oauth(access_token, signed_in_resource=nil)
        if !(Setting.plugin_lgdis.present? && Setting.plugin_lgdis[:enable_external_auth])
          raise ExternalAuthDisabled, "currently disabled sign-in via #{access_token.provider}"
        end
        case access_token.provider
        when 'twitter'
          user = self.find_or_initialize_by_provider_and_uid(TWITTER_IDENTIFIER, access_token.uid)
          user.login = "@" + access_token.info.nickname
          return user
        when 'facebook'
          user = self.find_or_initialize_by_provider_and_uid(FACEBOOK_IDENTIFIER, access_token.uid)
          user.login = access_token.info.name
          return user
        end
        raise InvalidAuthProvider, "illegal authorizer: #{access_token.provider}"
      end

    end

    module InstanceMethods
    end
  end
end

User.send(:include, Lgdis::UserPatch)
