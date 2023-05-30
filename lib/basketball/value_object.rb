# frozen_string_literal: true

require_relative 'value_object_dsl'

module Basketball
  # A Value Object is something that has no specific identity, instead its identity is the sum of
  # the attribute values. Changing one will change the entire object's identity.
  # Comes with a very simple DSL provided by ValueObjectDSL for specifying properties along with
  # base equality and sorting methods.
  class ValueObject
    include Comparable
    extend ValueObjectDSL

    def to_s
      to_h.map { |k, v| "#{k}: #{v}" }.join(', ')
    end

    def to_h
      self.class.all_sorted_value_keys.to_h { |k| [k, send(k)] }
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
      self.class.all_sorted_value_keys.map { |k| self[k] }
    end
  end
end
