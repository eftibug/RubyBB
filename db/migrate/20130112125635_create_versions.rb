class CreateVersions < ActiveRecord::Migration
  def change
    remove_column :forums, :deleted_at 
    remove_column :topics, :deleted_at 
    remove_column :messages, :deleted_at 
    remove_column :users, :deleted_at 
    create_table :versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end
    add_index :versions, [:item_type, :item_id]
  end
end
