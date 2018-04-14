require 'spec_helper'
require 'spf/query/record'

describe SPF::Query::Record do
  let(:spf) do
    %{v=spf1 ip4:199.16.156.0/22 ip4:199.59.148.0/22 ip4:8.25.194.0/23 ip4:8.25.196.0/23 ip4:204.92.114.203 ip4:204.92.114.204/31 ip4:107.20.52.15 ip4:23.21.83.90 include:_spf.google.com include:_thirdparty.twitter.com all}
  end

  subject { described_class.parse(spf) }

  describe "#initialize" do
    let(:version) { :spf1 }

    let(:ip4_rules) do
      [
        Mechanism.new(:ip4, value: IP.new('199.16.156.0', 22)),
        Mechanism.new(:ip4, value: IP.new('199.59.148.0', 22)),
        Mechanism.new(:ip4, value: IP.new('8.25.194.0',   23)),
        Mechanism.new(:ip4, value: IP.new('8.25.196.0',   23)),
        Mechanism.new(:ip4, value: IP.new('204.92.114.203')),
        Mechanism.new(:ip4, value: IP.new('204.92.114.204', 31)),
        Mechanism.new(:ip4, value: IP.new('107.20.52.15')),
        Mechanism.new(:ip4, value: IP.new('23.21.83.90')),
      ]
    end

    let(:include_rules) do
      [
        Mechanism.new(:include, value: '_spf.google.com'),
        Mechanism.new(:include, value: '_thirdparty.twitter.com'),
      ]
    end

    let(:all_rule) { Mechanism.new(:all) }
    let(:rules) { ip4_rules + include_rules + [all_rule] }

    subject { described_class.new(version,rules) }

    it "should set version" do
      expect(subject.version).to be version
    end

    it "should set rules" do
      expect(subject.rules).to be rules
    end

    describe "#mechanisms" do
      subject { super().mechanisms }

      it "should contain every Mechanism object" do
        expect(subject).to all(be_a(Mechanism))
      end
    end

    describe "#modifiers" do
      pending "need to add modifiers"
    end

    describe "#all" do
      subject { super().all }

      it "should find the last all mechanism" do
        expect(subject).to be all_rule
      end
    end

    describe "#include" do
      subject { super().include }

      it "should find all include: mechanisms" do
        expect(subject).to be == include_rules
      end
    end

    describe "#a" do
      subject { super().a }

      pending "need to add a: mechanisms" do
        it "should find all a: mechanisms" do
          expect(subject).to be == a
        end
      end
    end

    describe "#mx" do
      subject { super().mx }

      pending "need to add mx: mechanisms" do
        it "should find all mx: mechanisms" do
          expect(subject).to be == mx
        end
      end
    end

    describe "#ptr" do
      subject { super().ptr }

      pending "need to add ptr: mechanisms" do
        it "should find all ptr: mechanisms" do
          expect(subject).to be == ptr
        end
      end
    end

    describe "#ip4" do
      subject { super().ip4 }

      it "should find all ip4: mechanisms" do
        expect(subject).to be == ip4_rules
      end
    end

    describe "#ip6" do
      subject { super().ptr }

      pending "need to add ip6: mechanisms" do
        it "should find all ip6: mechanisms" do
          expect(subject).to be == ip6_rules
        end
      end
    end

    describe "#ips" do
      it "should contain ip4 mechanisms" do
        expect(subject.ips).to include(*subject.ip4)
      end

      pending "need to add ip6: mechanisms" do
        it "should also contain ip6 mechanisms" do
          expect(subject).to include(*ip6_rules)
        end
      end
    end

    describe "#exists" do
      subject { super().exists }

      pending "need to add exists: mechanisms" do
        it "should find all exists: mechanisms" do
          expect(subject).to be == exists
        end
      end
    end

    describe "#redirect" do
      subject { super().exists }

      pending "need to add a redirect: modifier" do
        it "should find the first redirect: modifier" do
          expect(subject).to be == redirect
        end
      end
    end

    describe "#exp" do
      subject { super().exp }

      pending "need to add a exp: modifier" do
        it "should find the first exp: modifier" do
          expect(subject).to be == exp
        end
      end
    end
  end

  describe ".parse" do
    context "when parsing a valid record" do
      let(:spf) do
        %{v=spf1 ip4:199.16.156.0/22 ip4:199.59.148.0/22 ip4:8.25.194.0/23 ip4:8.25.196.0/23 ip4:204.92.114.203 ip4:204.92.114.204/31 ip4:107.20.52.15 ip4:23.21.83.90 include:_spf.google.com include:_thirdparty.twitter.com all}
      end

      subject { described_class.parse(spf) }

      it "should return a Record" do
        expect(subject).to be_kind_of(Record)
      end
    end

    context "when parsing an invalid record" do
      let(:spf) { %{v=foo} }

      it "should raise an InvalidRecord exception" do
        expect {
          described_class.parse(spf)
        }.to raise_error(InvalidRecord)
      end
    end

    context "when given a SenderID record" do
      let(:sender_id) { "spf2.0/mfrom,pra or spf2.0/pra,mfrom" }

      it "should raise a SenderIDFound exception" do
        expect {
          described_class.parse(sender_id)
        }.to raise_error(SenderIDFound)
      end
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
