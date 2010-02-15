class AddKeychainDescription < ActiveRecord::Migration
  def self.up
    add_column :keychains, :description, :string
  end

  def self.down
  end
end
