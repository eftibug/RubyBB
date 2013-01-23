class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
      t.string :title
      t.string :url
      t.text :content
      t.string :banner
      t.string :theme
      t.string :color
      t.string :bgcolor
      t.text :css
      t.integer :messages_count
      t.integer :topics_count
      t.integer :users_count

      t.timestamps
    end
    add_index :domains, :name
  end
end
