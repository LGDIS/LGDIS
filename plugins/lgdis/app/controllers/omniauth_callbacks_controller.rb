# -*- coding:utf-8 -*-
class OmniauthCallbacksController < AccountController

  # CSRF警告メッセージを抑制
  skip_before_filter :verify_authenticity_token

  # 認可結果(OK)コールバックアクション
  # ==== Args
  # ==== Return
  # ==== Raise
  def auth
    begin
      send(params[:provider].to_s.to_sym)
    rescue Lgdis::UserPatch::ClassMethods::InvalidAuthProvider, Lgdis::UserPatch::ClassMethods::ExternalAuthDisabled
      redirect_to signin_path
    end
  end

  # 認可結果(NG)コールバックアクション
  # ==== Args
  # ==== Return
  # ==== Raise
  def error
    redirect_to signin_path
  end

  private

  # Googleによる認可結果リダイレクトアクション
  # ==== Args
  # ==== Return
  # ==== Raise
  def google
    user = User.find_for_open_id(request.env["omniauth.auth"])
    redirect_to_result(user)
  end

  # Twitterによる認可結果リダイレクトアクション
  # ==== Args
  # ==== Return
  # ==== Raise
  def twitter
    user = User.find_for_oauth(request.env["omniauth.auth"])
    redirect_to_result(user)
  end

  # facebookによる認可結果リダイレクトアクション
  # ==== Args
  # ==== Return
  # ==== Raise
  def facebook
    user = User.find_for_oauth(request.env["omniauth.auth"])
    redirect_to_result(user)
  end

  # 共通ログイン・リダイレクト処理
  # ==== Args
  # _user_ :: ログインユーザ(User)
  # ==== Return
  # ==== Raise
  def redirect_to_result(user)
    if user.new_record?
      user.admin = false
      user.random_password
      user.register
      # Automatic activation
      user.activate
      user.last_login_on = Time.now
      if user.save(:validate => false)
        self.logged_user = user
        flash[:notice] = I18n.t("external_auth.result.success", :kind => user.provider)
        redirect_to :controller => 'my', :action => 'account'
      else
        flash[:error] = I18n.t("external_auth.result.failure", :kind => user.provider)
        error
        return
      end
    else
      session["devise.#{user.provider}_data"] = request.env["omniauth.auth"]
      successful_authentication(user)
      flash[:notice] =  I18n.t("external_auth.result.success", :kind => user.provider)
    end
    logger.info "Successful authentication for '#{user.login}' from #{request.remote_ip} via #{user.provider} at #{Time.now.utc}"
  end
end
