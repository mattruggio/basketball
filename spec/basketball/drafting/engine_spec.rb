# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Drafting::Engine do
  subject(:engine) do
    Basketball::Drafting::EngineSerializer.new.deserialize(contents)
  end

  let(:contents) { read_fixture('drafting', 'no_fuzz_draft', 'input.json') }

  describe '#undrafted_player_search' do
    it 'returns search instance' do
      expect(engine.undrafted_player_search).to be_a Basketball::Drafting::PlayerSearch
    end

    it 'contains correct players' do
      expect(engine.undrafted_player_search.players).to eq engine.undrafted_players
    end
  end
end
