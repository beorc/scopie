describe Scopie::Base do
  let(:scope_name) { :test_scope }
  let(:only_method_name) { :only_test_method }
  let(:except_method_name) { :except_test_method }
  let(:options) do
    {
      only: only_method_name,
      except: except_method_name,
      default: false
    }
  end

  before(:each) { described_class.has_scope(scope_name, options) }

  describe '.has_scope' do
    it 'should store scope configuration' do
      expect(described_class.scopes_configuration[scope_name]).to eq options
    end
  end
end
