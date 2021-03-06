class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      # General
      t.string :name, null: false
      t.string :email, null: false
      t.string :image_url, null: false

      # Omniauthable
      t.string :provider, null: false
      t.string :uid, null: false

      t.timestamps null: false
    end

    add_index :users, [:provider, :uid], unique: true
    add_index :users, :email, unique: true
  end
end
