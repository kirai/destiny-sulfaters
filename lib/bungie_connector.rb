require 'net/http'
require 'json'
require 'open-uri'
require 'byebug'
require 'awesome_print'

class BungieConnector
  SULFATER_MEMBERS = %w(cads79 kirainetjp rod_zordor ae86tgt)
  PLAYSTATION = 2
  PSN_PLATFORM = "TigerPSN"

  XBOX = 1
  XBOX_PLATFORM = "TigerXbox"

  def get_platform(member)
    case member.platform.to_s
    when "1"
      XBOX_PLATFORM
    when "2"
      PSN_PLATFORM
    end
  end

  def get_id_for_member(member)
    url = "http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/#{member.platform}/#{member.username}/"
    member_json = JSON.parse(open(url).read)
    member_json["Response"].first["membershipId"]
  end

  def get_data_for_id(member, member_id)
    platform_name = get_platform(member)
    url = "http://www.bungie.net/Platform/Destiny/#{platform_name}/Account/#{member_id}/"
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

  def member_data(member)
    member_id = get_id_for_member(member)
    raw_data = get_data_for_id(member, member_id)
    data = {}
    data['glimmer'] = raw_data["data"]["inventory"]["currencies"].first["value"]
    data['grimoire_score'] = raw_data["data"]["grimoireScore"]
    data
  end

  def characters_by_member(member)
    characters = []
    member_id = get_id_for_member(member)
    raw_data = get_data_for_id(member, member_id)
    platform = get_platform(member)

    raw_data["data"]["characters"].each do |char|
      char_url = "http://www.bungie.net/Platform/Destiny/#{platform}/Account/#{member_id}/Character/#{char["characterBase"]["characterId"]}/?definitions=true"
      char_json = JSON.parse(open(char_url).read)["Response"]
      character_data_json = char_json["data"]
      character_definitions_json = char_json["definitions"]

      rep_url = "http://www.bungie.net/Platform/Destiny/#{platform}/Account/#{member_id}/Character/#{char["characterBase"]["characterId"]}/Progression/?definitions=true&fmt=true"
      rep_json = JSON.parse(open(rep_url).read)["Response"]
      rep_data_json = rep_json["data"]
      rep_definitions_json = rep_json["definitions"]

      char_hash = {}
      char_hash['power_level'] = character_data_json["characterBase"]["powerLevel"]
      char_hash['last_played'] = character_data_json["characterBase"]["dateLastPlayed"]
      char_hash['last_minutes_played'] = character_data_json["characterBase"]["minutesPlayedThisSession"]
      char_hash['percent_to_next_level'] = character_data_json["percentToNextLevel"]
      char_hash['progress_to_next_level'] = character_data_json["levelProgression"]["progressToNextLevel"]
      char_hash['next_level_at'] = character_data_json["levelProgression"]["nextLevelAt"]
      char_hash['daily_progress'] = character_data_json["levelProgression"]["dailyProgress"]
      char_hash['weekly_progress'] = character_data_json["levelProgression"]["weeklyProgress"]
      char_hash['current_progress'] = character_data_json["levelProgression"]["currentProgress"]
      char_hash['is_prestige_level'] = character_data_json["isPrestigeLevel"]
      char_hash['total_minutes_played'] = character_data_json["characterBase"]["minutesPlayedTotal"]
      char_hash['race'] = key_to_string(character_data_json["characterBase"]["raceHash"])
      char_hash['gender'] = key_to_string(character_data_json["characterBase"]["genderHash"])
      char_hash['class'] = key_to_string(character_data_json["characterBase"]["classHash"])
      char_hash['emblem_path'] = character_data_json["emblemPath"]
      char_hash['emblem_background'] = character_data_json["backgroundPath"]
      char_gear_keys = char["characterBase"]["peerView"]["equipment"].collect{|i| i["itemHash"]}
      char_hash['gear'] = set_gear_from_data(char_gear_keys, character_definitions_json["items"])
      char_hash['reputation'] = set_reputation_from_data(rep_data_json, rep_definitions_json)
      characters << char_hash
    end
    characters
  end

  def set_gear_from_data(keys, data)
    gear = {}
    gear["subclass"] = data[keys[0].to_s]
    gear["helmet"] = data[keys[1].to_s]
    gear["gaunlets"] = data[keys[2].to_s]
    gear["chest"] = data[keys[3].to_s]
    gear["boots"] = data[keys[4].to_s]
    gear["class_armor"] = data[keys[5].to_s]
    gear["primary_weapon"] = data[keys[6].to_s]
    gear["special_weapon"] = data[keys[7].to_s]
    gear["heavy_weapon"] = data[keys[8].to_s]
    gear["ship"] = data[keys[9].to_s]
    gear["sparrow"] = data[keys[10].to_s]
    gear["ghost_shell"] = data[keys[11].to_s]
    gear["emblem"] = data[keys[12].to_s]
    gear["shader"] = data[keys[13].to_s]
    return gear
  end

  def set_reputation_from_data(rep_data, def_data)
    rep = {}
    keys = rep_data["progressions"].collect{|i| i["progressionHash"]}
    # rep["banhammer_pvp_idleness"] = rep_data["progressions"][0].merge(def_data["progressions"][keys[0].to_s])
    # rep["banhammer_pvp_quitterness"] = rep_data["progressions"][1].merge(def_data["progressions"][keys[1].to_s])
    # rep["base_item_level"] = rep_data["progressions"][2].merge(def_data["progressions"][keys[2].to_s])
    # rep["character_display_xp"] = rep_data["progressions"][3].merge(def_data["progressions"][keys[3].to_s])
    # rep["character_level"] = rep_data["progressions"][4].merge(def_data["progressions"][keys[4].to_s])
    rep["character_prestige"] = rep_data["progressions"][5].merge(def_data["progressions"][keys[5].to_s])
    # rep["death_penalty"] = rep_data["progressions"][6].merge(def_data["progressions"][keys[6].to_s])
    rep["destination_chests_cosmodrome"] = rep_data["progressions"][7].merge(def_data["progressions"][keys[7].to_s])
    rep["destination_chests_mars"] = rep_data["progressions"][8].merge(def_data["progressions"][keys[8].to_s])
    rep["destination_chests_moon"] = rep_data["progressions"][9].merge(def_data["progressions"][keys[9].to_s])
    rep["destination_chests_venus"] = rep_data["progressions"][10].merge(def_data["progressions"][keys[10].to_s])
    rep["faction_cryptarch"] = rep_data["progressions"][11].merge(def_data["progressions"][keys[11].to_s])
    rep["faction_eris"] = rep_data["progressions"][12].merge(def_data["progressions"][keys[12].to_s])
    rep["faction_event_iron_banner"] = rep_data["progressions"][13].merge(def_data["progressions"][keys[13].to_s])
    rep["faction_event_queen"] = rep_data["progressions"][14].merge(def_data["progressions"][keys[14].to_s])
    rep["faction_fotc_vanguard"] = rep_data["progressions"][15].merge(def_data["progressions"][keys[15].to_s])
    rep["faction_pvp"] = rep_data["progressions"][16].merge(def_data["progressions"][keys[16].to_s])
    rep["faction_pvp_dead_orbit"] = rep_data["progressions"][17].merge(def_data["progressions"][keys[17].to_s])
    rep["faction_pvp_future_war_cult"] = rep_data["progressions"][18].merge(def_data["progressions"][keys[18].to_s])
    rep["faction_pvp_new_monarchy"] = rep_data["progressions"][19].merge(def_data["progressions"][keys[19].to_s])
    # rep["pvp_iron_banner.loss_tokens"] = rep_data["progressions"][20].merge(def_data["progressions"][keys[20].to_s])
    # rep["pvp_tournament0.losses"] = rep_data["progressions"][21].merge(def_data["progressions"][keys[21].to_s])
    # rep["pvp_tournament0.wins"] = rep_data["progressions"][22].merge(def_data["progressions"][keys[22].to_s])
    # rep["superior_gear_material_source"] = rep_data["progressions"][23].merge(def_data["progressions"][keys[23].to_s])
    # rep["terminals"] = rep_data["progressions"][24].merge(def_data["progressions"][keys[24].to_s])
    # rep["weekly_pve"] = rep_data["progressions"][25].merge(def_data["progressions"][keys[25].to_s])
    # rep["weekly_pvp"] = rep_data["progressions"][26].merge(def_data["progressions"][keys[26].to_s])
    return rep
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