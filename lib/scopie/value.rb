# frozen_string_literal: true

class Scopie::Value < Struct.new(:hash, :key_name, :options)

  TRUE_VALUES = ['true', true, '1', 1].freeze

  def raw
    return hash[key_name] if hash.key?(key_name)
    fetch_default
  end

  def coerced
    coerce_to_type(raw, fetch_type)
  end

  def fetch_type
    options[:type]
  end

  def fetch_default
    options[:default]
  end

  def has_default?
    options.key?(:default)
  end

  def given?
    key_passed? || has_default?
  end

  def key_passed?
    hash.key?(key_name)
  end

  def present?
    value = raw
    value.respond_to?(:empty?) ? !value.empty? : !!value
  end

  private

  def coerce_to_type(value, type)
    return value unless type

    coercion_method_name = "coerce_to_#{type}"

    respond_to?(coercion_method_name, true) || fail(Scopie::InvalidOptionError.new("Unknown value for option 'type' provided: :#{type}"))

    send(coercion_method_name, value)
  end

  def coerce_to_boolean(value)
    TRUE_VALUES.include? value
  end

  def coerce_to_integer(value)
    Integer(value)
  end

  def coerce_to_date(value)
    Date.parse(value)
  end

  def coerce_to_float(value)
    Float(value)
  end

end