# encoding: utf-8
require_dependency 'issues_helper'

module Lgdis
  module IssuesHelperPatch
    # XMLデータ抽出文字列
    XML_VIEW_SAMPLING_XPATH = %{//xmlns:Item[.//text()[contains(.,"石巻")]]}.freeze
    STATUS = {'request'      => '配信要求中',
              'done'         => '配信完了',
              'done_test'    => '配信完了(通信試験モード)',
              'reject'       => '配信却下',
             }.freeze

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        require_dependency 'nokogiri'
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def check_permissions(issue)
        flag = false
        return false if issue.blank?
        User.current.roles_for_project(issue.project).each do |r|
          r.permissions.each do |st|
             flag = true if st.equal?(:allow_delivery)
          end
        end
        flag
      end

      def tm_fmt(time)
        time.strftime("%Y年%m月%d日 %H時%M分%S秒")
      end

      def conv_st(status)
        STATUS[status]
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

        out = "<input type='checkbox' id='#{name}_view_sampling' checked>" +
              "<label for='#{name}_view_sampling'>#{l(:button_xml_view_sampling)}</label>"

        # 抽出データ表示
        begin
          out << "<div class='xml_field #{name}' id='#{name}_sampling'>#{print_xml(xml_doc.xpath(XML_VIEW_SAMPLING_XPATH))}</div>"
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
