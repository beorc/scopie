# frozen_string_literal: true
describe Scopie::Value do
  let(:key_name) { :fulltext_search }
  let(:value) { 'text' }
  let(:hash) { { key_name => value } }
  let(:options) { Hash.new }
  let(:subject) { described_class.new(hash, key_name, options) }

  describe '#raw' do
    it 'should return not coerced value' do
      expect(subject.raw).to eq value
    end

    context 'given empty hash' do
      let(:hash) { Hash.new }

      context 'given default value' do
        let(:options) { { default: 'default text' } }

        it 'should return default value' do
          expect(subject.raw).to eq options[:default]
        end
      end
    end
  end

  describe '#coerced' do
    context 'given type option :boolean' do
      let(:value) { 'true' }
      let(:options) { { type: :boolean } }

      it 'should return the coerced value' do
        expect(subject.coerced).to eq true
      end
    end

    context 'given type option :integer' do
      let(:value) { '0' }
      let(:options) { { type: :integer } }

      it 'should return the coerced value' do
        expect(subject.coerced).to eq Integer(value)
      end
    end

    context 'given type option :float' do
      let(:value) { '0.101' }
      let(:options) { { type: :float } }

      it 'should return the coerced value' do
        expect(subject.coerced).to eq Float(value)
      end
    end

    context 'given type option :date' do
      let(:value) { '2016-06-01' }
      let(:options) { { type: :date } }

      it 'should return the coerced value' do
        expect(subject.coerced).to eq Date.parse(value)
      end
    end

    context 'given no type option' do
      let(:value) { '0' }
      let(:options) { Hash.new }

      it 'should return the raw value' do
        expect(subject.coerced).to eq value
      end
    end

    context 'given invalid type option' do
      let(:options) { { type: :unknown } }

      it 'should raise exception' do
        expect do
          subject.coerced
        end.to raise_error(Scopie::InvalidOptionError, "Unknown value for option 'type' provided: :#{options[:type]}")
      end
    end
  end

  describe '#present?' do
    context 'given empty value' do
      let(:value) { '' }

      it 'should return false' do
        expect(subject.present?).to eq false
      end
    end

    context 'given integer value' do
      let(:value) { 0 }

      it 'should return true' do
        expect(subject.present?).to eq true
      end
    end

    context 'given empty hash' do
      let(:hash) { Hash.new }

      it 'should return false' do
        expect(subject.present?).to eq false
      end
    end

    context 'given not empty value' do
      it 'should return true' do
        expect(subject.present?).to eq true
      end
    end
  end

  describe '#given?' do
    context 'given value' do
      it 'should return true' do
        expect(subject.given?).to eq true
      end
    end

    context 'given empty hash' do
      let(:hash) { Hash.new }

      it 'should return false' do
        expect(subject.given?).to eq false
      end

      context 'given default value' do
        let(:options) { { default: 'default text' } }

        it 'should return true' do
          expect(subject.given?).to eq true
        end
      end
    end
  end
end
