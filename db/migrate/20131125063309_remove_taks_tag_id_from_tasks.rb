class RemoveTaksTagIdFromTasks < ActiveRecord::Migration
  def up
    remove_index :tasks, :taks_tag_id
    remove_column :tasks, :taks_tag_id
    add_column :tasks, :task_tag_id, :integer
    add_index :tasks, :task_tag_id
  end

  def down
    remove_index :tasks, :task_tag_id
    remove_column :tasks, :task_tag_id
    add_column :tasks, :taks_tag_id, :integer
    add_index :tasks, :taks_tag_id
  end
end
