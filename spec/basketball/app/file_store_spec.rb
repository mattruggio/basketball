# frozen_string_literal: true

require 'spec_helper'

describe Basketball::App::FileStore do
  subject(:store) { described_class.new }

  let(:path)     { temp_path("#{SecureRandom.uuid}.txt") }
  let(:contents) { 'abc123' }

  describe '#exist?' do
    it 'returns true' do
      write_file(path, contents)

      expect(store.exist?(path)).to be true
    end

    it 'returns false' do
      expect(store.exist?(path)).to be false
    end
  end

  describe '#read' do
    it 'returns contents' do
      write_file(path, contents)

      expect(store.read(path)).to eq(contents)
    end

    it 'raises PathNotFoundError' do
      expect { store.read(path) }.to raise_error(described_class::PathNotFoundError)
    end
  end

  describe '#write' do
    it 'writes contents' do
      store.write(path, contents)

      expect(File.read(path)).to eq(contents)
    end
  end

  describe '#delete' do
    it 'returns nil' do
      write_file(path, contents)

      expect(store.delete(path)).to be_nil
    end

    it 'raises PathNotFoundError' do
      expect { store.delete(path) }.to raise_error(described_class::PathNotFoundError)
    end
  end
end
