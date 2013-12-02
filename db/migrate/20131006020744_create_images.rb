class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :filename
      t.integer :price
      t.text :title
      t.text :author
      t.text :color
      t.timestamps
    end
  end
end
