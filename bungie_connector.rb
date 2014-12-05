require 'net/http'
require 'json'
require 'open-uri'

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
      char_hash['race'] = key_to_string(char["characterBase"]["raceHash"])
      char_hash['gender'] = key_to_string(char["characterBase"]["genderHash"])
      char_hash['class'] = key_to_string(char["characterBase"]["classHash"])
      characters << char_hash
    end
    characters
  end

  def key_to_string(key)
    bungie_hash[key.to_s]
  end

  def bungie_hash
    {
     '3159615086' => 'glimmer',
     '1415355184' => 'crucible marks',
     '1415355173' => 'vanguard marks',
     '898834093' => 'exo',
     '3887404748' => 'human',
     '2803282938' => 'awoken',
     '3111576190' => 'male',
     '2204441813' => 'female',
     '671679327' => 'hunter',
     '3655393761' => 'titan',
     '2271682572' => 'warlock',
     '3871980777' => 'New Monarchy',
     '529303302' => 'Cryptarch',
     '2161005788' => 'Iron Banner',
     '452808717' => 'Queen',
     '3233510749' => 'Vanguard',
     '1357277120' => 'Crucible',
     '2778795080' => 'Dead Orbit',
     '1424722124' => 'Future War Cult',
     '2033897742' => 'Weekly Vanguard Marks',
     '2033897755' => 'Weekly Vanguard Marks'
    }
  end
end