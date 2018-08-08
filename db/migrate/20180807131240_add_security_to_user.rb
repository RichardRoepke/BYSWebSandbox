class AddSecurityToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :security, :string, default: ''
  end
end
