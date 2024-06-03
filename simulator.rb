class Simulator
  def initialize(teams)
    @teams = teams
  end

  def generate_matches
    @teams.combination(2).to_a.each do |team_pair|
      Match.create(home_team: team_pair[0], away_team: team_pair[1], home_team_score: nil, away_team_score: nil, match_date: Date.today)
    end
  end

  def play_match(match)
    match.home_team_score = rand(0..5)
    match.away_team_score = rand(0..5)
    match.save
  end

  def update_standings
    standings = Hash.new { |hash, key| hash[key] = { points: 0, goals_for: 0, goals_against: 0, goal_difference: 0 } }
    Match.each do |match|
      if match.home_team_score && match.away_team_score
        home_team = match.home_team
        away_team = match.away_team

        standings[home_team][:goals_for] += match.home_team_score
        standings[home_team][:goals_against] += match.away_team_score
        standings[away_team][:goals_for] += match.away_team_score
        standings[away_team][:goals_against] += match.home_team_score

        if match.home_team_score > match.away_team_score
          standings[home_team][:points] += 3
        elsif match.home_team_score < match.away_team_score
          standings[away_team][:points] += 3
        else
          standings[home_team][:points] += 1
          standings[away_team][:points] += 1
        end

        standings[home_team][:goal_difference] = standings[home_team][:goals_for] - standings[home_team][:goals_against]
        standings[away_team][:goal_difference] = standings[away_team][:goals_for] - standings[away_team][:goals_against]
      end
    end
    standings
  end
end
