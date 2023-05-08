# frozen_string_literal: true

require 'faker'
require 'fileutils'
require 'forwardable'
require 'json'
require 'securerandom'
require 'slop'

# Top-level
require_relative 'basketball/entity'
require_relative 'basketball/value_object'

# Submodules
require_relative 'basketball/drafting'
require_relative 'basketball/scheduling'
