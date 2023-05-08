# frozen_string_literal: true

def make_id
  SecureRandom.uuid
end

def make_teams(count = 5)
  [].tap do |teams|
    count.times do
      teams << Basketball::Scheduling::Team.new(id: make_id, name: 'TEAM')
    end
  end
end

def make_divisions(count = 3)
  [].tap do |divisions|
    count.times do
      divisions << Basketball::Scheduling::Division.new(
        id: make_id,
        name: 'DIVISION',
        teams: make_teams(5)
      )
    end
  end
end

def make_conferences(count = 2)
  [].tap do |conferences|
    count.times do
      conferences << Basketball::Scheduling::Conference.new(
        id: make_id,
        name: 'CONFERENCE',
        divisions: make_divisions(3)
      )
    end
  end
end
