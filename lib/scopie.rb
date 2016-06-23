# frozen_string_literal: true

module Scopie

  require 'scopie/base'

  def self.apply_scopes(target, hash, method: nil, scopie: Scopie::Base.new)
    scopie.apply_scopes(target, hash, method)
  end

end
