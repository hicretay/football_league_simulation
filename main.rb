require 'sinatra'
require 'json'
require 'sinatra/reloader' if development?

set :public_folder, 'public'

# Takımlar ve maçlar için başlangıç verilerini tanımlayın
teams = [
  { id: 1, name: 'Team A', strength: 5, points: 0, goals_for: 0, goals_against: 0, goal_difference: 0 },
  { id: 2, name: 'Team B', strength: 4, points: 0, goals_for: 0, goals_against: 0, goal_difference: 0 },
  { id: 3, name: 'Team C', strength: 3, points: 0, goals_for: 0, goals_against: 0, goal_difference: 0 },
  { id: 4, name: 'Team D', strength: 2, points: 0, goals_for: 0, goals_against: 0, goal_difference: 0 }
]

matches = []

# Helper fonksiyonlar
def generate_matches(teams)
  matches = []
  teams.combination(2).each do |team_pair|
    matches << { home_team: team_pair[0], away_team: team_pair[1], home_team_score: nil, away_team_score: nil }
  end
  matches
end

def play_match(match)
  home_advantage = rand(0..1)
  match[:home_team_score] = rand(0..5) + home_advantage
  match[:away_team_score] = rand(0..5)

  if match[:home_team][:strength] > match[:away_team][:strength]
    match[:home_team_score] += rand(1..2)
  elsif match[:home_team][:strength] < match[:away_team][:strength]
    match[:away_team_score] += rand(1..2)
  end

  match[:home_team_score] = [match[:home_team_score], 5].min
  match[:away_team_score] = [match[:away_team_score], 5].min
end

def update_standings(teams, matches)
  standings = teams.map { |team| team.merge(points: 0, goals_for: 0, goals_against: 0, goal_difference: 0) }

  matches.each do |match|
    next unless match[:home_team_score] && match[:away_team_score]

    home_team = standings.find { |team| team[:id] == match[:home_team][:id] }
    away_team = standings.find { |team| team[:id] == match[:away_team][:id] }

    home_team[:goals_for] += match[:home_team_score]
    home_team[:goals_against] += match[:away_team_score]
    away_team[:goals_for] += match[:away_team_score]
    away_team[:goals_against] += match[:home_team_score]

    if match[:home_team_score] > match[:away_team_score]
      home_team[:points] += 3
    elsif match[:home_team_score] < match[:away_team_score]
      away_team[:points] += 3
    else
      home_team[:points] += 1
      away_team[:points] += 1
    end

    home_team[:goal_difference] = home_team[:goals_for] - home_team[:goals_against]
    away_team[:goal_difference] = away_team[:goals_for] - away_team[:goals_against]
  end
  standings.sort_by { |team| [-team[:points], -team[:goal_difference], -team[:goals_for]] }
end

def monte_carlo_simulation(teams, matches, simulations = 1000)
  championship_counts = Hash.new(0)

  simulations.times do
    simulated_matches = matches.map(&:dup)
    simulated_teams = teams.map(&:dup)
    simulated_matches.each { |match| play_match(match) }
    standings = update_standings(simulated_teams, simulated_matches)
    champion = standings.first
    championship_counts[champion[:name]] += 1
  end

  total_simulations = simulations.to_f
  championship_percentages = championship_counts.transform_values { |count| (count / total_simulations * 100).round(2) }
end

# Maçları başlat
matches = generate_matches(teams)

# Sinatra rotaları
get '/' do
  @teams = teams
  @matches = matches
  erb :index
end

post '/simulate' do
  matches.each { |match| play_match(match) }
  standings = update_standings(teams, matches)
  standings.to_json
end

post '/reset' do
  matches.each do |match|
    match[:home_team_score] = nil
    match[:away_team_score] = nil
  end

  teams.each do |team|
    team[:points] = 0
    team[:goals_for] = 0
    team[:goals_against] = 0
    team[:goal_difference] = 0
  end

  status 200
end

post '/championship_percentages' do
  percentages = monte_carlo_simulation(teams, matches)
  percentages.to_json
end
