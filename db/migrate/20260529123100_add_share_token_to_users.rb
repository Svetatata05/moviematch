class AddShareTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :share_token, :string
    add_index :users, :share_token, unique: true

    reversible do |dir|
      dir.up do
        User.reset_column_information
        User.find_each do |user|
          user.update_column(:share_token, SecureRandom.urlsafe_base64(12))
        end
      end
    end

    change_column_null :users, :share_token, false
  end
end
