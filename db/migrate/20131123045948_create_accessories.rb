class CreateAccessories < ActiveRecord::Migration
  def change
    create_table :accessories do |t|
      t.string :name
      t.integer :types
      t.integer :task_id
      t.integer :user_id
      t.integer :accessory_url
      t.integer :status
      t.integer :longness
      t.timestamps
    end
    add_index :accessories, :task_id
  end
end
