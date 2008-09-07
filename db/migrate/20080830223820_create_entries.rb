class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.string :entry_type
      t.string :memo

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
