require 'spec_helper'
require 'spf/query/mechanism'

describe SPF::Query::Mechanism do
  let(:name)      { :all }
  let(:qualifier) { :soft_fail }

  subject { described_class.new(name, qualifier: qualifier) }

  describe "#initialize" do
    it "should set the name" do
      expect(subject.name).to be :all
    end

    it "should set qualifier" do
      expect(subject.qualifier).to be :soft_fail
    end

    context "when qualifier is omitted" do
      subject { described_class.new(:all) }

      it "should default qualifier to :pass" do
        expect(subject.qualifier).to be :pass
      end
    end
  end

  describe "#pass?" do
    subject { described_class.new(name, qualifier: :pass) }

    it "should check if qualifier is :pass" do
      expect(subject.pass?).to be true
    end
  end

  describe "#fail?" do
    subject { described_class.new(name, qualifier: :fail) }

    it "should check if qualifier is :fail" do
      expect(subject.fail?).to be true
    end
  end

  describe "#soft_fail?" do
    subject { described_class.new(name, qualifier: :soft_fail) }

    it "should check if qualifier is :soft_fail" do
      expect(subject.soft_fail?).to be true
    end
  end

  describe "#neutral?" do
    subject { described_class.new(name, qualifier: :neutral) }

    it "should check if qualifier is :neutral" do
      expect(subject.neutral?).to be true
    end
  end

  describe "#to_s" do
    it "should map the qualifier back to a Symbol" do
      expect(subject.to_s).to be == "~#{name}"
    end
  end
end
