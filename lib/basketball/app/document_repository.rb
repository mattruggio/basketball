# frozen_string_literal: true

module Basketball
  module App
    # Base class for all repositories which are based on a flat document.
    # At the very minimum sub-classes should implement #to_h(object) and #from_h(hash).
    class DocumentRepository
      attr_reader :store

      def initialize(store = InMemoryStore.new)
        super()

        @store = store
      end

      def load(id)
        contents = store.read(id)

        deserialize(contents).tap do |object|
          object.send('id=', id)
        end
      end

      def save(id, object)
        object.send('id=', id)

        contents = serialize(object)

        store.write(id, contents)

        object
      end

      def delete(object)
        return false unless object.id

        store.delete(object.id)

        object.send('id=', nil)

        true
      end

      protected

      def from_h(hash)
        Entity.new(hash[:id])
      end

      def to_h(entity)
        { id: entity.id }
      end

      private

      def deserialize(string)
        hash = JSON.parse(string, symbolize_names: true)

        from_h(hash)
      end

      def serialize(object)
        to_h(object).to_json
      end
    end
  end
end
