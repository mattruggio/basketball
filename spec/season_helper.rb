# frozen_string_literal: true

def make_exhibition(args)
  Basketball::Season::Exhibition.new(**args)
end

def make_regular(args)
  Basketball::Season::Regular.new(**args)
end

class PlayoffGame < Basketball::Season::Game; end

class BadArena < Basketball::Season::Arena
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
      away_score: 1
    )
  end
end

class PredictableArena < Basketball::Season::Arena
  def play(matchup)
    Basketball::Season::Result.new(
      game: matchup.game,
      home_score: 1,
      away_score: 2
    )
  end
end
