class CreatePigriderUserUsers < ActiveRecord::Migration
  def change
    create_table :pigrider_user_users do |t|
      t.string :username
      t.string :password_digest
      t.string :authorityLevel
      t.string :email

      t.timestamps
    end
  end
end
