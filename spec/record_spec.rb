require 'spec_helper'
require 'spf/query/record'

describe SPF::Query::Record do
  let(:spf) do
    %{v=spf1 ip4:199.16.156.0/22 ip4:199.59.148.0/22 ip4:8.25.194.0/23 ip4:8.25.196.0/23 ip4:204.92.114.203 ip4:204.92.114.204/31 ip4:107.20.52.15 ip4:23.21.83.90 include:_spf.google.com include:_thirdparty.twitter.com all}
  end

  subject { described_class.parse(spf) }

  describe "#initialize" do
    let(:version) { :spf1 }
    let(:rules)   { double(:rules) }

    subject { described_class.new(version,rules) }

    it "should set version" do
      expect(subject.version).to be version
    end

    it "should set rules" do
      expect(subject.rules).to be rules
    end
  end

  describe ".parse" do
    let(:spf) do
      %{v=spf1 ip4:199.16.156.0/22 ip4:199.59.148.0/22 ip4:8.25.194.0/23 ip4:8.25.196.0/23 ip4:204.92.114.203 ip4:204.92.114.204/31 ip4:107.20.52.15 ip4:23.21.83.90 include:_spf.google.com include:_thirdparty.twitter.com all}
    end

    subject { described_class.parse(spf) }

    it "should return a Record" do
      expect(subject).to be_kind_of(Record)
    end
  end

  describe ".query" do
    let(:domain) { 'twitter.com' }

    subject { described_class.query(domain) }

    it "should return a Record" do
      expect(subject).to be_kind_of(Record)
    end

    context "when given a domain without SPF" do
      let(:domain) { 'geocities.com' }

      it "should return nil" do
        expect(subject).to be nil
      end
    end
  end

  describe "#each" do
    it "should enumerate over ever record" do
    end
  end

  describe "#to_s" do
    it "should convert the record back into SPF" do
      expect(subject.to_s).to be == spf
    end
  end

  describe "#inspect" do
    it "should display the raw SPF" do
      expect(subject.inspect).to be == "#<#{described_class}: #{spf}>"
    end
  end
end
