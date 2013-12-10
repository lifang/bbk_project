class ChangeSourceSourceUrlFromTasks < ActiveRecord::Migration
  def up
  	change_column :tasks, :source_url, :string
  end

  def down
  	change_column :tasks, :source_url, :integer
  end
end
