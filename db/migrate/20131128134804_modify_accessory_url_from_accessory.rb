class ModifyAccessoryUrlFromAccessory < ActiveRecord::Migration
  def up
    remove_column :accessories, :accessory_url
    add_column :accessories, :accessory_url, :string
  end

  def down
    remove_column :accessories, :accessory_url
    add_column :accessories, :accessory_url, :integer
  end
end
