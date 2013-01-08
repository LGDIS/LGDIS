# encoding: utf-8
module Lgdis
  class ViewHooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom,
              :partial => 'issues/view_issues_form_details_bottom'
  end
end