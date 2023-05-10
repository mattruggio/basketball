# frozen_string_literal: true

require 'spec_helper'
require 'scheduling_helper'

describe Basketball::Scheduling::Coordinator do
  subject(:coordinator) { described_class.new }

  let(:league) { read_league_fixture('scheduling', 'league.json') }
  let(:year)   { 2023 }

  describe '#schedule' do
    specify 'all teams play between 4 and 6 preseason games' do
      calendar = coordinator.schedule(year:, league:)

      league.teams.each do |team|
        count = calendar.preseason_games_for(team:).length

        expect(count).to be_between(4, 6), "#{team} only plays #{count} preseason games"
      end
    end
  end
end
