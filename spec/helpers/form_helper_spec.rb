require 'spec_helper'

describe FormHelper do

  describe 'collecting?' do
    let(:config)      { {} }
    let(:app_config)  { config }

    it 'should return TRUE when is set to TRUE' do
      config['collect_field'] = true
      collecting.should be_true
    end

    it 'should return FALSE when is set to FALSE' do
      config['collect_field'] = false
      collecting.should be_false
    end

    it 'should return FALSE when is not set' do
      collecting.should be_false
    end

    private

    def collecting
      helper.collecting?('field', app_config)
    end
  end
end
