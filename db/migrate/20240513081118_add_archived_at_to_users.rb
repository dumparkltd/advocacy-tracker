class AddArchivedAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :archived_at, :datetime, precision: 6, null: true
  end
end
