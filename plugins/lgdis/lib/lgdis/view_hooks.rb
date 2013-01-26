# encoding: utf-8
module Lgdis
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_details_bottom,
              :partial => 'issues/view_issues_show_details_bottom'
    render_on :view_issues_show_description_bottom,
              :partial => 'issues/view_issues_show_description_bottom'
    render_on :view_issues_form_details_bottom,
              :partial => 'issues/view_issues_form_details_bottom'
    render_on :view_layouts_base_html_head,
              :partial => 'layouts/view_layouts_base_html_head'
  end
end
