class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.string :name
      t.text :outline
      t.text :graphics_collateral
      t.string :script
      t.date :deadline
      t.boolean :check
      t.boolean :approved
      t.references :producer
      t.references :correspondent
           t.references :staff
      t.references :editor 
      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end
end
