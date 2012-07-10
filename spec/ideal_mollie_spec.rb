require 'spec_helper'

describe IdealMollie do
  before(:each) do
    @config = IdealMollie::Config
    @config.reset!
    @config.test_mode = false
    @config.partner_id = 987654
    @config.report_url = "http://example.org/report"
    @config.return_url = "http://example.org/return"
  end

  context "#banks" do
    it "returns an array with banks" do
      VCR.use_cassette("banks") do
        banks = IdealMollie.banks
        banks.is_a?(Array).should be_true
        banks.count > 0

        bank = banks.first
        bank.id.should eq "0031"
        bank.name.should eq "ABN AMRO"
      end
    end
  end

  context "#new_order" do
    it "should return a Order with the correct values" do
      VCR.use_cassette("new_order") do
        order = IdealMollie.new_order(1000, "test", "0031")
        order.transaction_id.should eq "c9f93e5c2bd6c1e7c5bee5c5580c6f83"
        order.amount.should eq 1000
        order.currency.should eq "EUR"
        order.url.should eq "https://www.abnamro.nl/nl/ideal/identification.do?randomizedstring=8433910909&trxid=30000217841224"
        order.message.should eq "Your iDEAL-payment has successfully been setup. Your customer should visit the given URL to make the payment"
      end
    end
    it "should return a Order for profile_key with the correct values" do
      @config.profile_key = "123abc45"
      @config.update!
      VCR.use_cassette("new_order") do
        order = IdealMollie.new_order(1000, "test", "0031")
        order.transaction_id.should eq "474ed7b2735cbe4d1f4fd4da23269263"
        order.amount.should eq 1000
        order.currency.should eq "EUR"
        order.url.should eq "https://www.abnamro.nl/nl/ideal/identification.do?randomizedstring=6616737002&trxid=30000226032385"
        order.message.should eq "Your iDEAL-payment has successfully been setup. Your customer should visit the given URL to make the payment"
      end
    end
    it "should override the return url when specified" do
      params = IdealMollie.new_order_params(1200, "test", "0031")
      params[:returnurl].should eq "http://example.org/return"

      params = IdealMollie.new_order_params(1200, "test", "0031", "http://another.example.org/return")
      params[:returnurl].should eq "http://another.example.org/return"
    end
    it "should not append the profile_key this isn't specified in the config" do
      params = IdealMollie.new_order_params(1200, "test", "0031")
      params.has_key?(:profile_key).should be_false
    end
    it "should append the profile_key if specified in the config" do
      @config.profile_key = 12345
      @config.update!

      params = IdealMollie.new_order_params(1200, "test", "0031")
      params.has_key?(:profile_key).should be_true
    end
  end

  context "#check_order" do
    it "should return a OrderResult with the correct values" do
      VCR.use_cassette("check_order") do
        order_result = IdealMollie.check_order("c9f93e5c2bd6c1e7c5bee5c5580c6f83")
        order_result.transaction_id.should eq "c9f93e5c2bd6c1e7c5bee5c5580c6f83"
        order_result.amount.should eq 1000
        order_result.currency.should eq "EUR"
        order_result.paid.should eq false
        order_result.message.should eq "This iDEAL-order wasn't payed for, or was already checked by you. (We give payed=true only once, for your protection)"
        order_result.status.should eq "CheckedBefore"
      end
    end

    it "should mark the OrderResult as paid and contain the customer information when called by mollie" do
      VCR.use_cassette("check_order") do
        order_result = IdealMollie.check_order("482d599bbcc7795727650330ad65fe9b")
        order_result.transaction_id.should eq "482d599bbcc7795727650330ad65fe9b"
        order_result.amount.should eq 1000
        order_result.currency.should eq "EUR"
        order_result.paid.should eq true
        order_result.message.should eq "This iDEAL-order has successfuly been payed for, and this is the first time you check it."

        order_result.customer_name.should eq "Hr J Janssen"
        order_result.customer_account.should eq "P001234567"
        order_result.customer_city.should eq "Amsterdam"
      end
    end
  end
end
