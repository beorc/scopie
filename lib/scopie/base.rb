# frozen_string_literal: true

class Scopie::Base

  def self.scopes_configuration
    instance_variable_get(:@scopes_configuration) || {}
  end

  def scopes_configuration
    self.class.scopes_configuration
  end

  def self.has_scope(*scopes, **options)
    @scopes_configuration ||= {}

    scopes.each do |scope|
      @scopes_configuration[scope.to_sym] = options
    end
  end

  def apply_scopes(target, hash, method = nil)
    current_scopes(hash, method).each do |scope_name, value|
      target = apply_scope(scope_name, target, value, hash)
    end

    target
  end

  def current_scopes(hash, method = nil)
    scopes = scopes_configuration.map do |scope_name, options|
      value = scope_value(scope_name, options, hash)
      next unless scope_applicable?(value, options, method)

      [scope_name, value.coerced]
    end

    scopes.compact!
    scopes.to_h
  end

  private

  def apply_scope(scope_name, target, value, hash)
    result = if respond_to?(scope_name)
               public_send(scope_name, target, value, hash)
             else
               target.public_send(scope_name, value)
             end

    result || target
  end

  def key_name(scope_name, options)
    key_name = scope_name
    key_name = options[:as] if options.key?(:as)
    key_name
  end

  def scope_value(scope_name, options, hash)
    key_name = key_name(scope_name, options)
    reduced_hash = reduced_hash(hash, options)

    Scopie::Value.new(reduced_hash, key_name, options)
  end

  def scope_applicable?(value, options, method)
    return false unless method_applicable?(method, options)
    return false unless value.given?

    value.present? || !!options[:allow_blank]
  end

  def reduced_hash(hash, options)
    return hash unless options.key?(:in)
    hash.fetch(options[:in], {})
  end

  def method_applicable?(method, options)
    return true unless method

    methods_white_list = Array(options[:only])
    methods_black_list = Array(options[:except])

    return false if methods_black_list.include?(method)
    return false if methods_white_list.any? && !methods_white_list.include?(method)

    true
  end

  def self.reset_scopes_configuration!
    @scopes_configuration = {}
  end

  private_class_method :reset_scopes_configuration!

end
