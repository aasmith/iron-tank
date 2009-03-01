class CreateAdapters < ActiveRecord::Migration
  def self.up
    create_table :adapters do |t|
      t.string :fetcher
      t.string :loader
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :adapters
  end
end
