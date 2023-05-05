# frozen_string_literal: true

module Basketball
  class ValueObject
    include Comparable

    class << self
      def value_keys
        @value_keys ||= []
      end

      def sorted_value_keys
        value_keys.sort
      end

      def attr_reader_value(*keys)
        keys.each { |k| value_keys << k.to_sym }

        attr_reader(*keys)
      end
    end

    def to_s
      to_h.map { |k, v| "#{k}: #{v}" }.join(', ')
    end

    def to_h
      self.class.sorted_value_keys.to_h { |k| [k, send(k)] }
    end

    def [](key)
      to_h[key]
    end

    def <=>(other)
      all_sorted_values <=> other.all_sorted_values
    end

    def ==(other)
      to_h == other.to_h
    end
    alias eql? ==

    def hash
      all_sorted_values.map(&:hash).hash
    end

    def all_sorted_values
      self.class.sorted_value_keys.map { |k| self[k] }
    end
  end
end
