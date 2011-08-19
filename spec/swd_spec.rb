require 'spec_helper'

describe SWD do
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
end