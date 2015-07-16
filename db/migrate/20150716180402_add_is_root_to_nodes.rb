class AddIsRootToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :is_root, :boolean
  end
end
