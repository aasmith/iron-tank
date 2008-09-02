class CreateSplits < ActiveRecord::Migration
  def self.up
    create_table :splits do |t|
      t.integer :entry_id
      t.integer :ledger_id
      t.integer :amount

      # OFX field FITID (Financial Institution Transaction ID)
      # See OFX spec sect 3.2.1
      t.string :fit

      t.timestamps
    end
  end

  def self.down
    drop_table :splits
  end
end
