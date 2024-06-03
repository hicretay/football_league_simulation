class Match < Sequel::Model
  many_to_one :home_team, class: :Team
  many_to_one :away_team, class: :Team
end
