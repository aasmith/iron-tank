class CreateKeychains < ActiveRecord::Migration
  def self.up
    create_table :keychains do |t|
      t.integer :user_id
      t.text    :crypted_details

      t.timestamps
    end
  end

  def self.down
    drop_table :keychains
  end
end
