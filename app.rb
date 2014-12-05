# myapp.rb
require 'sinatra'
require './bungie_connector'

get '/' do
  connector = BungieConnector.new
  members = []
  BungieConnector::SULFATER_MEMBERS.each do |member|
    member_hash = {}
    member_data = connector.member_data(member)
    member_hash['name'] = member
    member_hash['glimmer'] = member_data['glimmer']
    member_hash['grimoire_score'] = member_data['grimoire_score']
    member_hash['characters']= connector.characters_by_member(member)
    members << member_hash
  end
  erb :index, :locals => {members: members}
end
