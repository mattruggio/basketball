# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Season::Exhibition do
  subject(:game) { described_class.new(date:, home_opponent:, away_opponent:, opponent_type:) }

  let(:date)          { Date.parse('2023-01-02') }
  let(:home_opponent) { Basketball::Season::Team.new(id: 'ht') }
  let(:away_opponent) { Basketball::Season::Team.new(id: 'at') }
  let(:opponent_type) { Basketball::Season::OpponentType::INTRA_DIVISIONAL }

  describe '#to_s' do
    it 'includes exhibition' do
      expect(game.to_s).to include('exhibition')
    end
  end
end
