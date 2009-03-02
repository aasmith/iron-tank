class CreateLedgers < ActiveRecord::Migration
  def self.up
    create_table :ledgers do |t|
      t.string :type
      t.string :name

      t.integer :user_id
      t.integer :keychain_id
      t.integer :adapter_id

      # The unique ID used by the remote finanical 
      # institution that identifies this account.
      # Supplements the user's keychain data.
      t.string :external_id

      t.timestamps
    end
  end

  def self.down
    drop_table :ledgers
  end
end
