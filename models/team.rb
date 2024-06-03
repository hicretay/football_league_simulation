class Team < Sequel::Model
  one_to_many :home_matches, class: :Match, key: :home_team_id
  one_to_many :away_matches, class: :Match, key: :away_team_id
end
