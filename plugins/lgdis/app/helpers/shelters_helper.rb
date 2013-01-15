# encoding: utf-8
module SheltersHelper
  include ApplicationHelper

=begin
  def label_tag_for_field_of(key, options = {}, &block)
    label = options[:label].is_a?(Symbol) ? l(options[:label]) : options[:label]
    label ||= localize_scoped(key)
    label += (options.delete(:required) ? content_tag("span", " *", :class => "required"): "")
    
    content_tag("label", :class => options[:class]) do
      yield key, label.html_safe
    end
  end
=end
  
  # スコープを適用したローカライズ処理
  # "field_" + キー文字列 でローカライズします。
  # コントローラ名をスコープに設定してローカライズできない場合は、スコープ無しのローカライズ結果を返却します。
  # ==== Args
  # _key_ :: キー文字列
  # _params[:controller]_ :: コントローラ名
  # ==== Return
  # ローカライズ文字列
  # ==== Raise
  def localize_scoped(key)
    begin
      localized = l(("field_"+key.to_s).to_sym, :scope => params[:controller], :raise => true)
    rescue
    end
    localized ||= l(("field_"+key.to_s).to_sym)
  end

  # html_options指定のpタグで囲み、ブロックを実行します。
  # {|key, label| ... }
  # key:キー文字列
  # label:
  #   options[:label]の指定がある場合は、指定値を設定
  #   上記以外は、localize_scoped(key)を実行結果を設定
  #   また、いずれの場合も、options[:required] == true の場合、"*"(class = "required")を付与する。
  # ==== Args
  # _key_ :: キー文字列
  # _options_ :: オプションハッシュ値
  # _html_options_ :: HTMLオプションハッシュ値
  # _&block_ :: ブロック値
  # ==== Return
  # ==== Raise
  def field_for(key, options = {}, html_options = {}, &block)
    label = options[:label].is_a?(Symbol) ? l(options[:label]) : options[:label]
    label ||= localize_scoped(key)
    label += (options.delete(:required) ? content_tag("span", " *", :class => "required"): "")
    
    content_tag("p", html_options) do
      yield key, label.html_safe
    end
  end
end
