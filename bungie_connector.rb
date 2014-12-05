require 'net/http'
require 'json'
require 'byebug'
require 'open-uri'
require "awesome_print"

class BungieConnector
  SULFATER_MEMBERS = %w(cads79 kirainetjp rod_zordor ae86tgt)
  PLAYSTATION = 2
  XBOX = 1

  def get_id_for_member(member_name)
    url = "http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/#{PLAYSTATION}/#{member_name}/"
    member_json = JSON.parse(open(url).read)
    member_json["Response"].first["membershipId"]
  end

  def get_data_for_id(member_id)
    url = "http://www.bungie.net/Platform/Destiny/TigerPSN/Account/#{member_id}/"
    member_data_json = JSON.parse(open(url).read)
    member_data_json["Response"]
  end

  def clan_data
    clan_data = []
    SULFATER_MEMBERS.each do |member|
      id = get_id_for_member(member)
      clan_data << get_data_for_id(id)
    end
    clan_data
  end

  def member_data(member_name)
    member_id = get_id_for_member(member_name)
    raw_data = get_data_for_id(member_id)
    data = {}
    data['glimmer'] = raw_data["data"]["inventory"]["currencies"].first["value"]
    data['grimoire_score'] = raw_data["data"]["grimoireScore"]
    data
  end

  def characters_by_member(member_name)
    characters = []
    member_id = get_id_for_member(member_name)
    raw_data = get_data_for_id(member_id)
    raw_data["data"]["characters"].each do |char|
      char_hash = {}
      char_hash['power_level'] = char["characterBase"]["powerLevel"]
      char_hash['percent_to_next_level'] = char["percentToNextLevel"]
      char_hash['progress_to_next_level'] = char["levelProgression"]["progressToNextLevel"]
      char_hash['next_level_at'] = char["levelProgression"]["nextLevelAt"]
      char_hash['total_minutes_played'] = char["characterBase"]["minutesPlayedTotal"]
      characters << char_hash
    end
    characters
  end
end