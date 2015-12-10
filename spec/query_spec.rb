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

    context "when the domain has a SPF type record" do
      let(:domain) { 'getlua.com' }

      it "should prefer the SPF type record over other TXT records" do
        expect(subject.query(domain)).to be == %{v=spf1 include:_spf.google.com include:mail.zendesk.com include:servers.mcsv.net -all}
      end
    end

    context "when given an invalid domain" do
      let(:domain) { 'foo.bar.com' }

      it "should return nil" do
        expect(subject.query(domain)).to be_nil
      end
    end

    context 'when skip spf record type check' do
      let(:domain) { 'getlua.com' }

      it "skip properly" do
        expect_any_instance_of(Resolv::DNS).not_to receive(:get_resource).with(domain, Resolv::DNS::Resource::IN::SPF)
        subject.query(domain)
      end
    end
  end
end
