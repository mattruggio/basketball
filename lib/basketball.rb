# frozen_string_literal: true

require 'faker'
require 'fileutils'
require 'forwardable'
require 'json'
require 'securerandom'
require 'slop'

module Basketball
  autoload(:Drafting, './lib/basketball/drafting.rb')
end
