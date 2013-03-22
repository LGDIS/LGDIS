# encoding: utf-8
module Lgdis
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_layouts_base_html_head,
              :partial => 'layouts/view_layouts_base_html_head'
    render_on :view_account_login_bottom,
              :partial => 'account/view_account_login_bottom'
    render_on :view_issues_show_details_bottom,
              :partial => 'issues/view_issues_show_details_bottom'
    render_on :view_issues_show_description_bottom,
              :partial => 'issues/view_issues_show_description_bottom'
    render_on :view_issues_form_details_bottom,
              :partial => 'issues/view_issues_form_details_bottom'
    render_on :view_custom_fields_form_upper_box,
              :partial => 'custom_fields/view_custom_fields_form_upper_box'
    render_on :view_projects_show_right,
              :partial => 'projects/view_projects_show_right'
  end
end
