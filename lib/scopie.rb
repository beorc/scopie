# frozen_string_literal: true

module Scopie

  class InvalidOptionError < StandardError; end

  require 'scopie/value'
  require 'scopie/base'

  def self.apply_scopes(target, hash, method: nil, scopie: Scopie::Base.new)
    scopie.apply_scopes(target, hash, method)
  end

  def self.current_scopes(hash, method: nil, scopie: Scopie::Base.new)
    scopie.current_scopes(hash, method)
  end

end
