class CreateCharacters < ActiveRecord::Migration
  def self.up
    create_table :characters do |t|
      t.string :salutation
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone_1
      t.string :phone_2
      t.string :phone_3
      t.string :email_1
      t.string :email_2
      t.text :notes
      t.string :avatar
      t.string :rep_phone
      t.string :rep_email
      t.string :representative
      t.string :rep_address
      t.references :story
      t.timestamps
    end
  end

  def self.down
    drop_table :characters
  end
end
