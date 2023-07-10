# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Season::Record do
  subject(:record) { described_class.new(id: bunnies.id, details: [home_detail, away_detail]) }

  let(:bunnies) { Basketball::Season::Team.new(id: 'bunnies') }
  let(:rabbits) { Basketball::Season::Team.new(id: 'rabbits') }

  let(:home_detail) do
    Basketball::Season::Detail.new(
      date: Date.new(2023, 1, 2),
      home: true,
      opponent: Basketball::Season::Team.new(id: rabbits.id),
      opponent_score: 1,
      score: 2,
      opponent_type: Basketball::Season::OpponentType::INTRA_DIVISIONAL
    )
  end

  let(:away_detail) do
    Basketball::Season::Detail.new(
      date: Date.new(2023, 1, 3),
      home: false,
      opponent: Basketball::Season::Team.new(id: rabbits.id),
      opponent_score: 9,
      score: 8,
      opponent_type: Basketball::Season::OpponentType::INTER_CONFERENCE
    )
  end

  describe '#win_count' do
    it 'all' do
      expect(record.win_count).to eq(1)
    end

    it 'intra-divisional' do
      expect(record.win_count(Basketball::Season::OpponentType::INTRA_DIVISIONAL)).to eq(1)
    end

    it 'intra-conference' do
      expect(record.win_count(Basketball::Season::OpponentType::INTRA_CONFERENCE)).to eq(0)
    end

    it 'inter-conference' do
      expect(record.win_count(Basketball::Season::OpponentType::INTER_CONFERENCE)).to eq(0)
    end
  end

  describe '#loss_count' do
    it 'all' do
      expect(record.loss_count).to eq(1)
    end

    it 'intra-divisional' do
      expect(record.loss_count(Basketball::Season::OpponentType::INTRA_DIVISIONAL)).to eq(0)
    end

    it 'intra-conference' do
      expect(record.loss_count(Basketball::Season::OpponentType::INTRA_CONFERENCE)).to eq(0)
    end

    it 'inter-conference' do
      expect(record.loss_count(Basketball::Season::OpponentType::INTER_CONFERENCE)).to eq(1)
    end
  end

  describe '#win_percentage_display' do
    it 'has trailing zeros' do
      expect(record.win_percentage_display).to eq('0.500')
    end
  end

  describe '#to_s' do
    it 'contains wins/losses' do
      wins_losses = "#{record.win_count}-#{record.loss_count}"

      expect(record.to_s).to include(wins_losses)
    end
  end
end
