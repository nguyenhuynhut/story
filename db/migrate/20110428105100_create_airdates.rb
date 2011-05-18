class CreateAirdates < ActiveRecord::Migration
  def self.up
    create_table :airdates do |t|
      t.datetime :airdate
      t.references :story
      t.timestamps
    end
  end

  def self.down
    drop_table :airdates
  end
end
