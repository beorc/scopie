# frozen_string_literal: true
require 'support/subject_class'

describe Scopie do
  it 'has a version number' do
    expect(Scopie::VERSION).not_to be nil
  end

  describe '.apply_scopes' do
    let(:scopie_class) { SubjectClass }
    let(:scopie_instance) { scopie_class.new }
    let(:scope_name) { :test_scope }
    let(:another_scope_name) { :another_scope }
    let(:target) { double }
    let(:scope_value) { 'test' }
    let(:hash) { { scope_name => scope_value } }
    let(:options) { Hash.new }

    before(:each) { scopie_class.has_scope(scope_name, another_scope_name, options) }

    it 'should sequently call scope methods on target' do
      expect(target).to receive(scope_name).once.with(hash[scope_name])
      Scopie.apply_scopes(target, hash, scopie: scopie_instance)
    end

    context 'given blank value' do
      let(:scope_value) { '' }

      it 'should not call the scope method' do
        expect(target).not_to receive(scope_name)
        Scopie.apply_scopes(target, hash, scopie: scopie_instance)
      end

      context 'given the "allow_blank" option' do
        let(:options) { { allow_blank: true } }

        it 'should call the scope method on target' do
          expect(target).to receive(scope_name).once.with(scope_value)
          Scopie.apply_scopes(target, hash, scopie: scopie_instance)
        end
      end
    end

    context 'given the "only" option' do
      let(:options) { { only: :index } }

      context 'given an allowed method name' do
        let(:method_name) { :index }

        it 'should call the scope method on target' do
          expect(target).to receive(scope_name).once.with(scope_value)
          Scopie.apply_scopes(target, hash, method: method_name, scopie: scopie_instance)
        end
      end

      context 'given a not allowed method name' do
        let(:method_name) { :show }

        it 'should not call the scope method on target' do
          expect(target).not_to receive(scope_name)
          Scopie.apply_scopes(target, hash, method: method_name, scopie: scopie_instance)
        end
      end
    end

    context 'given the "except" option' do
      let(:options) { { except: :index } }

      context 'given an allowed method name' do
        let(:method_name) { :show }

        it 'should call the scope method on target' do
          expect(target).to receive(scope_name).once.with(hash[scope_name])
          Scopie.apply_scopes(target, hash, method: method_name, scopie: scopie_instance)
        end
      end

      context 'given a not allowed method name' do
        let(:method_name) { :index }

        it 'should not call the scope method on target' do
          expect(target).not_to receive(scope_name)
          Scopie.apply_scopes(target, hash, method: method_name, scopie: scopie_instance)
        end
      end
    end

    context 'given the "default" option' do
      let(:options) { { default: :default_value } }
      before(:each) do
        expect(scopie_instance).to receive(another_scope_name).once.with(target, options[:default], hash)
      end

      context 'given a hash without the scope key' do
        let(:hash) { Hash.new }

        it 'should call the scope method on target with default value' do
          expect(target).to receive(scope_name).once.with(options[:default]).and_return(target)
          Scopie.apply_scopes(target, hash, scopie: scopie_instance)
        end
      end

      context 'given a hash with the scope key' do
        it 'should not call the scope method on target' do
          expect(target).to receive(scope_name).once.with(hash[scope_name]).and_return(target)
          Scopie.apply_scopes(target, hash, scopie: scopie_instance)
        end
      end
    end

    context 'given the "type: :boolean" option' do
      let(:options) { { type: :boolean } }

      context 'given a hash with the scope key' do
        let(:hash) { { scope_name => 'true' } }

        it 'should call the scope method on target and pass coerced value' do
          expect(target).to receive(scope_name).once.with(true).and_return(target)
          Scopie.apply_scopes(target, hash, scopie: scopie_instance)
        end
      end
    end

    context 'given the "type: :integer" option' do
      let(:options) { { type: :integer } }

      context 'given a hash with the scope key' do
        let(:hash) { { scope_name => '123' } }

        it 'should call the scope method on target and pass coerced value' do
          expect(target).to receive(scope_name).once.with(123).and_return(target)
          Scopie.apply_scopes(target, hash, scopie: scopie_instance)
        end
      end
    end

    context 'given the "type: :float" option' do
      let(:options) { { type: :float } }

      context 'given a hash with the scope key' do
        let(:hash) { { scope_name => '1.23' } }

        it 'should call the scope method on target and pass coerced value' do
          expect(target).to receive(scope_name).once.with(1.23).and_return(target)
          Scopie.apply_scopes(target, hash, scopie: scopie_instance)
        end
      end
    end

    context 'given the "type: :date" option' do
      let(:options) { { type: :date } }

      context 'given a hash with the scope key' do
        let(:hash) { { scope_name => '2016-06-01' } }

        it 'should call the scope method on target and pass coerced value' do
          expect(target).to receive(scope_name).once.with(Date.parse(hash[scope_name])).and_return(target)
          Scopie.apply_scopes(target, hash, scopie: scopie_instance)
        end
      end
    end

    context 'given the scope metod defined in scopie' do
      let(:hash) { { another_scope_name => 'true' } }

      it 'should call the scope method on scopie' do
        expect(scopie_instance).to receive(another_scope_name).once.with(target, hash[another_scope_name], hash)
        Scopie.apply_scopes(target, hash, scopie: scopie_instance)
      end
    end

    context 'given the "in" option' do
      let(:scope_name) { :fulltext_search }
      let(:options) { { in: :search } }
      before(:each) { scopie_class.has_scope(scope_name, options) }

      context 'given a hash with the scope key' do
        let(:test_value) { 'test search text' }
        let(:hash) { { options[:in] => { scope_name => test_value } } }

        it 'should call the scope method on target and pass correct value' do
          expect(target).to receive(scope_name).once.with(test_value)
          Scopie.apply_scopes(target, hash, scopie: scopie_instance)
        end
      end
    end

    context 'given the "as" option' do
      let(:scope_name) { :fulltext_search }
      let(:options) { { as: :search_text } }
      before(:each) { scopie_class.has_scope(scope_name, options) }

      context 'given a hash with the scope key' do
        let(:hash) { { options[:as] => 'search text' } }

        it 'should call the scope method on target and pass correct value' do
          expect(target).to receive(scope_name).once.with(hash[options[:as]])
          Scopie.apply_scopes(target, hash, scopie: scopie_instance)
        end
      end
    end

    context 'given "in" and "as" options' do
      let(:scope_name) { :fulltext_search }
      let(:options) { { as: :search_text, in: :search } }
      before(:each) { scopie_class.has_scope(scope_name, options) }

      context 'given a hash with the scope key' do
        let(:test_value) { 'test search text' }
        let(:hash) { { options[:in] => { options[:as] => test_value } } }

        it 'should call the scope method on target and pass correct value' do
          expect(target).to receive(scope_name).once.with(test_value)
          Scopie.apply_scopes(target, hash, scopie: scopie_instance)
        end
      end
    end
  end

  describe '.current_scopes' do
    let(:scopie_class) { SubjectClass }
    let(:scopie_instance) { scopie_class.new }
    let(:scope_name) { :test_scope }
    let(:another_scope_name) { :another_scope }
    let(:target) { double }
    let(:hash) { { scope_name => 'test' } }
    let(:options) { Hash.new }

    before(:each) { scopie_class.has_scope(scope_name, another_scope_name, options) }

    it 'should return a hash that contains scopes with its values' do
      scopes = Scopie.current_scopes(hash, scopie: scopie_instance)
      expect(scopes).to eq({ scope_name => hash[scope_name] })
    end
  end
end
