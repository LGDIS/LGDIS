# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121026003537) do

  create_table "attachments", :force => true do |t|
    t.integer  "container_id"
    t.string   "container_type", :limit => 30
    t.string   "filename",                     :default => "", :null => false
    t.string   "disk_filename",                :default => "", :null => false
    t.integer  "filesize",                     :default => 0,  :null => false
    t.string   "content_type",                 :default => ""
    t.string   "digest",         :limit => 40, :default => "", :null => false
    t.integer  "downloads",                    :default => 0,  :null => false
    t.integer  "author_id",                    :default => 0,  :null => false
    t.datetime "created_on"
    t.string   "description"
  end

  add_index "attachments", ["author_id"], :name => "index_attachments_on_author_id"
  add_index "attachments", ["container_id", "container_type"], :name => "index_attachments_on_container_id_and_container_type"
  add_index "attachments", ["created_on"], :name => "index_attachments_on_created_on"

  create_table "auth_sources", :force => true do |t|
    t.string  "type",              :limit => 30, :default => "",    :null => false
    t.string  "name",              :limit => 60, :default => "",    :null => false
    t.string  "host",              :limit => 60
    t.integer "port"
    t.string  "account"
    t.string  "account_password",                :default => ""
    t.string  "base_dn"
    t.string  "attr_login",        :limit => 30
    t.string  "attr_firstname",    :limit => 30
    t.string  "attr_lastname",     :limit => 30
    t.string  "attr_mail",         :limit => 30
    t.boolean "onthefly_register",               :default => false, :null => false
    t.boolean "tls",                             :default => false, :null => false
    t.string  "filter"
    t.integer "timeout"
  end

  add_index "auth_sources", ["id", "type"], :name => "index_auth_sources_on_id_and_type"

  create_table "boards", :force => true do |t|
    t.integer "project_id",                      :null => false
    t.string  "name",            :default => "", :null => false
    t.string  "description"
    t.integer "position",        :default => 1
    t.integer "topics_count",    :default => 0,  :null => false
    t.integer "messages_count",  :default => 0,  :null => false
    t.integer "last_message_id"
    t.integer "parent_id"
  end

  add_index "boards", ["last_message_id"], :name => "index_boards_on_last_message_id"
  add_index "boards", ["project_id"], :name => "boards_project_id"

  create_table "changes", :force => true do |t|
    t.integer "changeset_id",                               :null => false
    t.string  "action",        :limit => 1, :default => "", :null => false
    t.text    "path",                                       :null => false
    t.text    "from_path"
    t.string  "from_revision"
    t.string  "revision"
    t.string  "branch"
  end

  add_index "changes", ["changeset_id"], :name => "changesets_changeset_id"

  create_table "changeset_parents", :id => false, :force => true do |t|
    t.integer "changeset_id", :null => false
    t.integer "parent_id",    :null => false
  end

  add_index "changeset_parents", ["changeset_id"], :name => "changeset_parents_changeset_ids"
  add_index "changeset_parents", ["parent_id"], :name => "changeset_parents_parent_ids"

  create_table "changesets", :force => true do |t|
    t.integer  "repository_id", :null => false
    t.string   "revision",      :null => false
    t.string   "committer"
    t.datetime "committed_on",  :null => false
    t.text     "comments"
    t.date     "commit_date"
    t.string   "scmid"
    t.integer  "user_id"
  end

  add_index "changesets", ["committed_on"], :name => "index_changesets_on_committed_on"
  add_index "changesets", ["repository_id", "revision"], :name => "changesets_repos_rev", :unique => true
  add_index "changesets", ["repository_id", "scmid"], :name => "changesets_repos_scmid"
  add_index "changesets", ["repository_id"], :name => "index_changesets_on_repository_id"
  add_index "changesets", ["user_id"], :name => "index_changesets_on_user_id"

  create_table "changesets_issues", :id => false, :force => true do |t|
    t.integer "changeset_id", :null => false
    t.integer "issue_id",     :null => false
  end

  add_index "changesets_issues", ["changeset_id", "issue_id"], :name => "changesets_issues_ids", :unique => true

  create_table "comments", :force => true do |t|
    t.string   "commented_type", :limit => 30, :default => "", :null => false
    t.integer  "commented_id",                 :default => 0,  :null => false
    t.integer  "author_id",                    :default => 0,  :null => false
    t.text     "comments"
    t.datetime "created_on",                                   :null => false
    t.datetime "updated_on",                                   :null => false
  end

  add_index "comments", ["author_id"], :name => "index_comments_on_author_id"
  add_index "comments", ["commented_id", "commented_type"], :name => "index_comments_on_commented_id_and_commented_type"

  create_table "constants", :force => true do |t|
    t.string   "kind1"
    t.string   "kind2"
    t.string   "kind3"
    t.string   "text"
    t.string   "value"
    t.integer  "_order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "custom_fields", :force => true do |t|
    t.string  "type",            :limit => 30, :default => "",    :null => false
    t.string  "name",            :limit => 30, :default => "",    :null => false
    t.string  "field_format",    :limit => 30, :default => "",    :null => false
    t.text    "possible_values"
    t.string  "regexp",                        :default => ""
    t.integer "min_length",                    :default => 0,     :null => false
    t.integer "max_length",                    :default => 0,     :null => false
    t.boolean "is_required",                   :default => false, :null => false
    t.boolean "is_for_all",                    :default => false, :null => false
    t.boolean "is_filter",                     :default => false, :null => false
    t.integer "position",                      :default => 1
    t.boolean "searchable",                    :default => false
    t.text    "default_value"
    t.boolean "editable",                      :default => true
    t.boolean "visible",                       :default => true,  :null => false
    t.boolean "multiple",                      :default => false
  end

  add_index "custom_fields", ["id", "type"], :name => "index_custom_fields_on_id_and_type"

  create_table "custom_fields_projects", :id => false, :force => true do |t|
    t.integer "custom_field_id", :default => 0, :null => false
    t.integer "project_id",      :default => 0, :null => false
  end

  add_index "custom_fields_projects", ["custom_field_id", "project_id"], :name => "index_custom_fields_projects_on_custom_field_id_and_project_id"

  create_table "custom_fields_trackers", :id => false, :force => true do |t|
    t.integer "custom_field_id", :default => 0, :null => false
    t.integer "tracker_id",      :default => 0, :null => false
  end

  add_index "custom_fields_trackers", ["custom_field_id", "tracker_id"], :name => "index_custom_fields_trackers_on_custom_field_id_and_tracker_id"

  create_table "custom_values", :force => true do |t|
    t.string  "customized_type", :limit => 30, :default => "", :null => false
    t.integer "customized_id",                 :default => 0,  :null => false
    t.integer "custom_field_id",               :default => 0,  :null => false
    t.text    "value"
  end

  add_index "custom_values", ["custom_field_id"], :name => "index_custom_values_on_custom_field_id"
  add_index "custom_values", ["customized_type", "customized_id"], :name => "custom_values_customized"

  create_table "documents", :force => true do |t|
    t.integer  "project_id",                :default => 0,  :null => false
    t.integer  "category_id",               :default => 0,  :null => false
    t.string   "title",       :limit => 60, :default => "", :null => false
    t.text     "description"
    t.datetime "created_on"
  end

  add_index "documents", ["category_id"], :name => "index_documents_on_category_id"
  add_index "documents", ["created_on"], :name => "index_documents_on_created_on"
  add_index "documents", ["project_id"], :name => "documents_project_id"

  create_table "enabled_modules", :force => true do |t|
    t.integer "project_id"
    t.string  "name",       :null => false
  end

  add_index "enabled_modules", ["project_id"], :name => "enabled_modules_project_id"

  create_table "enumerations", :force => true do |t|
    t.string  "name",          :limit => 30, :default => "",    :null => false
    t.integer "position",                    :default => 1
    t.boolean "is_default",                  :default => false, :null => false
    t.string  "type"
    t.boolean "active",                      :default => true,  :null => false
    t.integer "project_id"
    t.integer "parent_id"
    t.string  "position_name", :limit => 30
  end

  add_index "enumerations", ["id", "type"], :name => "index_enumerations_on_id_and_type"
  add_index "enumerations", ["project_id"], :name => "index_enumerations_on_project_id"

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id", :null => false
    t.integer "user_id",  :null => false
  end

  add_index "groups_users", ["group_id", "user_id"], :name => "groups_users_ids", :unique => true

  create_table "issue_additions", :force => true do |t|
    t.integer "issue_id"
    t.decimal "latitude",  :precision => 10, :scale => 6
    t.decimal "longitude", :precision => 10, :scale => 6
    t.xml     "xml_field"
  end

  create_table "issue_categories", :force => true do |t|
    t.integer "project_id",                   :default => 0,  :null => false
    t.string  "name",           :limit => 30, :default => "", :null => false
    t.integer "assigned_to_id"
  end

  add_index "issue_categories", ["assigned_to_id"], :name => "index_issue_categories_on_assigned_to_id"
  add_index "issue_categories", ["project_id"], :name => "issue_categories_project_id"

  create_table "issue_relations", :force => true do |t|
    t.integer "issue_from_id",                 :null => false
    t.integer "issue_to_id",                   :null => false
    t.string  "relation_type", :default => "", :null => false
    t.integer "delay"
  end

  add_index "issue_relations", ["issue_from_id", "issue_to_id"], :name => "index_issue_relations_on_issue_from_id_and_issue_to_id", :unique => true
  add_index "issue_relations", ["issue_from_id"], :name => "index_issue_relations_on_issue_from_id"
  add_index "issue_relations", ["issue_to_id"], :name => "index_issue_relations_on_issue_to_id"

  create_table "issue_statuses", :force => true do |t|
    t.string  "name",               :limit => 30, :default => "",    :null => false
    t.boolean "is_closed",                        :default => false, :null => false
    t.boolean "is_default",                       :default => false, :null => false
    t.integer "position",                         :default => 1
    t.integer "default_done_ratio"
  end

  add_index "issue_statuses", ["is_closed"], :name => "index_issue_statuses_on_is_closed"
  add_index "issue_statuses", ["is_default"], :name => "index_issue_statuses_on_is_default"
  add_index "issue_statuses", ["position"], :name => "index_issue_statuses_on_position"

  create_table "issues", :force => true do |t|
    t.integer  "tracker_id",       :default => 0,     :null => false
    t.integer  "project_id",       :default => 0,     :null => false
    t.string   "subject",          :default => "",    :null => false
    t.text     "description"
    t.date     "due_date"
    t.integer  "category_id"
    t.integer  "status_id",        :default => 0,     :null => false
    t.integer  "assigned_to_id"
    t.integer  "priority_id",      :default => 0,     :null => false
    t.integer  "fixed_version_id"
    t.integer  "author_id",        :default => 0,     :null => false
    t.integer  "lock_version",     :default => 0,     :null => false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.date     "start_date"
    t.integer  "done_ratio",       :default => 0,     :null => false
    t.float    "estimated_hours"
    t.integer  "parent_id"
    t.integer  "root_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.boolean  "is_private",       :default => false, :null => false
    t.xml      "xml_body"
  end

  add_index "issues", ["assigned_to_id"], :name => "index_issues_on_assigned_to_id"
  add_index "issues", ["author_id"], :name => "index_issues_on_author_id"
  add_index "issues", ["category_id"], :name => "index_issues_on_category_id"
  add_index "issues", ["created_on"], :name => "index_issues_on_created_on"
  add_index "issues", ["fixed_version_id"], :name => "index_issues_on_fixed_version_id"
  add_index "issues", ["priority_id"], :name => "index_issues_on_priority_id"
  add_index "issues", ["project_id"], :name => "issues_project_id"
  add_index "issues", ["root_id", "lft", "rgt"], :name => "index_issues_on_root_id_and_lft_and_rgt"
  add_index "issues", ["status_id"], :name => "index_issues_on_status_id"
  add_index "issues", ["tracker_id"], :name => "index_issues_on_tracker_id"

  create_table "journal_details", :force => true do |t|
    t.integer "journal_id",               :default => 0,  :null => false
    t.string  "property",   :limit => 30, :default => "", :null => false
    t.string  "prop_key",   :limit => 30, :default => "", :null => false
    t.text    "old_value"
    t.text    "value"
  end

  add_index "journal_details", ["journal_id"], :name => "journal_details_journal_id"

  create_table "journals", :force => true do |t|
    t.integer  "journalized_id",                 :default => 0,     :null => false
    t.string   "journalized_type", :limit => 30, :default => "",    :null => false
    t.integer  "user_id",                        :default => 0,     :null => false
    t.text     "notes"
    t.datetime "created_on",                                        :null => false
    t.boolean  "private_notes",                  :default => false, :null => false
  end

  add_index "journals", ["created_on"], :name => "index_journals_on_created_on"
  add_index "journals", ["journalized_id", "journalized_type"], :name => "journals_journalized_id"
  add_index "journals", ["journalized_id"], :name => "index_journals_on_journalized_id"
  add_index "journals", ["user_id"], :name => "index_journals_on_user_id"

  create_table "member_roles", :force => true do |t|
    t.integer "member_id",      :null => false
    t.integer "role_id",        :null => false
    t.integer "inherited_from"
  end

  add_index "member_roles", ["member_id"], :name => "index_member_roles_on_member_id"
  add_index "member_roles", ["role_id"], :name => "index_member_roles_on_role_id"

  create_table "members", :force => true do |t|
    t.integer  "user_id",           :default => 0,     :null => false
    t.integer  "project_id",        :default => 0,     :null => false
    t.datetime "created_on"
    t.boolean  "mail_notification", :default => false, :null => false
  end

  add_index "members", ["project_id"], :name => "index_members_on_project_id"
  add_index "members", ["user_id", "project_id"], :name => "index_members_on_user_id_and_project_id", :unique => true
  add_index "members", ["user_id"], :name => "index_members_on_user_id"

  create_table "messages", :force => true do |t|
    t.integer  "board_id",                         :null => false
    t.integer  "parent_id"
    t.string   "subject",       :default => "",    :null => false
    t.text     "content"
    t.integer  "author_id"
    t.integer  "replies_count", :default => 0,     :null => false
    t.integer  "last_reply_id"
    t.datetime "created_on",                       :null => false
    t.datetime "updated_on",                       :null => false
    t.boolean  "locked",        :default => false
    t.integer  "sticky",        :default => 0
  end

  add_index "messages", ["author_id"], :name => "index_messages_on_author_id"
  add_index "messages", ["board_id"], :name => "messages_board_id"
  add_index "messages", ["created_on"], :name => "index_messages_on_created_on"
  add_index "messages", ["last_reply_id"], :name => "index_messages_on_last_reply_id"
  add_index "messages", ["parent_id"], :name => "messages_parent_id"

  create_table "news", :force => true do |t|
    t.integer  "project_id"
    t.string   "title",          :limit => 60, :default => "", :null => false
    t.string   "summary",                      :default => ""
    t.text     "description"
    t.integer  "author_id",                    :default => 0,  :null => false
    t.datetime "created_on"
    t.integer  "comments_count",               :default => 0,  :null => false
  end

  add_index "news", ["author_id"], :name => "index_news_on_author_id"
  add_index "news", ["created_on"], :name => "index_news_on_created_on"
  add_index "news", ["project_id"], :name => "news_project_id"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "projects", :force => true do |t|
    t.string   "name",        :default => "",   :null => false
    t.text     "description"
    t.string   "homepage",    :default => ""
    t.boolean  "is_public",   :default => true, :null => false
    t.integer  "parent_id"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "identifier"
    t.integer  "status",      :default => 1,    :null => false
    t.integer  "lft"
    t.integer  "rgt"
  end

  add_index "projects", ["lft"], :name => "index_projects_on_lft"
  add_index "projects", ["rgt"], :name => "index_projects_on_rgt"

  create_table "projects_trackers", :id => false, :force => true do |t|
    t.integer "project_id", :default => 0, :null => false
    t.integer "tracker_id", :default => 0, :null => false
  end

  add_index "projects_trackers", ["project_id", "tracker_id"], :name => "projects_trackers_unique", :unique => true
  add_index "projects_trackers", ["project_id"], :name => "projects_trackers_project_id"

  create_table "queries", :force => true do |t|
    t.integer "project_id"
    t.string  "name",          :default => "",    :null => false
    t.text    "filters"
    t.integer "user_id",       :default => 0,     :null => false
    t.boolean "is_public",     :default => false, :null => false
    t.text    "column_names"
    t.text    "sort_criteria"
    t.string  "group_by"
  end

  add_index "queries", ["project_id"], :name => "index_queries_on_project_id"
  add_index "queries", ["user_id"], :name => "index_queries_on_user_id"

  create_table "repositories", :force => true do |t|
    t.integer "project_id",                  :default => 0,     :null => false
    t.string  "url",                         :default => "",    :null => false
    t.string  "login",         :limit => 60, :default => ""
    t.string  "password",                    :default => ""
    t.string  "root_url",                    :default => ""
    t.string  "type"
    t.string  "path_encoding", :limit => 64
    t.string  "log_encoding",  :limit => 64
    t.text    "extra_info"
    t.string  "identifier"
    t.boolean "is_default",                  :default => false
  end

  add_index "repositories", ["project_id"], :name => "index_repositories_on_project_id"

  create_table "roles", :force => true do |t|
    t.string  "name",              :limit => 30, :default => "",        :null => false
    t.integer "position",                        :default => 1
    t.boolean "assignable",                      :default => true
    t.integer "builtin",                         :default => 0,         :null => false
    t.text    "permissions"
    t.string  "issues_visibility", :limit => 30, :default => "default", :null => false
  end

  create_table "settings", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.text     "value"
    t.datetime "updated_on"
  end

  add_index "settings", ["name"], :name => "index_settings_on_name"

  create_table "shelters", :force => true do |t|
    t.integer  "project_id",                                            :null => false
    t.string   "disaster_code",                         :limit => 20,   :null => false
    t.string   "name",                                  :limit => 30,   :null => false
    t.string   "name_kana",                             :limit => 60
    t.string   "address",                               :limit => 200,  :null => false
    t.string   "phone",                                 :limit => 20
    t.string   "fax",                                   :limit => 20
    t.string   "e_mail"
    t.string   "person_responsible",                    :limit => 100
    t.string   "shelter_type",                                          :null => false
    t.string   "shelter_type_detail"
    t.string   "shelter_sort",                                          :null => false
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.integer  "capacity"
    t.string   "status"
    t.integer  "head_count"
    t.integer  "head_count_voluntary"
    t.integer  "households"
    t.integer  "households_voluntary"
    t.datetime "checked_at"
    t.string   "shelter_code",                          :limit => 14,   :null => false
    t.string   "manager_code",                          :limit => 10
    t.string   "manager_name",                          :limit => 100
    t.string   "manager_another_name",                  :limit => 100
    t.datetime "reported_at"
    t.string   "building_damage_info",                  :limit => 4000
    t.string   "electric_infra_damage_info",            :limit => 4000
    t.string   "communication_infra_damage_info",       :limit => 4000
    t.string   "other_damage_info",                     :limit => 4000
    t.string   "usable_flag",                           :limit => 1
    t.string   "openable_flag",                         :limit => 1
    t.integer  "injury_count"
    t.integer  "upper_care_level_three_count"
    t.integer  "elderly_alone_count"
    t.integer  "elderly_couple_count"
    t.integer  "bedridden_elderly_count"
    t.integer  "elderly_dementia_count"
    t.integer  "rehabilitation_certificate_count"
    t.integer  "physical_disability_certificate_count"
    t.string   "note",                                  :limit => 4000
    t.datetime "deleted_at"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  create_table "time_entries", :force => true do |t|
    t.integer  "project_id",  :null => false
    t.integer  "user_id",     :null => false
    t.integer  "issue_id"
    t.float    "hours",       :null => false
    t.string   "comments"
    t.integer  "activity_id", :null => false
    t.date     "spent_on",    :null => false
    t.integer  "tyear",       :null => false
    t.integer  "tmonth",      :null => false
    t.integer  "tweek",       :null => false
    t.datetime "created_on",  :null => false
    t.datetime "updated_on",  :null => false
  end

  add_index "time_entries", ["activity_id"], :name => "index_time_entries_on_activity_id"
  add_index "time_entries", ["created_on"], :name => "index_time_entries_on_created_on"
  add_index "time_entries", ["issue_id"], :name => "time_entries_issue_id"
  add_index "time_entries", ["project_id"], :name => "time_entries_project_id"
  add_index "time_entries", ["user_id"], :name => "index_time_entries_on_user_id"

  create_table "tokens", :force => true do |t|
    t.integer  "user_id",                  :default => 0,  :null => false
    t.string   "action",     :limit => 30, :default => "", :null => false
    t.string   "value",      :limit => 40, :default => "", :null => false
    t.datetime "created_on",                               :null => false
  end

  add_index "tokens", ["user_id"], :name => "index_tokens_on_user_id"

  create_table "trackers", :force => true do |t|
    t.string  "name",          :limit => 30, :default => "",    :null => false
    t.boolean "is_in_chlog",                 :default => false, :null => false
    t.integer "position",                    :default => 1
    t.boolean "is_in_roadmap",               :default => true,  :null => false
    t.integer "fields_bits",                 :default => 0
  end

  create_table "user_preferences", :force => true do |t|
    t.integer "user_id",   :default => 0,     :null => false
    t.text    "others"
    t.boolean "hide_mail", :default => false
    t.string  "time_zone"
  end

  add_index "user_preferences", ["user_id"], :name => "index_user_preferences_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login",                           :default => "",    :null => false
    t.string   "hashed_password",   :limit => 40, :default => "",    :null => false
    t.string   "firstname",         :limit => 30, :default => "",    :null => false
    t.string   "lastname",          :limit => 30, :default => "",    :null => false
    t.string   "mail",              :limit => 60, :default => "",    :null => false
    t.boolean  "admin",                           :default => false, :null => false
    t.integer  "status",                          :default => 1,     :null => false
    t.datetime "last_login_on"
    t.string   "language",          :limit => 5,  :default => ""
    t.integer  "auth_source_id"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "type"
    t.string   "identity_url"
    t.string   "mail_notification",               :default => "",    :null => false
    t.string   "salt",              :limit => 64
  end

  add_index "users", ["auth_source_id"], :name => "index_users_on_auth_source_id"
  add_index "users", ["id", "type"], :name => "index_users_on_id_and_type"
  add_index "users", ["type"], :name => "index_users_on_type"

  create_table "versions", :force => true do |t|
    t.integer  "project_id",      :default => 0,      :null => false
    t.string   "name",            :default => "",     :null => false
    t.string   "description",     :default => ""
    t.date     "effective_date"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "wiki_page_title"
    t.string   "status",          :default => "open"
    t.string   "sharing",         :default => "none", :null => false
  end

  add_index "versions", ["project_id"], :name => "versions_project_id"
  add_index "versions", ["sharing"], :name => "index_versions_on_sharing"

  create_table "watchers", :force => true do |t|
    t.string  "watchable_type", :default => "", :null => false
    t.integer "watchable_id",   :default => 0,  :null => false
    t.integer "user_id"
  end

  add_index "watchers", ["user_id", "watchable_type"], :name => "watchers_user_id_type"
  add_index "watchers", ["user_id"], :name => "index_watchers_on_user_id"
  add_index "watchers", ["watchable_id", "watchable_type"], :name => "index_watchers_on_watchable_id_and_watchable_type"

  create_table "wiki_content_versions", :force => true do |t|
    t.integer  "wiki_content_id",                              :null => false
    t.integer  "page_id",                                      :null => false
    t.integer  "author_id"
    t.binary   "data"
    t.string   "compression",     :limit => 6, :default => ""
    t.string   "comments",                     :default => ""
    t.datetime "updated_on",                                   :null => false
    t.integer  "version",                                      :null => false
  end

  add_index "wiki_content_versions", ["updated_on"], :name => "index_wiki_content_versions_on_updated_on"
  add_index "wiki_content_versions", ["wiki_content_id"], :name => "wiki_content_versions_wcid"

  create_table "wiki_contents", :force => true do |t|
    t.integer  "page_id",                    :null => false
    t.integer  "author_id"
    t.text     "text"
    t.string   "comments",   :default => ""
    t.datetime "updated_on",                 :null => false
    t.integer  "version",                    :null => false
  end

  add_index "wiki_contents", ["author_id"], :name => "index_wiki_contents_on_author_id"
  add_index "wiki_contents", ["page_id"], :name => "wiki_contents_page_id"

  create_table "wiki_pages", :force => true do |t|
    t.integer  "wiki_id",                       :null => false
    t.string   "title",                         :null => false
    t.datetime "created_on",                    :null => false
    t.boolean  "protected",  :default => false, :null => false
    t.integer  "parent_id"
  end

  add_index "wiki_pages", ["parent_id"], :name => "index_wiki_pages_on_parent_id"
  add_index "wiki_pages", ["wiki_id", "title"], :name => "wiki_pages_wiki_id_title"
  add_index "wiki_pages", ["wiki_id"], :name => "index_wiki_pages_on_wiki_id"

  create_table "wiki_redirects", :force => true do |t|
    t.integer  "wiki_id",      :null => false
    t.string   "title"
    t.string   "redirects_to"
    t.datetime "created_on",   :null => false
  end

  add_index "wiki_redirects", ["wiki_id", "title"], :name => "wiki_redirects_wiki_id_title"
  add_index "wiki_redirects", ["wiki_id"], :name => "index_wiki_redirects_on_wiki_id"

  create_table "wikis", :force => true do |t|
    t.integer "project_id",                :null => false
    t.string  "start_page",                :null => false
    t.integer "status",     :default => 1, :null => false
  end

  add_index "wikis", ["project_id"], :name => "wikis_project_id"

  create_table "workflows", :force => true do |t|
    t.integer "tracker_id",                  :default => 0,     :null => false
    t.integer "old_status_id",               :default => 0,     :null => false
    t.integer "new_status_id",               :default => 0,     :null => false
    t.integer "role_id",                     :default => 0,     :null => false
    t.boolean "assignee",                    :default => false, :null => false
    t.boolean "author",                      :default => false, :null => false
    t.string  "type",          :limit => 30
    t.string  "field_name",    :limit => 30
    t.string  "rule",          :limit => 30
  end

  add_index "workflows", ["new_status_id"], :name => "index_workflows_on_new_status_id"
  add_index "workflows", ["old_status_id"], :name => "index_workflows_on_old_status_id"
  add_index "workflows", ["role_id", "tracker_id", "old_status_id"], :name => "wkfs_role_tracker_old_status"
  add_index "workflows", ["role_id"], :name => "index_workflows_on_role_id"

  set_table_comment 'constants', 'コンスタント'
  set_column_comment 'constants', 'kind1', '種別'
  set_column_comment 'constants', 'kind2', 'テーブル名'
  set_column_comment 'constants', 'kind3', 'カラム名'
  set_column_comment 'constants', 'text', 'テキスト'
  set_column_comment 'constants', 'value', '値'
  set_column_comment 'constants', '_order', '並び順'
  set_column_comment 'constants', 'created_at', '登録日時'
  set_column_comment 'constants', 'updated_at', '更新日時'

  set_table_comment 'shelters', '避難所情報'
  set_column_comment 'shelters', 'disaster_code', '災害コード'
  set_column_comment 'shelters', 'name', '避難所名'
  set_column_comment 'shelters', 'name_kana', '避難所名カナ'
  set_column_comment 'shelters', 'address', '避難所の住所'
  set_column_comment 'shelters', 'phone', '避難所の電話番号'
  set_column_comment 'shelters', 'fax', '避難所のFAX番号'
  set_column_comment 'shelters', 'e_mail', '避難所のメールアドレス'
  set_column_comment 'shelters', 'person_responsible', '避難所の担当者名'
  set_column_comment 'shelters', 'shelter_type', '避難所種別'
  set_column_comment 'shelters', 'shelter_type_detail', '避難所種別では表現しきれない情報'
  set_column_comment 'shelters', 'shelter_sort', '避難所区分'
  set_column_comment 'shelters', 'opened_at', '開設日時'
  set_column_comment 'shelters', 'closed_at', '閉鎖日時'
  set_column_comment 'shelters', 'capacity', '最大の収容人数'
  set_column_comment 'shelters', 'status', '避難所状況'
  set_column_comment 'shelters', 'head_count', '人数（自主避難人数を含む）'
  set_column_comment 'shelters', 'head_count_voluntary', '自主避難人数'
  set_column_comment 'shelters', 'households', '世帯数（自主避難世帯数を含む）'
  set_column_comment 'shelters', 'households_voluntary', '自主避難世帯数'
  set_column_comment 'shelters', 'checked_at', '避難所状況確認日時'
  set_column_comment 'shelters', 'shelter_code', '避難所識別番号'
  set_column_comment 'shelters', 'manager_code', '管理者（職員番号）'
  set_column_comment 'shelters', 'manager_name', '管理者（名称）'
  set_column_comment 'shelters', 'manager_another_name', '管理者（別名）'
  set_column_comment 'shelters', 'reported_at', '報告日時'
  set_column_comment 'shelters', 'building_damage_info', '建物被害状況'
  set_column_comment 'shelters', 'electric_infra_damage_info', '電力被害状況'
  set_column_comment 'shelters', 'communication_infra_damage_info', '通信手段被害状況'
  set_column_comment 'shelters', 'other_damage_info', 'その他の被害'
  set_column_comment 'shelters', 'usable_flag', '使用可否'
  set_column_comment 'shelters', 'openable_flag', '開設の可否'
  set_column_comment 'shelters', 'injury_count', '負傷_計'
  set_column_comment 'shelters', 'upper_care_level_three_count', '要介護度3以上_計'
  set_column_comment 'shelters', 'elderly_alone_count', '一人暮らし高齢者（65歳以上）_計'
  set_column_comment 'shelters', 'elderly_couple_count', '高齢者世帯（夫婦共に65歳以上）_計'
  set_column_comment 'shelters', 'bedridden_elderly_count', '寝たきり高齢者_計'
  set_column_comment 'shelters', 'elderly_dementia_count', '認知症高齢者_計'
  set_column_comment 'shelters', 'rehabilitation_certificate_count', '療育手帳所持者_計'
  set_column_comment 'shelters', 'physical_disability_certificate_count', '身体障害者手帳所持者_計'
  set_column_comment 'shelters', 'note', '備考'
  set_column_comment 'shelters', 'deleted_at', '削除日時'
  set_column_comment 'shelters', 'created_at', '登録日時'
  set_column_comment 'shelters', 'updated_at', '更新日時'

end
