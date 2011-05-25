class CreateWebextras < ActiveRecord::Migration
  def self.up
    create_table :webextras do |t|
      t.string :title
      t.text :summary
      t.boolean :check
      t.string :videourl
      t.references :story
       t.references :staff
      t.timestamps
    end
  end

  def self.down
    drop_table :webextras
  end
end
