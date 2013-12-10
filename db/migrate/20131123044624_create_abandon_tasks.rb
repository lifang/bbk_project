class CreateAbandonTasks < ActiveRecord::Migration
  def change
    create_table :abandon_tasks do |t|
      t.integer :task_id
      t.integer :types
      t.integer :user_id

      t.timestamps
    end
    add_index :abandon_tasks, :task_id
    add_index :abandon_tasks, :user_id
  end
end
