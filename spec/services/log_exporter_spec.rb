require 'spec_helper'

describe LogExporter do

  describe 'components_to_date' do
    it 'should return nil if none provided' do
      ctd(nil, nil).should be_nil
      ctd('', '').should be_nil
    end

    it "should return the date" do
      ctd("2012-05-07", '').strftime("%Y-%m-%d %H:%M:%S").should == "2012-05-07 00:01:00"
      ctd("07/05/2012", "5:00").strftime("%Y-%m-%d %H:%M:%S").should == "2012-05-07 05:00:00"
    end

  end

  def ctd(d, t)
    LogExporter.send(:convert_date, d, t)
  end

end
