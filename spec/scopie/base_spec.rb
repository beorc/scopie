# frozen_string_literal: true
require 'support/subject_class'

describe Scopie::Base do
  let(:scope_name) { :test_scope }
  let(:another_scope_name) { :another_scope }
  let(:only_method_name) { :only_test_method }
  let(:except_method_name) { :except_test_method }
  let(:subject) { described_class.new }
  let(:target) { double }
  let(:another_target) { double }
  let(:options) do
    {
      only: [only_method_name.to_s],
      except: [except_method_name.to_s]
    }
  end

  before(:each) do
    described_class.has_scope(scope_name, { only: only_method_name, except: except_method_name })
    described_class.has_scope(another_scope_name)
  end

  describe '.has_scope' do
    it 'should store scope configuration' do
      expect(described_class.scopes_configuration[scope_name]).to eq options
    end
  end

  describe '#scopes_configuration' do
    it 'should be a hash containing scopes configuration' do
      expect(subject.scopes_configuration).to eq({
                                                   test_scope:
                                                     {
                                                       only: ['only_test_method'],
                                                       except: ['except_test_method']
                                                     },
                                                   another_scope:
                                                     {
                                                       only: [],
                                                       except: []
                                                     }
                                                 })
    end
  end

  describe '#apply_scopes' do
    context 'given the hash containing two scope values' do
      let(:hash) { { scope_name => '0', another_scope_name => :another_value } }

      it 'should call the scope methods on target and return target' do
        expect(target).to receive(scope_name).once.with(hash[scope_name]).and_return(target)
        expect(target).to receive(another_scope_name).once.with(hash[another_scope_name]).and_return(another_target)
        expect(subject.apply_scopes(target, hash)).to eq another_target
      end
    end

    context 'given the hash containing one scope value' do
      let(:hash) { { scope_name => '0' } }

      it 'should call the apply_scope on subject and return target' do
        expect(subject).to receive(:apply_scope).once.with(scope_name, target, hash[scope_name], hash).and_return(target)
        expect(subject.apply_scopes(target, hash)).to eq target
      end
    end

    context 'given scopie having scope method defined' do
      let(:scopie_class) { SubjectClass }
      let(:subject) { scopie_class.new }

      context 'given the hash containing one scope value' do
        let(:hash) { { another_scope_name => :another_value } }

        it 'should call the scopie method' do
          expect(subject).to receive(another_scope_name).once.with(target, hash[another_scope_name], hash).and_return(target)
          expect(subject.send(:apply_scope, another_scope_name, target, hash[another_scope_name], hash)).to eq target
        end
      end
    end
  end

  describe '#apply_scope' do
    let(:value) { '0' }
    let(:hash) { { scope_name => value, another_scope_name => :another_value } }
    let(:result) { target }

    it 'should call the scope method on target and return target' do
      expect(target).to receive(scope_name).once.with(value).and_return(target)
      expect(subject.send(:apply_scope, scope_name, target, value, hash)).to eq target
    end

    context 'given true result' do
      let(:result) { true }

      it 'should call the scope method on target and return target' do
        expect(target).to receive(scope_name).once.with(value).and_return(result)
        expect(subject.send(:apply_scope, scope_name, target, value, hash)).to eq target
      end
    end

    context 'given scopie having scope method defined' do
      let(:scopie_class) { SubjectClass }
      let(:subject) { scopie_class.new }

      it 'should call the scopie method' do
        expect(subject).to receive(another_scope_name).once.with(target, hash[another_scope_name], hash).and_return(target)
        expect(subject.send(:apply_scope, another_scope_name, target, hash[another_scope_name], hash)).to eq target
      end
    end
  end

  describe '#current_scopes' do
    context 'given hash' do
      let(:value) { '0' }
      let(:hash) { { scope_name => value, another_scope_name => :another_value } }

      context 'given the only method' do
        it 'should be a hash containing scopes and values for given action' do
          expect(subject.current_scopes(hash, only_method_name)).to eq({ scope_name => value, another_scope_name => hash[another_scope_name] })
        end
      end

      context 'given no method' do
        it 'should be a hash containing scopes and values' do
          expect(subject.current_scopes(hash)).to eq({ scope_name => value, another_scope_name => hash[another_scope_name] })
        end
      end

      context 'given the except method' do
        it 'should be a hash containing global scopes and values' do
          expect(subject.current_scopes(hash, except_method_name)).to eq({ another_scope_name => hash[another_scope_name] })
        end
      end
    end
  end

  describe '#scope_applicable?' do
    context 'given the applicable value' do
      let(:hash) { { scope_name => '0' } }
      let(:value) { Scopie::Value.new(hash, scope_name, options) }

      context 'given the applicable method' do
        let(:method) { only_method_name }

        it 'should return true' do
          expect(subject.send(:scope_applicable?, value, options, method)).to eq true
        end
      end

      context 'given the not applicable method' do
        let(:method) { except_method_name }

        it 'should return false' do
          expect(subject.send(:scope_applicable?, value, options, method)).to eq false
        end
      end
    end

    context 'given the hash without the scope key' do
      let(:hash) { { unknown: 'test' } }
      let(:value) { Scopie::Value.new(hash, scope_name, options) }

      context 'given the applicable method' do
        let(:method) { only_method_name }

        it 'should return false' do
          expect(subject.send(:scope_applicable?, value, options, method)).to eq false
        end
      end
    end

    context 'given the hash with blank value' do
      let(:hash) { { scope_name => '' } }
      let(:value) { Scopie::Value.new(hash, scope_name, options) }

      context 'given the applicable method' do
        let(:method) { only_method_name }

        it 'should return false' do
          expect(subject.send(:scope_applicable?, value, options, method)).to eq false
        end

        context 'given the :allow_blank option set to true' do
          before(:each) { options[:allow_blank] = true }

          it 'should return true' do
            expect(subject.send(:scope_applicable?, value, options, method)).to eq true
          end
        end

        context 'given the :allow_blank option set to false' do
          before(:each) { options[:allow_blank] = false }

          it 'should return false' do
            expect(subject.send(:scope_applicable?, value, options, method)).to eq false
          end
        end
      end
    end
  end

  describe '#reduced_hash' do
    context 'given no :in option' do
      let(:options) { Hash.new }

      it 'should return all hash' do
        expect(subject.send(:reduced_hash, hash, options)).to eq hash
      end
    end

    context 'given the :in option' do
      let(:options) { { in: :search } }

      context 'given the applicable nested hash' do
        let(:hash) { { search: { scope_name => '0' } } }

        it 'should return all hash' do
          expect(subject.send(:reduced_hash, hash, options)).to eq hash[:search]
        end
      end

      context 'given the not applicable nested hash' do
        let(:hash) { { scope_name => '0' } }

        it 'should return empty hash' do
          expect(subject.send(:reduced_hash, hash, options)).to eq({})
        end
      end
    end
  end

  describe '#method_applicable?' do
    context 'given no method' do
      let(:method) { nil }
      let(:options) { { except: [], only: [] } }

      it 'should return true' do
        expect(subject.send(:method_applicable?, method, options)).to eq true
      end
    end

    context 'given black list' do
      let(:options) { { only: [], except: ['index'] } }

      context 'given the blacklisted method' do
        let(:method) { :index }

        it 'should return false' do
          expect(subject.send(:method_applicable?, method, options)).to eq false
        end
      end

      context 'given the not blacklisted method' do
        let(:method) { :show }

        it 'should return true' do
          expect(subject.send(:method_applicable?, method, options)).to eq true
        end
      end
    end

    context 'given white list' do
      let(:options) { { only: ['index'], except: [] } }

      context 'given the not whitelisted method' do
        let(:method) { :show }

        it 'should return false' do
          expect(subject.send(:method_applicable?, method, options)).to eq false
        end
      end

      context 'given the whitelisted method' do
        let(:method) { :index }

        it 'should return true' do
          expect(subject.send(:method_applicable?, method, options)).to eq true
        end
      end

      context 'given no method' do
        let(:method) { nil }

        it 'should return true' do
          expect(subject.send(:method_applicable?, method, options)).to eq true
        end
      end
    end
  end

  describe '#key_name' do
    context 'given no :as option' do
      let(:options) { Hash.new }

      it 'should return passed scope name' do
        expect(subject.send(:key_name, scope_name, options)).to eq scope_name
      end
    end

    context 'given the :as option' do
      let(:options) { { as: :aliased_scope_name } }

      it 'should return passed scope name' do
        expect(subject.send(:key_name, scope_name, options)).to eq options[:as]
      end
    end
  end
end
