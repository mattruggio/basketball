# frozen_string_literal: true

require 'spec_helper'

describe Basketball::App::InMemoryStore do
  subject(:store) { described_class.new(data) }

  let(:key)      { '123-456' }
  let(:contents) { 'abc123' }
  let(:data)     { {} }

  describe '#exist?' do
    it 'returns true' do
      data[key] = contents

      expect(store.exist?(key)).to be true
    end

    it 'returns false' do
      expect(store.exist?(key)).to be false
    end
  end

  describe '#read' do
    it 'returns contents' do
      data[key] = contents

      expect(store.read(key)).to eq(contents)
    end

    it 'raises PathNotFoundError' do
      expect { store.read(key) }.to raise_error(described_class::KeyNotFoundError)
    end
  end

  describe '#write' do
    it 'writes contents' do
      store.write(key, contents)

      expect(data[key]).to eq(contents)
    end
  end

  describe '#delete' do
    it 'returns nil' do
      data[key] = contents

      expect(store.delete(key)).to be_nil
    end

    it 'raises PathNotFoundError' do
      expect { store.delete(key) }.to raise_error(described_class::KeyNotFoundError)
    end
  end
end
