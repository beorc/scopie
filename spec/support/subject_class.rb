# frozen_string_literal: true

class SubjectClass < Scopie::Base

  def another_scope(target, _value, _hash)
    target
  end

end
