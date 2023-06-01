# frozen_string_literal: true

module Basketball
  module App
    # Knows how to read and write documents to a Ruby Hash.
    class InMemoryStore
      class KeyNotFoundError < StandardError; end

      attr_reader :data

      def initialize(data = {})
        @data = data

        freeze
      end

      def exist?(key)
        data.key?(key.to_s)
      end

      def read(key)
        raise KeyNotFoundError, "'#{key}' not found" unless exist?(key)

        data[key.to_s]
      end

      def write(key, contents)
        data[key.to_s] = contents

        nil
      end

      def delete(key)
        raise KeyNotFoundError, "'#{key}' not found" unless exist?(key)

        data.delete(key)

        nil
      end
    end
  end
end
