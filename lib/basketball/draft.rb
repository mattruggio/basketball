# frozen_string_literal: true

require_relative 'draft/cli'

module Basketball
  module Draft
    class PlayerAlreadyRegisteredError < StandardError; end
  end
end
