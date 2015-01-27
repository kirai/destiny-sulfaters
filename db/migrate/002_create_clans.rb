class CreateClans < ActiveRecord::Migration
  def self.up
    create_table :clans, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.string :platform
      t.string :bungie_clan_id
      t.timestamps
    end
  end

  def self.down
    drop_table :clans
  end
end
