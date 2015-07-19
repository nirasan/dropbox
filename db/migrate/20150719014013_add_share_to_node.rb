class AddShareToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :share_path, :string
    add_column :nodes, :share_mode, :integer

    add_index :nodes, :share_path, unique: true
  end
end
