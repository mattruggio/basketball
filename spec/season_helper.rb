# frozen_string_literal: true

def make_exhibition(args)
  Basketball::Season::Exhibition.new(**args)
end

def make_regular(args)
  Basketball::Season::Regular.new(**args)
end

class PlayoffGame < Basketball::Season::Game; end

class BadArena
  attr_reader :date

  def initialize(date)
    super()

    @date = date
  end

  def play(matchup)
    game = matchup.game

    Basketball::Season::Result.new(
      game: Basketball::Season::Game.new(
        date:,
        home_opponent: game.home_opponent,
        away_opponent: game.away_opponent
      ),
      home_score: 1,
      away_score: 2
    )
  end
end

class PredictableArena
  def play(matchup)
    Basketball::Season::Result.new(
      game: matchup.game,
      home_score: 1,
      away_score: 2
    )
  end
end

def read_league_fixture(*path)
  deserialize_league(read_json_fixture(*path))
end

def deserialize_league(league_hash)
  Basketball::Org::League.new(
    conferences: deserialize_conferences(league_hash[:conferences])
  )
end

def deserialize_conferences(conference_hashes)
  (conference_hashes || []).map do |conference_hash|
    Basketball::Org::Conference.new(
      id: conference_hash[:id],
      divisions: deserialize_divisions(conference_hash[:divisions])
    )
  end
end

def deserialize_divisions(division_hashes)
  (division_hashes || []).map do |division_hash|
    Basketball::Org::Division.new(
      id: division_hash[:id],
      teams: deserialize_teams(division_hash[:teams])
    )
  end
end

def deserialize_teams(team_hashes)
  (team_hashes || []).map do |team_hash|
    Basketball::Org::Team.new(
      id: team_hash[:id],
      players: deserialize_players(team_hash[:players])
    )
  end
end

def deserialize_players(player_hashes)
  (player_hashes || []).map do |player_hash|
    Basketball::Org::Player.new(
      id: player_hash[:id],
      overall: player_hash[:overall],
      position: Org::Position.new(player_hash[:position])
    )
  end
end

def make_id
  SecureRandom.uuid
end

def make_team(args)
  Basketball::Org::Team.new(**args)
end

def make_player(args)
  Basketball::Org::Player.new(**args)
end

def make_division(args)
  Basketball::Org::Division.new(**args)
end

def make_conference(args)
  Basketball::Org::Conference.new(**args)
end

def make_league(args)
  Basketball::Org::League.new(**args)
end

def make_teams(count = 5)
  [].tap do |teams|
    count.times do
      teams << make_team(id: make_id)
    end
  end
end

def make_divisions(count = 3)
  [].tap do |divisions|
    count.times do
      divisions << make_division(
        id: make_id,
        teams: make_teams(5)
      )
    end
  end
end

def make_conferences(count = 2)
  [].tap do |conferences|
    count.times do
      conferences << make_conference(
        id: make_id,
        divisions: make_divisions(3)
      )
    end
  end
end
