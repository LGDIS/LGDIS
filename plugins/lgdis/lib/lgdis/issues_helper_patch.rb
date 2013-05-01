# encoding: utf-8
require_dependency 'issues_helper'

module Lgdis
  module IssuesHelperPatch

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        require_dependency 'nokogiri'
        alias_method_chain :render_custom_fields_rows, :hr
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      # チケット照会画面カスタムフィールド表示処理
      # 罫線(tableレイアウトのため、tdの背景色指定)を追加するように変更（カスタムフィールドが存在する場合のみ）
      # ==== Args
      # _issue_ :: Issueオブジェクト
      # ==== Return
      # html
      # ==== Raise
      def render_custom_fields_rows_with_hr(issue)
        return if issue.custom_field_values.empty?
        s = "<tr class='like_hr'><td colspan=4></td></tr>\n"
        s += render_custom_fields_rows_without_hr(issue)
        s.html_safe
      end

      def tm_fmt(time)
        time.strftime("%Y年%m月%d日 %H時%M分%S秒") if time.present?
      end
      
      def tm_fmt_delivery(time)
        time.strftime("%Y/%m/%d %H:%M:%S") if time.present?
      end

      # XML型フィールドの画面表示部生成
      # ==== Args
      # _xml_ :: XML型フィールド値
      # _name_ :: 項目名
      # ==== Return
      # 画面表示部
      # ==== Raise
      def print_xml_field(xml, name)
        return "" if xml.blank?

        xml_doc = Nokogiri::XML(xml)
        return "" if xml_doc.blank?

        # Sentence 以降の弟をnode を削除
        nodes = xml_doc.xpath('//Sentence/following-sibling::node()')
        unless nodes.blank?
          nodes.each do |node|
            (xml_doc/"#{node.name}").remove
          end
        end
        
        # XMLの対象地域データ抽出文字列の設定
        city_name = I18n.t("target_municipality")
        xml_sampling = %{//xmlns:Item[.//text()[contains(.,"#{city_name}")]]}.freeze

        out = "<input type='checkbox' id='#{name}_view_sampling' checked>" +
              "<label for='#{name}_view_sampling'>#{l(:button_xml_view_sampling)}</label>"

        # 抽出データ表示
        begin
          out << "<div class='xml_field #{name}' id='#{name}_sampling'>#{print_xml(xml_doc.xpath(xml_sampling))}</div>"
        rescue
          out << ""
        end

        # 全データ表示
        out << "<div class='xml_field #{name}' id='#{name}_all'>#{print_xml(xml_doc.children)}</div>"

        out << javascript_tag(<<-EOF)
          $(function(){
            $("##{name}_view_sampling").change(function(){
              $("##{name}_all").toggle(!this.checked);
              $("##{name}_sampling").toggle(this.checked);
            }).change();
          });
        EOF

        out.html_safe
      end

      private

      # XML型フィールドの画面表示部生成（ノードセット）
      # ==== Args
      # _node_set_ :: ノードセット
      # ==== Return
      # 画面表示部
      # ==== Raise
      def print_xml(node_set)
        out = ""
        # ノードセット分、print_xml_node実行
        node_set.each {|n| out << print_xml_node(n)}
        out
      end

      # XML型フィールドの画面表示部生成（ノード）
      # ==== Args
      # _node_set_ :: ノード
      # ==== Return
      # 画面表示部
      # ==== Raise
      def print_xml_node(node)
        out = ""
        # テキストノードで、値が存在すれば表示
        out << "<tr><td>#{node.text}</td></tr>" if node.text? && node.text.present?
        
        # 子ノード群が存在する場合は、print_xml実行（再帰処理）
        out << print_xml(node.children) if node.children.present?

        # 値が存在しない階層（タグ）は、囲い（htmlのtableタグ）を省略し、不要な囲みを減らす
        # ⇒カレントノードの直下の子ノード群の値で、有効値（（改行、空白）以外の文字）が存在する場合のみtableタグで囲う
        if node.xpath(%{./*/text()[string-length(normalize-space()) > 0]}).size > 0
          "<tr><td><table>#{out}</table></td></tr>"
        else
          out
        end
      end
    end
  end
end

IssuesHelper.send(:include, Lgdis::IssuesHelperPatch)
