class AddFileToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :file, :string
  end
end
