class ModifyTypesFromTask < ActiveRecord::Migration
  def up
    rename_column :tasks, :types, :is_upload_source
    add_column :tasks, :source_url, :integer
  end

  def down
    rename_column :tasks, :is_upload_source, :types
    remove_column :tasks, :source_url
  end
end
