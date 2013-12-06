class CreateCalculations < ActiveRecord::Migration
  def change
    create_table :calculations do |t|
      t.integer :user_id
      t.string :month
      t.string :time
      t.boolean :is_pay
      t.integer :longness
      t.timestamps
    end
    add_index :calculations, :user_id
  end
end
