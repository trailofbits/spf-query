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
        expect(subject.query(domain)).to be == %{v=spf1 include:_spf.google.com ~all}
      end
    end

    context "when the domain.com has a TXT record" do
      let(:domain) { 'yahoo.com' }

      it "should return the TXT record containing the SPF record" do
        expect(subject.query(domain)).to be == %{v=spf1 redirect=_spf.mail.yahoo.com}
      end

      context "and when the record is split into multiple strings" do
        let(:domain) { '_spf.facebook.com' }

        it "should join the strings, without spaces" do
          expect(subject.query(domain)).to be == %{v=spf1 ip4:69.63.179.25 ip4:69.63.178.128/25 ip4:69.63.184.0/25 ip4:66.220.144.128/25 ip4:66.220.155.0/24 ip4:69.171.232.0/24 ip4:66.220.157.0/25 ip4:69.171.244.0/24 mx -all}
        end
      end
    end

    context "when the domain has a SPF type record" do
      let(:domain) { 'getlua.com' }

      it "should prefer the TXT type record over other SPF records" do
        expect_any_instance_of(Resolv::DNS).to_not receive(:getresource).with("getlua.com", Resolv::DNS::Resource::IN::SPF)
        expect_any_instance_of(Resolv::DNS).to receive(:getresources).with("getlua.com", Resolv::DNS::Resource::IN::TXT).at_least(:once).and_call_original

        expect(subject.query(domain)).to be == %{v=spf1 include:_spf.google.com include:mail.zendesk.com include:servers.mcsv.net include:aspmx.pardot.com -all}
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
