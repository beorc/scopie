## Scopie

[![Code Climate](https://codeclimate.com/github/beorc/scopie/badges/gpa.svg)](https://codeclimate.com/github/beorc/scopie)
[![Build Status](https://travis-ci.org/beorc/scopie.svg?branch=master)](https://travis-ci.org/beorc/scopie)
[![Coverage Status](https://codecov.io/gh/beorc/scopie/branch/master/graph/badge.svg)](https://codecov.io/gh/beorc/scopie)
[![Dependency Status](https://gemnasium.com/beorc/scopie.svg)](https://gemnasium.com/beorc/scopie)
[![Gem Version](https://badge.fury.io/rb/scopie.svg)](https://badge.fury.io/rb/scopie)

A [has_scope](http://github.com/plataformatec/has_scope) alternative.

Scopie allows you to map incoming controller parameters to named scopes in your resources through OO design.

Motivation:

* Dedicated class for scopes mapping, so that the logic is isolated and your controller is skinny.
* Dependencies free. Please have a look at [scopie_rails](http://github.com/beorc/scopie_rails) if you are using Ruby on Rails framework.
* Ability to override default mapping behavior by definition of a method having the same name as a scope in the scopie class.
* Ability to use the object oriented approach to DRY your custom scopes mapping logic and reuse the scopie class.

Imagine the following model called graduations:

```ruby
class Graduation < ActiveRecord::Base

  scope :featured, -> { where(featured: true) }
  scope :by_degree, -> (degree) { where(degree: degree) }
  scope :by_period, -> (started_at, ended_at) { where('started_at = ? AND ended_at = ?', started_at, ended_at) }

  scope :created_at_greater_than, ->(date) { where('created_at >= ?', date.beginning_of_day) }
  scope :created_at_less_than, ->(date) { where('created_at <= ?', date.end_of_day) }

  scope :updated_at_greater_than, ->(date) { where('updated_at >= ?', date.beginning_of_day) }
  scope :updated_at_less_than, ->(date) { where('updated_at <= ?', date.end_of_day) }

end
```

You can use those named scopes as filters by declaring them on your scopie:

```ruby
class GraduationsScopie < Scopie::Base

  has_scope :featured, type: :boolean
  has_scope :by_degree, :by_period

  has_scope :created_at_greater_than, in: :created_at, as: :start_at
  has_scope :created_at_less_than, in: :created_at, as: :end_at

  has_scope :updated_at_greater_than, in: :updated_at, as: :start_at, type: :date
  has_scope :updated_at_less_than, in: :updated_at, as: :end_at, type: :date

  has_scope :page, default: 1
  has_scope :per, default: 30
  
  def by_period(scope, value, _hash)
    started_at = value[:started_at]
    ended_at = value[:ended_at]

    started_at && ended_at && scope.by_period(started_at, ended_at)
  end

  def created_at_greater_than(scope, value, _hash)
    scope.created_at_greater_than(parse_date(value))
  end

  def created_at_less_than(scope, value, _hash)
    scope.created_at_less_than(parse_date(value))
  end

  def updated_at_greater_than(scope, value, _hash)
    scope.updated_at_greater_than(value)
  end

  def updated_at_less_than(scope, value, _hash)
    scope.updated_at_less_than(value)
  end

  private

  def parse_date(value)
    Date.parse(value)
  end

end
```

Now, if you want to apply them to an specific resource, you just need to call `apply_scopes`:

```ruby
class GraduationsController < ApplicationController

  def index
    @graduations = Scopie.apply_scopes(Graduation, method: :index, scopie: GraduationsScopie.new).all
  end

end
```

Then for each request:

```
/graduations
#=> acts like a normal request

/graduations?featured=true
#=> calls the named scope and bring featured graduations

/graduations?by_period[started_at]=20100701&by_period[ended_at]=20101013
#=> brings graduations in the given period

/graduations?created_at[start_at]=2016-06-01&created_at[end_at]=2016-06-02
#=> brings graduations created in the given period

/graduations?featured=true&by_degree=phd
#=> brings featured graduations with phd degree
```

## Installation

Add `scopie` to your Gemfile or install it from Rubygems.

```ruby
gem 'scopie'
```

## Mutation testing

    mutant --include lib --require scopie --use rspec Scopie*

## Options

Scopie supports several options:

* `:type` - Coerces the type of the parameter sent. Available options: boolean, integer, float, date.

* `:only` - In which actions the scope is applied.

* `:except` - In which actions the scope is not applied.

* `:as` - The key in the params hash expected to find the scope. Defaults to the scope name.

* `:in` - The key in the params hash expected to contain a hash holding scope name as a value.

* `:allow_blank` - Blank values are not sent to scopes by default. Set to true to overwrite.

* `:ignore_blank` - Set to true to not apply the scope if blank value is given.

* `:default` - Default value for the scope. Whenever supplied the scope is always called.

## Thanks

Scopie was inspired by [has_scope](http://github.com/plataformatec/has_scope) and [pundit](http://github.com/elabs/pundit).

Thanks to both.
