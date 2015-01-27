class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :clan_id
      t.string :email
      t.string :password
      t.string :token
      t.string :username
      t.string :platform
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
