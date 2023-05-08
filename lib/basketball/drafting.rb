# frozen_string_literal: true

require_relative 'drafting/cli'

module Basketball
  module Drafting
    class PlayerAlreadyRegisteredError < StandardError; end
  end
end
