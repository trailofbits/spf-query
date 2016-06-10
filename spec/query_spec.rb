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

    context "when the domain.com has a TXT record" do
      let(:domain) { 'yahoo.com' }

      it "should return the TXT record containing the SPF record" do
        expect(subject.query(domain)).to be == %{v=spf1 redirect=_spf.mail.yahoo.com}
      end
    end

    context "when the domain has a SPF type record" do
      let(:domain) { 'getlua.com' }

      it "should prefer the TXT type record over other SPF records" do
        expect_any_instance_of(Resolv::DNS).to_not receive(:getresource).with("getlua.com", Resolv::DNS::Resource::IN::SPF)
        expect_any_instance_of(Resolv::DNS).to receive(:getresources).with("getlua.com", Resolv::DNS::Resource::IN::TXT).at_least(:once).and_call_original
        expect_any_instance_of(Resolv::DNS).to receive(:getresources).with("_spf.getlua.com", Resolv::DNS::Resource::IN::TXT).at_least(:once).and_call_original

        expect(subject.query(domain)).to be == %{v=spf1 include:_spf.google.com include:mail.zendesk.com include:servers.mcsv.net -all}
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
