class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.references :user, index: true, foreign_key: true
      t.text :name
      t.integer :parent_node_id
      t.boolean :is_folder

      t.timestamps null: false

      t.index :parent_node_id
    end
  end
end
