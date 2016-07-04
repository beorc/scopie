# frozen_string_literal: true

module Scopie
  RESULTS_TO_IGNORE = [true, false].freeze

  require 'scopie/version'
  require 'scopie/invalid_type_error'
  require 'scopie/value'
  require 'scopie/base'

  # Receives an object where scopes will be applied to.
  #
  #   class GraduationsScopie < Scopie::Base
  #     has_scope :featured, type: :boolean
  #     has_scope :by_degree, :by_period
  #   end
  #
  #   class GraduationsController < ApplicationController
  #     def index
  #       @graduations = Scopie.apply_scopes(Graduation, method: :index, scopie: GraduationsScopie.new).all
  #     end
  #   end
  #
  def self.apply_scopes(target, hash, method: nil, scopie: Scopie::Base.new)
    scopie.apply_scopes(target, hash, method)
  end

  # Returns the scopes used in this action.
  def self.current_scopes(hash, method: nil, scopie: Scopie::Base.new)
    scopie.current_scopes(hash, method)
  end
end
