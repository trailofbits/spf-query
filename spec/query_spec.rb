require 'spec_helper'
require 'spf/query/query'

describe SPF::Query do
  subject { described_class }

  describe ".query" do
    let(:domain) { 'gmail.com' }

    it "should return the first SPF record" do
      expect(subject.query(domain)).to be == %{v=spf1 redirect=_spf.google.com}
    end

    context "when _spf.domain.com exists" do
      let(:domain) { 'google.com' }

      it "should return the first SPF record" do
        expect(subject.query(domain)).to be == %{v=spf1 include:_netblocks.google.com include:_netblocks2.google.com include:_netblocks3.google.com ~all}
      end
    end

    context "when given an invalid domain" do
      let(:domain) { 'foo.bar.com' }

      it "should return nil" do
        expect(subject.query(domain)).to be_nil
      end
    end
  end
end
