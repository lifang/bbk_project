class CreateTaskTags < ActiveRecord::Migration
  def change
    create_table :task_tags do |t|
      t.string :name
      t.integer :status
      t.timestamps
    end
  end
end
