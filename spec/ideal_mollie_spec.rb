require 'spec_helper'

describe IdealMollie do
  before(:each) do
    config = IdealMollie::Config
    config.test_mode = false
    config.partner_id = 987654
    config.report_url = "http://example.org/report"
    config.return_url = "http://example.org/return"
  end

  context "#banks" do
    it "returns an array with banks" do
      VCR.use_cassette("banks") do
        banks = IdealMollie.banks
        banks.class.is_a?Array.should be_true
        banks.count > 0

        bank = banks.first
        bank[:id].should eq "0031"
        bank[:name].should eq "ABN AMRO"
      end
    end
  end

  context "#new_payment" do
    it "should return a transaction hash with the correct values" do
      VCR.use_cassette("new_payment") do
        payment = IdealMollie.new_payment(1000, "test", "0031")
        payment[:transaction_id].should eq "c9f93e5c2bd6c1e7c5bee5c5580c6f83"
        payment[:amount].should eq 1000
        payment[:currency].should eq "EUR"
        payment[:url].should eq "https://www.abnamro.nl/nl/ideal/identification.do?randomizedstring=8433910909&trxid=30000217841224"
        payment[:message].should eq "Your iDEAL-payment has successfully been setup. Your customer should visit the given URL to make the payment"
      end
    end
  end

  context "#check_payment" do
    it "should return a payment response with the correct values" do
      VCR.use_cassette("check_payment") do
        payment = IdealMollie.check_payment("c9f93e5c2bd6c1e7c5bee5c5580c6f83")
        payment[:transaction_id].should eq "c9f93e5c2bd6c1e7c5bee5c5580c6f83"
        payment[:amount].should eq 1000
        payment[:currency].should eq "EUR"
        payment[:payed].should eq false
        payment[:message].should eq "This iDEAL-order wasn't payed for, or was already checked by you. (We give payed=true only once, for your protection)"
        payment[:status].should eq "CheckedBefore"
      end
    end
    it "should mark the transaction as payed and contain the consumer information when called by mollie" do
      VCR.use_cassette("check_payment") do
        payment = IdealMollie.check_payment("482d599bbcc7795727650330ad65fe9b")
        payment[:transaction_id].should eq "482d599bbcc7795727650330ad65fe9b"
        payment[:amount].should eq 1000
        payment[:currency].should eq "EUR"
        payment[:payed].should eq true
        payment[:message].should eq "This iDEAL-order has successfuly been payed for, and this is the first time you check it."
        consumer = payment[:consumer]
        consumer[:name].should eq "Hr J Janssen"
        consumer[:account].should eq "P001234567"
        consumer[:city].should eq "Amsterdam"
      end
    end
  end
end
