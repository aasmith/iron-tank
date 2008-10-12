class CreateLedgers < ActiveRecord::Migration
  def self.up
    create_table :ledgers do |t|
      t.string :type
      t.string :name

      t.integer :user_id

      # OFX fields: financial institute id, acct num, routing num
      t.string :fid
      t.string :institution
      t.string :account_number
      t.string :routing_number

      t.text :credentials

      t.timestamps
    end
  end

  def self.down
    drop_table :ledgers
  end
end
