class CreateShoots < ActiveRecord::Migration
  def self.up
    create_table :shoots do |t|
      t.date :date
      t.text :crew_requirements
      t.text :location
      t.boolean :senior_approval
      t.boolean :assigned
      t.text :notes
      t.text :preshow_tease
      t.boolean :check_mail
      t.string :name
      t.references :cameraperson
      t.references :approver
      t.references :story
       t.references :staff
      t.timestamps
    end
  end

  def self.down
    drop_table :shoots
  end
end
