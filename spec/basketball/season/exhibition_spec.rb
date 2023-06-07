# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Season::Exhibition do
  subject(:game) { described_class.new(date:, home_opponent:, away_opponent:) }

  let(:date) { Date.parse('2023-01-02') }
  let(:home_opponent) { Basketball::Org::Team.new(id: 'ht') }
  let(:away_opponent) { Basketball::Org::Team.new(id: 'at') }

  describe '#to_s' do
    it 'includes exhibition' do
      expect(game.to_s).to include('exhibition')
    end
  end
end
