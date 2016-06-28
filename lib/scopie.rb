# frozen_string_literal: true

module Scopie

  class InvalidOptionError < StandardError; end

  RESULTS_TO_IGNORE = [true, false].freeze

  require 'scopie/value'
  require 'scopie/base'

  def self.apply_scopes(target, hash, method: nil, scopie: Scopie::Base.new)
    scopie.apply_scopes(target, hash, method)
  end

  def self.current_scopes(hash, method: nil, scopie: Scopie::Base.new)
    scopie.current_scopes(hash, method)
  end

end
