require 'rgeo'
require 'rgeo-geojson'

module EncodeToJson
  def self.encode_teams_to_json(obj)
    factory = RGeo::GeoJSON::EntityFactory.instance
    teams_to_json = nil

    arr = []
    if obj.is_a? Team
      arr.push(obj)
    else
      arr = obj
    end

    if arr.length == 1
      team = arr.first
      feature = factory.feature(User.find(team.location_user_id).latlon, nil,
                                {
                                    name: team.name, f_id: team.id, location_user_id: team.location_user_id,
                                    created_at: team.created_at, updated_at: team.updated_at,
                                    location_user_name: User.find(team.location_user_id).full_name,
                                    leader_id: team.leader_id, leader_name: User.find(team.leader_id).full_name,
                                    highlight_coords: team.latlon_highlight
                                }
      )
      teams_to_json = RGeo::GeoJSON.encode feature
    else
      mapped_teams = factory.map_feature_collection(arr) {
          |f| factory.feature(User.find(f.location_user_id).latlon, nil,
                              {
                                  name: f.name, f_id: f.id, location_user_id: f.location_user_id,
                                  created_at: f.created_at, updated_at: f.updated_at,
                                  location_user_name: User.find(f.location_user_id).full_name,
                                  leader_id: f.leader_id, leader_name: User.find(f.leader_id).full_name,
                                  highlight_coords: f.latlon_highlight
                              }
        )
      }
      teams_to_json = RGeo::GeoJSON.encode factory.feature_collection(mapped_teams)
    end

    teams_to_json
  end

  def self.encode_geo_entities_to_json(obj)
    factory = RGeo::GeoJSON::EntityFactory.instance
    geo_entities_to_json = nil

    arr = []
    if obj.is_a? GeoEntity
      arr.push(obj)
    else
      arr = obj
    end

    if arr.length == 1
      geo_entity = arr.first
      feature = factory.feature(geo_entity.latlon, nil,
                                {
                                    f_id: geo_entity.id, name: geo_entity.name, username: geo_entity.user.full_name,
                                    user_id: geo_entity.user_id, description: geo_entity.description,
                                    radius: geo_entity.radius, created_at: geo_entity.created_at,
                                    updated_at: geo_entity.updated_at, entity_type: geo_entity.entity_type,
                                    category_id: geo_entity.category_id, category_name: geo_entity.category.name
                                }
      )
      geo_entities_to_json = RGeo::GeoJSON.encode feature
    else
      mapped_feats = factory.map_feature_collection(arr) {
          |f| factory.feature(f.latlon, nil,
                              {
                                  f_id: f.id, name: f.name, username: f.user.full_name, user_id: f.user_id,
                                  description: f.description, radius: f.radius, updated_at: f.updated_at,
                                  created_at: f.created_at, entity_type: f.entity_type,
                                  category_id: f.category_id, category_name: f.category.name
                              }
        )
      }
      geo_entities_to_json = RGeo::GeoJSON.encode factory.feature_collection(mapped_feats)
    end

    geo_entities_to_json
  end

  def self.encode_users_to_json(obj)
    factory = RGeo::GeoJSON::EntityFactory.instance
    users_to_json = nil

    arr = []
    if obj.is_a? User
      arr.push(obj)
    else
      arr = obj
    end

    if arr.length == 1
      user = arr.first
      feature = factory.feature(user.latlon, nil,
                                {
                                    user_id: user.id, full_name: user.full_name, email: user.email,
                                    phone_number: user.phone_number, profile: user.profile, updated_at: user.updated_at
                                }
      )
      users_to_json = RGeo::GeoJSON.encode feature
    else
      mapped_feats = factory.map_feature_collection(arr) {
          |f| factory.feature(f.latlon, nil,
                              {
                                  user_id: f.id, full_name: f.full_name, email: f.email,
                                  phone_number: f.phone_number, profile: f.profile, updated_at: f.updated_at
                              }
        )
      }
      users_to_json = RGeo::GeoJSON.encode factory.feature_collection(mapped_feats)
    end

    users_to_json
  end
end