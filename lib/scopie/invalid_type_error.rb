# frozen_string_literal: true

class Scopie::InvalidTypeError < StandardError

  def initialize(type)
    @type = type
  end

  def message
    "Unknown value for option 'type' provided: :#{@type}"
  end

end
