require 'spec_helper'
require 'spf_parse/parser'

describe Parser do
  describe "rules" do
    describe "version" do
      subject { super().version }

      it "should match v=spf1" do
        expect(subject.parse('v=spf1')).to be == {version: 'spf1'}
      end
    end

    describe "qualifier" do
      subject { super().qualifier }

      %w[+ - ~ ?].each do |char|
        it "should match '#{char}'" do
          expect(subject.parse(char)).to be == {qualifier: char}
        end
      end

      it "should match other characters" do
        expect { subject.parse('x') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe "name" do
      subject { super().name }

      %w[A AAA A123 A_123 A-123 A.123 A123_ A123- A123.].each do |str|
        it "should parse #{str.inspect}" do
          expect(subject.parse(str)).to be == str
        end
      end
    end

    describe "macro_literal" do
      subject { super().macro_literal }

      [*"\x21".."\x24", *"\x26".."\x7e"].each do |char|
        it "should recognize the #{char.inspect} char" do
          expect(subject.parse(char)).to be == char
        end
      end
    end

    describe "macro_letter" do
      subject { super().macro_letter }

      %w[s l o d i p h c r t].each do |char|
        it "should recognize the '#{char}' char" do
          expect(subject.parse(char)).to be == {letter: char}
        end
      end
    end

    describe "transformers" do
      subject { super().transformers }

      it "should parse \"\"" do
        expect(subject.parse("")).to be == {digit: nil}
      end

      it "should parse a single digit" do
        expect(subject.parse("1")).to be == {digit: "1"}
      end

      it "should parse a multiple digits" do
        expect(subject.parse("123")).to be == {digit: "123"}
      end

      it "should parse 'r'" do
        expect(subject.parse("r")).to be == {digit: nil, reverse: "r"}
      end

      it "should parse a single digit then 'r'" do
        expect(subject.parse("1r")).to be == {digit: "1", reverse: "r"}
      end

      it "should parse a multiple digits then 'r'" do
        expect(subject.parse("123r")).to be == {digit: "123", reverse: "r"}
      end
    end

    describe "delimiter" do
      subject { super().delimiter }

      %w[- . + , / _ =].each do |char|
        it "should match '#{char}'" do
          expect(subject.parse(char)).to be == {char: char}
        end
      end

      it "should not match other characters" do
        expect { subject.parse('x') }.to raise_error(Parslet::ParseFailed)
      end
    end
  end
end
