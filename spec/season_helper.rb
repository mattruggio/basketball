# frozen_string_literal: true

def read_league_fixture(*path)
  Basketball::Season::LeagueSerializer.new.deserialize(read_fixture(*path))
end

def make_id
  SecureRandom.uuid
end

def make_preseason_game(args)
  Basketball::Season::PreseasonGame.new(**args)
end

def make_season_game(args)
  Basketball::Season::SeasonGame.new(**args)
end

def make_team(args)
  Basketball::Season::Team.new(**args)
end

def make_division(args)
  Basketball::Season::Division.new(**args)
end

def make_conference(args)
  Basketball::Season::Conference.new(**args)
end

def make_league(args)
  Basketball::Season::League.new(**args)
end

def make_teams(count = 5)
  [].tap do |teams|
    count.times do
      teams << make_team(id: make_id, name: Faker::Team.name)
    end
  end
end

def make_divisions(count = 3)
  [].tap do |divisions|
    count.times do
      divisions << make_division(
        id: make_id,
        name: Faker::Address.community,
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
        name: Faker::Address.community,
        divisions: make_divisions(3)
      )
    end
  end
end
