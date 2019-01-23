class Match < ApplicationRecord
  belongs_to :team

  @@totalscore = {}
  @@homescore = {}
  @@awayscore = {}
  @@score = {}

  def mvp
    TeamPlayer.find(self.man_of_match).name
  end

  def away_team
    Team.find(self.team_id_2)
  end

  def match
    @@homescore = home_baskets
    @@awayscore = away_baskets
    @@totalscore
  end

  def home_score
    @@homescore
  end

  def away_score
    @@awayscore
  end

  def final_score
    @@score
  end

  def home_baskets
    teammod = self.team.teammodifier
    team_baskets = {}
    self.team.team_players.each do |player|
      baskets = (player.modifier * teammod).to_i
      player.matchbaskets = baskets
      player.totalbaskets += baskets
      team_baskets[player.name] = baskets
      player.save
    end
    @@totalscore[:home] = team_baskets
  end

  def away_baskets
    teammod = self.away_team.teammodifier
    team_baskets = {}
    team = away_team
    team.team_players.each do |player|
      baskets = (player.modifier * teammod).to_i
      player.matchbaskets = baskets
      player.totalbaskets += baskets
      team_baskets[player.name] = baskets
      player.save
    end
    @@totalscore[:away] = team_baskets
  end

  def score
    score = {}
    homescore = 0
    awayscore = 0
    self.match.each do |team, stats|
      stats.each do |player, score|
        if team == :home
          homescore += score
        else
          awayscore += score
        end
      end
    end
    self.baskets_team_1 = homescore
    self.baskets_team_2 = awayscore
    self.save
    @@score = {home: homescore, away: awayscore}
  end

  def highest_scorer
    m1 = @@totalscore[:home].max_by { |k, v| v }
    m2 = @@totalscore[:away].max_by { |k, v| v }
    byebug
    if m1[1] > m2[1]
      playerid = Player.find_by(name: m1[0]).id
      self.man_of_match = TeamPlayer.find_by(player_id: playerid).id
      self.save
    else
      playerid = Player.find_by(name: m2[0]).id
      self.man_of_match = TeamPlayer.find_by(player_id: playerid).id
      self.save
    end
  end
end
