# frozen_string_literal: true

require 'spec_helper'

describe Basketball::Draft::Skip do
  let(:event) do
    described_class.new(front_office: ducks, pick: 1, round: 1, round_pick: 1)
  end

  let(:ducks) { Basketball::Draft::FrontOffice.new(id: 'ducks') }

  describe '#to_s' do
    it 'contained skipped' do
      expect(event.to_s).to include('skipped')
    end
  end
end
