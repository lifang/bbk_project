class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.integer :types
      t.integer :taks_tag_id
      t.string :origin_ppt_url
      t.string :origin_flash_url
      t.integer :ppt_doer
      t.integer :flash_doer
      t.integer :status
      t.integer :checker
      t.string :ppt_start_time
      t.string :flash_start_time
      t.boolean :is_calculate

      t.timestamps
    end
    add_index :tasks, :taks_tag_id
  end
end
