class CreateShareUsers < ActiveRecord::Migration
  def change
    create_table :share_users do |t|
      t.references :node, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
