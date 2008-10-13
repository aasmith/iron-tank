class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.integer :user_id
      t.string  :entry_type
      t.date    :posted
      t.string  :memo
      t.boolean :approved, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
