# frozen_string_literal: true

require 'spec_helper'
require 'scheduling_helper'

describe Basketball::Scheduling::Game do
  subject(:game) { described_class.new(date:, home_team:, away_team:) }

  let(:date)      { Date.parse('2023-01-02') }
  let(:home_team) { make_team(id: 'ht') }
  let(:away_team) { make_team(id: 'at') }

  describe 'initialization' do
    it 'sets date' do
      expect(game.date).to eq(date)
    end

    it 'sets home_team' do
      expect(game.home_team).to eq(home_team)
    end

    it 'sets away_team' do
      expect(game.away_team).to eq(away_team)
    end

    it 'prevents team from playing itself' do
      expect do
        described_class.new(
          date:,
          home_team:,
          away_team: home_team
        )
      end.to raise_error(ArgumentError)
    end
  end
end
