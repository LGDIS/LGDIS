# encoding: utf-8
module Lgdis
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_details_bottom,
              :partial => 'issues/view_issues_form_details_bottom'
    render_on :view_issues_show_description_bottom,
              :partial => 'issues/view_issues_form_description_bottom'
  end
end
