# frozen_string_literal: true

module Scopie

  require 'scopie/base'

  def self.apply_scopes(target, hash, method: nil, scopie: Scopie::Base.new)
    scopie.class.scopes_configuration.each do |scope_name, options|
      target = scopie.apply_scope(scope_name, options, target, hash, method)
    end

    target
  end

end
