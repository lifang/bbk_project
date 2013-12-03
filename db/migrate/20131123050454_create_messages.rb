class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :sender_id
      t.integer :reciver_id
      t.string :content
      t.integer :accessory_id
      t.timestamps
    end
    add_index :messages, :accessory_id
  end
end
