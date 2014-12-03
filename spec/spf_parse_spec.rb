require 'spec_helper'
require 'spf/query'

describe SPF::Query do
  describe "spf" do
    context "when given a domain which we know to have a SPF record" do
      let(:domain) { 'trailofbits.com' }

      it "should return a hash containing the SPF record and path where it was found" do
        spf = described_class.check_host(domain)

        expect(spf).to be_kind_of(Hash)
        expect(spf[:record_path]).to ( eq("#{domain}") || eq("_spf.#{domain}") )
        puts "  - record path: #{spf[:record_path]}"
        puts "  - record: #{spf[:record]}"
      end
    end

    context "when given a domain which does not have a SPF record" do
      let(:domain) { 'fsho.trailofbits.com' }

      it "should return nil" do
        spf = described_class.check_host(domain)
        expect(spf).to eq(nil)
      end
    end

    context "when given a bad domain" do
      it "should raise an error explaining that the domain was malformed" do
        expect {
          described_class.check_host('qwerty')
        }.to raise_error
      end
    end
  end
end
