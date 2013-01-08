class AddXmlBodyToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :xml_body, :xml
  end
end
