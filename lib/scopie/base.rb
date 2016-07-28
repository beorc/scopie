# frozen_string_literal: true

class Scopie::Base

  def self.scopes_configuration
    instance_variable_get(:@scopes_configuration) || {}
  end

  def scopes_configuration
    self.class.scopes_configuration
  end

  # Detects params from url and apply as scopes to your classes.
  #
  # == Options
  #
  # * <tt>:type</tt> - Coerces the type of the parameter sent.
  #
  # * <tt>:only</tt> - In which actions the scope is applied.
  #
  # * <tt>:except</tt> - In which actions the scope is not applied.
  #
  # * <tt>:as</tt> - The key in the params hash expected to find the scope.
  #                  Defaults to the scope name.
  #
  # * <tt>:default</tt> - Default value for the scope. Whenever supplied the scope
  #                       is always called.
  #
  # * <tt>:allow_blank</tt> - Blank values are not sent to scopes by default. Set to true to overwrite.
  #
  # == Method usage
  #
  # You can also define a method having the same name as a scope. The current scope, value and params are yielded
  # to the block so the user can apply the scope on its own. The method can return new scope or the boolean value.
  # In the latter case will be used not modified scope. This is useful in case we
  # need to manipulate the given value:
  #
  #   has_scope :category
  #
  #   def category(scope, value, _hash)
  #     value != 'all' && scope.by_category(value)
  #   end
  #
  #   has_scope :not_voted_by_me, type: :boolean
  #
  #   def not_voted_by_me(scope, _value, _hash)
  #     scope.not_voted_by(controller.current_user.id) # The controller method is available in the scopie_rails gem
  #   end
  #
  def self.has_scope(*scopes, **options)
    @scopes_configuration ||= {}
    normalize_options!(options)

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

    if Scopie::RESULTS_TO_IGNORE.include?(result)
      target
    else
      result
    end
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
    hash.fetch(options[:in]) { {} }
  end

  def method_applicable?(method, options)
    return true unless method
    action = method.to_s

    methods_white_list = options[:only]
    methods_black_list = options[:except]

    return false if methods_black_list.include?(action)
    return false if methods_white_list.any? && !methods_white_list.include?(action)

    true
  end

  def self.reset_scopes_configuration!
    @scopes_configuration = {}
  end

  private_class_method :reset_scopes_configuration!

  def self.normalize_options!(options)
    [:only, :except].each do |key|
      options[key] = Array(options[key]).map(&:to_s)
      options[key].reject!(&:empty?)
    end

    options
  end

  private_class_method :normalize_options!

end
