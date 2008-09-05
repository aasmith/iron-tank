class CreateMappings < ActiveRecord::Migration
  def self.up
    create_table :mappings do |t|
      t.integer :ledger_id
      t.string :condition
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :mappings
  end
end
