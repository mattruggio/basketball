# frozen_string_literal: true

require 'spec_helper'

describe Basketball::App::DocumentRepository do
  subject(:repository) { described_class.new(store) }

  let(:key)       { '123-abc' }
  let(:store)     { Basketball::App::InMemoryStore.new }
  let(:entity)    { Basketball::Entity.new }
  let(:json_hash) { { id: key } }

  describe '#save' do
    specify 'underlying JSON in the store is correct' do
      repository.save(key, entity)

      actual = json_parse(store.data[key])

      expect(actual).to eq(json_hash)
    end
  end

  describe '#load' do
    specify 'underlying JSON in the store is correct' do
      store.data[key] = json_hash.to_json
      entity.send('id=', key)

      actual = repository.load(key)

      expect(actual).to eq(entity)
    end
  end

  describe '#delete' do
    specify 'value is removed from store' do
      store.data[key] = json_hash.to_json
      entity.send('id=', key)

      repository.delete(entity)

      expect(store.data[key]).to be_nil
    end

    specify 'returns true' do
      store.data[key] = json_hash.to_json
      entity.send('id=', key)

      expect(repository.delete(entity)).to be true
    end

    context 'when object has no id' do
      specify 'returns false' do
        expect(repository.delete(entity)).to be false
      end
    end
  end
end
