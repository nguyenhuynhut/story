class CreateStaffs < ActiveRecord::Migration
  def self.up
    create_table :staffs do |t|
      t.string :userid
      t.string :password
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :title
      t.string :avatar
      t.string :phone
      t.string :token
      t.boolean :is_senior_producer
      t.boolean :is_assignment_editor
      t.boolean :is_producer

      t.timestamps
    end
  end

  def self.down
    drop_table :staffs
  end
end
