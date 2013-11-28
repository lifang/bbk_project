class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :password
      t.integer :types
      t.string :phone
      t.string :address
      t.integer :status
      t.timestamps
    end
  end
end
