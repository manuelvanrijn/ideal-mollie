require 'spec_helper'

describe IdealMollie::Config do
  before(:each) do
    @config = IdealMollie::Config
    @config.test_mode = true
    @config.partner_id = 123456
    @config.report_url = "http://example.org/report"
    @config.return_url = "http://example.org/return"
  end
  describe "#reset!" do
    it "should reset the values" do
      @config.reset!
      @config.test_mode.should be_false
      @config.partner_id.should be_nil
      @config.report_url.should be_nil
      @config.return_url.should be_nil
    end
  end
  describe "#update!" do
    it "should update" do
      @config.test_mode = false
      @config.partner_id = 987654
      @config.report_url = "report"
      @config.return_url = "return"
      @config.update!

      config = IdealMollie::Config
      config.test_mode.should be_false
      config.partner_id.should eq 987654
      config.report_url.should eq "report"
      config.return_url.should eq "return"
    end
  end
end
