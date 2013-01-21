# encoding: utf-8
module SheltersHelper
  include ApplicationHelper
  
  # スコープを適用したローカライズ処理
  # "field_" + キー文字列 でローカライズします。
  # コントローラ名をスコープに設定してローカライズできない場合は、スコープ無しのローカライズ結果を返却します。
  # ==== Args
  # _key_ :: キー文字列
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
  # key :: キー文字列
  # html_safe ::
  #   optionsに:labelの指定がある場合は、指定値を設定
  #   上記以外は、localize_scoped(key)を実行結果を設定
  #   また、いずれの場合も、optionsの:required が true の場合、"*"(class = "required")を付与する。
  # ==== Args
  # _key_ :: キー文字列
  # _options_ :: オプションハッシュ値
  # _html_options_ :: HTMLオプションハッシュ値
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
  
  # 避難所一覧画面一括更新用エラーメッセージ作成処理
  # ==== Args
  # _objects_ :: 避難所情報配列
  # ==== Return
  # エラーメッセージ
  # ==== Raise
  def error_messages_for_shelters(*objects)
    html   = ""
    errors = nil
    objects.each do |object|
      errors = object.map do |o|
        o.errors.full_messages.map do |m|
          "#{l('shelters.field_shelter_code')}\"#{o.shelter_code}\"の#{m}"
        end
      end.flatten
    end
    if errors.any?
      html << "<div id='errorExplanation'><ul>\n"
      errors.each do |error|
        html << "<li>#{h error}</li>\n"
      end
      html << "</ul></div>\n"
    end
    html.html_safe
  end  
end
