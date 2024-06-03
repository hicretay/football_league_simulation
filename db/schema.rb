require 'sequel'

DB = Sequel.sqlite('league.db')

DB.create_table :teams do
  primary_key :id
  String :name
  Integer :strength
end

DB.create_table :matches do
  primary_key :id
  foreign_key :home_team_id, :teams
  foreign_key :away_team_id, :teams
  Integer :home_team_score
  Integer :away_team_score
  Date :match_date
end
