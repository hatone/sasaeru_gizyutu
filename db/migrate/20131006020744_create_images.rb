class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :filename
      t.integer :price
      t.timestamps
    end
  end
end
