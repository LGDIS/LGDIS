# encoding: utf-8
module Lgdis
  class ShowViewHooks < Redmine::Hook::ViewListener
    view_hook_list = [
      :view_account_left_bottom,
      :view_account_right_bottom,
      :view_account_login_top,
      :view_account_login_bottom,
      :view_custom_fields_form_upper_box,
      :view_custom_fields_form_issue_custom_field,
      :view_issue_statuses_form,
      :view_issues_bulk_edit_details_bottom,
      :view_issues_edit_notes_bottom,
      :view_issues_form_details_bottom,
      :view_issues_history_journal_bottom,
      :view_issues_show_details_bottom,
      :view_issues_sidebar_issues_bottom,
      :view_issues_sidebar_planning_bottom,
      :view_issues_sidebar_queries_bottom,
      :view_issues_context_menu_start,
      :view_issues_context_menu_end,
      :view_issues_new_top,
      :view_issues_show_description_bottom,
      :view_issues_move_bottom,
      :view_journals_notes_form_after_notes,
      :view_journals_update_rjs_bottom,
      :view_layouts_base_body_bottom,
      :view_layouts_base_content,
      :view_layouts_base_html_head,
      :view_layouts_base_sidebar,
      :view_my_account,
      :view_my_account_contextual,
      :view_projects_form,
      :view_projects_roadmap_version_bottom,
      :view_projects_settings_members_table_header,
      :view_projects_settings_members_table_row,
      :view_projects_show_left,
      :view_projects_show_right,
      :view_projects_show_sidebar_bottom,
      :view_repositories_show_contextual,
      :view_timelog_edit_form_bottom,
      :view_settings_general_form,
      :view_users_memberships_table_header,
      :view_users_memberships_table_row,
      :view_users_form,
      :view_versions_show_bottom,
      :view_versions_show_contextual,
      :view_welcome_index_left,
      :view_welcome_index_right
      ]
    
    view_hook_list.each {|view_hook|
      define_method(view_hook.to_s) do |context={ }|
        html = ''
        html << "<font size='-3' color='red'>[view hook:#{__method__}]</font>"
        html
      end
    }
  end
  
end