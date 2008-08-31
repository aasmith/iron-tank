class CreateSplits < ActiveRecord::Migration
  def self.up
    create_table :splits do |t|
      t.integer :entry_id
      t.integer :ledger_id
      t.integer :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :splits
  end
end
