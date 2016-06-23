# frozen_string_literal: true

class Scopie::Base
  TRUE_VALUES = ['true', true, '1', 1]

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

  def key_name(scope_name, options)
    key_name = scope_name
    key_name = options[:as] if options.key?(:as)
    key_name
  end

  def scope_value(scope_name, options, hash)
    key_name = key_name(scope_name, options)
    return coerce_value_type(hash[key_name], options[:type]) if hash.key?(key_name)
    options[:default]
  end

  def coerce_value_type(value, type)
    return value unless type
    send("coerce_to_#{type}", value)
  end

  def coerce_to_boolean(value)
    TRUE_VALUES.include? value
  end

  def scope_applicable?(scope_name, options, hash, method)
    methods_white_list = Array(options[:only])
    methods_black_list = Array(options[:except])

    if method
      return false if methods_black_list.include?(method)
      return false if methods_white_list.any? && !methods_white_list.include?(method)
    end

    key_name = key_name(scope_name, options)
    hash.key?(key_name) || options.key?(:default)
  end

  def self.reset_scopes_configuration!
    @scopes_configuration = {}
  end

  private_class_method :reset_scopes_configuration!

end
