# frozen_string_literal: true

class Scopie::Base

  def self.scopes_configuration
    instance_variable_get(:@scopes_configuration) || {}
  end

  def self.has_scope(*scopes, **options)
    @scopes_configuration ||= {}

    scopes.each do |scope|
      @scopes_configuration[scope.to_sym] = options
    end
  end

  def apply_scope(scope_name, options, target, hash, method = nil)
    hash ||= {}

    return target unless scope_applicable?(scope_name, options, hash, method)

    value = scope_value(scope_name, options, hash)

    if respond_to?(scope_name)
      public_send(scope_name, target, value, hash)
    else
      target.public_send(scope_name, value)
    end
  end

  private

  def scope_value(scope_name, options, hash)
    return hash[scope_name] if hash.has_key?(scope_name)
    options[:default]
  end

  def scope_applicable?(scope_name, options, hash, method)
    methods_white_list = Array(options[:only])
    methods_black_list = Array(options[:except])

    if method
      return false if methods_black_list.include?(method)
      return false if methods_white_list.any? && !methods_white_list.include?(method)
    end

    hash.has_key?(scope_name) || options.has_key?(:default)
  end

  def self.reset_scopes_configuration!
    @scopes_configuration = {}
  end

end
