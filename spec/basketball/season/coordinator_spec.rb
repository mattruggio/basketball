# frozen_string_literal: true

require 'spec_helper'
require 'season_helper'

describe Basketball::Season::Coordinator do
  subject(:coordinator) { described_class.new }

  let(:league) { read_league_fixture('season', 'league.json') }
  let(:year)   { 2023 }

  describe '#schedule' do
    specify 'all teams play between 3 and 6 preseason games' do
      calendar = coordinator.schedule(year:, league:)

      league.teams.each do |team|
        count = calendar.preseason_games_for(team:).length

        expect(count).to be_between(3, 6), "#{team} only plays #{count} preseason games"
      end
    end

    specify 'all teams play 82 eseason games' do
      calendar = coordinator.schedule(year:, league:)

      league.teams.each do |team|
        count = calendar.season_games_for(team:).length

        expect(count).to eq(82), "#{team} plays #{count} season games"
      end
    end
  end
end
