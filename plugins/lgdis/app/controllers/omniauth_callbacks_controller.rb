# -*- coding:utf-8 -*-
class OmniauthCallbacksController < ApplicationController
  # 認可
  # ==== Args
  # ==== Return
  # ==== Raise
  def auth
    send(params[:provider].to_s.to_sym)
  end

  def error
    render_404
  end

  private

  # Googleによる認可結果リダイレクトアクション
  # ==== Args
  # ==== Return
  # ==== Raise
  def google
    @user = User.find_for_open_id(request.env["omniauth.auth"])
    redirect_to_result('google')
  end

  # Twitterによる認可結果リダイレクトアクション
  # ==== Args
  # ==== Return
  # ==== Raise
  def twitter
    @user = User.find_for_oauth(request.env["omniauth.auth"])
    redirect_to_result('twitter')
  end

  # facebookによる認可結果リダイレクトアクション
  # ==== Args
  # ==== Return
  # ==== Raise
  def facebook
    @user = User.find_for_oauth(request.env["omniauth.auth"])
    redirect_to_result('facebook')
  end

  # 共通リダイレクト処理
  # ==== Args
  # _provider_ :: 認可プロバイダ名(String)
  # ==== Return
  # ==== Raise
  def redirect_to_result(provider)
    if @user && @user.persisted?
      @user.update_attribute(:last_login_on, Time.now)
      self.logged_user = @user
      logger.info "Successful authentication for '#{@user.login}' from #{request.remote_ip} via #{provider} at #{Time.now.utc}"
      flash[:notice] =  I18n.t "external_auth.result.success", :kind => provider
      redirect_back_or_default :controller => 'my', :action => 'page'
    else
      session["devise.#{provider}_data"] = request.env["omniauth.auth"]
      redirect_to :action => :index
    end
  end
end
