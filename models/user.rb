class User < ActiveRecord::Base
  belongs_to :clan

  def api_hash(force_request=false)
    hash = Padrino.cache["cached_hash_#{self.id}"]
    unless hash || force_request
      connector = BungieConnector.new
      hash = {}
      member_data = connector.member_data(self)
      hash['name'] = self.username
      hash['glimmer'] = member_data['glimmer']
      hash['grimoire_score'] = member_data['grimoire_score']
      hash['characters']= connector.characters_by_member(self)
      Padrino.cache.store "cached_hash_#{self.id}", hash, expires: 3600
    end
    return hash
  end
end
