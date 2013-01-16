# encoding: utf-8
require_dependency 'issues_helper'

module Lgdis
  module IssuesHelperPatch
    # XML_
    XML_VIEW_SAMPLING_XPATH = %{//xmlns:Item[.//text()[contains(.,"石巻")]]}.freeze
    STATUS = {'request' => '配信要求中',
              'done'    => '配信完了',
              'reject'  => '配信却下',
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
        User.current.roles_for_project(issue.project).each do |r|
          r.permissions.each do |st|
             flag = true if st.equal?(:manage_issue_relations)
          end
        end
      end

      def tm_fmt(time)
        time.strftime("%Y年%m月%d日 %H時%M分%S秒")
      end

      def conv_st(status)
        STATUS[status]
      end

      def print_xml_field(xml)
        return "" if xml.blank?

        xml_doc = Nokogiri::XML(xml)
        return "" if xml_doc.blank?

        out = ""
        out << "<div class='xml_field' id='xml_field_sampling'>#{print_xml(xml_doc.xpath(XML_VIEW_SAMPLING_XPATH))}</div>"
        out << "<div class='xml_field' id='xml_field_all'>#{print_xml(xml_doc.children)}</div>"
        out
      end

      private

      def print_xml(node_set)
        out = ""
        node_set.each {|n| out << print_xml_node(n)}
        out
      end

      def print_xml_node(node)
        out = ""
        out << "<tr><td>#{node.text}</td></tr>" if node.text? && node.text.present?
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
