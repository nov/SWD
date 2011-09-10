require 'spec_helper'

describe SWD do
  after { SWD.debugging = false }

  its(:logger) { should be_a Logger }
  its(:debugging?) { should be_false }
  its(:cache) { should be_a SWD::Cache }

  describe '#discover!' do
    it 'should return SWD::Response' do
      mock_json "https://example.com/.well-known/simple-web-discovery", 'success', :query => {
        :principal => 'mailto:joe@example.com',
        :service => 'urn:adatum.com:calendar'
      } do
        SWD.discover!(
          :principal => 'mailto:joe@example.com',
          :service => 'urn:adatum.com:calendar',
          :host => 'example.com'
        ).should be_a SWD::Response
      end
    end
  end

  describe '.debug!' do
    before { SWD.debug! }
    its(:debugging?) { should be_true }
  end

  describe '.debug' do
    it 'should enable debugging within given block' do
      SWD.debug do
        SWD.debugging?.should be_true
      end
      SWD.debugging?.should be_false
    end

    it 'should not force disable debugging' do
      SWD.debug!
      SWD.debug do
        SWD.debugging?.should be_true
      end
      SWD.debugging?.should be_true
    end
  end
end