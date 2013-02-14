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

      # create user authorized by google
      # ==== Args
      # _access_token_ :: openidアクセストークン
      # _signed_in_resource_ :: RESERVED
      # ==== Return
      # Userオブジェクト
      # ==== Raise
      # RuntimeError :: プラグイン設定で機能が無効化されているとき、想定しないプロバイダによる認可のとき
      def find_for_open_id(access_token, signed_in_resource=nil)
        raise "illegal authorizer: #{access_token.provider}" unless access_token.provider == 'google'
        raise "currently disabled sign-in via #{access_token.provider}" unless Setting.plugin_lgdis[:enable_external_auth]
        loginid = access_token.info['email']
        uid = access_token.uid
        return authorized_user(loginid, uid, GOOGLE_IDENTIFIER)
      end

      # create user authorized by twitter/facebook
      # ==== Args
      # _access_token_ :: oauthアクセストークン
      # _signed_in_resource_ :: RESERVED
      # ==== Return
      # Userオブジェクト
      # ==== Raise
      # RuntimeError :: プラグイン設定で機能が無効化されているとき、想定しないプロバイダによる認可のとき
      def find_for_oauth(access_token, signed_in_resource=nil)
        raise "currently disabled sign-in via #{access_token.provider}" unless Setting.plugin_lgdis[:enable_external_auth]
        case access_token.provider
        when 'twitter'
          return authorized_user("@" + access_token.info.nickname, access_token.uid, TWITTER_IDENTIFIER)
        when 'facebook'
          return authorized_user(access_token.info.name, access_token.uid, FACEBOOK_IDENTIFIER)
        end
        raise "illegal authorizer: #{access_token.provider}"
      end

      private

      # 認可されたユーザを取得する(存在しなければ新規登録もする)
      # ==== Args
      # _loginid_ :: ログインユーザID(String) ※"@user"や"Yamada Kazuo"などのユーザ名
      # _uid_ :: ログインユーザ識別子(String)
      # _provider_ :: 認可プロバイダ名(String)
      # ==== Return
      # Userオブジェクト
      # ==== Raise
      def authorized_user(loginid, uid, provider)
        user = User.where(:provider => provider, :uid => uid).first
        unless user
          user = User.new(:language => Setting.default_language, :mail_notification => Setting.default_notification_option)
          user.provider = provider
          user.uid = uid
          user.login = loginid
          user.admin = false
          user.password, user.password_confirmation = [nil, nil]
          user.save!(:validate => false)
        end
        return user
      end
    end

    module InstanceMethods
    end
  end
end

User.send(:include, Lgdis::UserPatch)
