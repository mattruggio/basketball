# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Draft::Room do
  subject(:room) do
    Basketball::Draft::RoomSerializer.new.deserialize(contents)
  end

  let(:contents) { read_fixture('draft', 'no_fuzz_draft', 'input.json') }

  describe '#undrafted_player_search' do
    it 'returns search instance' do
      expect(room.undrafted_player_search).to be_a Basketball::Draft::PlayerSearch
    end

    it 'contains correct players' do
      expect(room.undrafted_player_search.players).to eq room.undrafted_players
    end
  end
end
