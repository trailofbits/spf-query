require 'spec_helper'
require 'spf/query/parser'

describe Parser do
  describe "rules" do
    describe "record" do
      subject { super().record }

      it "should parse a version then multiple terms" do
        expect(subject.parse("v=spf1 -all redirect=_spf.example.com")).to be == {
          version: 'spf1',

          rules: [
            {
              directive: {
                qualifier: '-',
                name: "all"
              }
            },

            {
              modifier: {
                name: 'redirect',
                value: {macro_string: [{literal: '_spf.example.com'}]}
              }
            }
          ]
        }
      end
    end

    describe "version" do
      subject { super().version }

      it "should match v=spf1" do
        expect(subject.parse('v=spf1')).to be == {version: 'spf1'}
      end
    end

    describe "terms" do
      subject { super().terms }

      it "should parse a single term" do
        expect(subject.parse("-all")).to be == {
          directive: {
            qualifier: '-',
            name: "all"
          }
        }
      end

      it "should parse multiple terms separated by one or more spaces" do
        expect(subject.parse("-all  redirect=_spf.example.com")).to be == [
          {
            directive: {
              qualifier: '-',
              name: "all"
            }
          },

          {
            modifier: {
              name: 'redirect',
              value: {macro_string: [{literal: '_spf.example.com'}]}
            }
          }
        ]
      end
    end

    describe "term" do
      subject { super().term }

      it "should parse a directive" do
        expect(subject.parse("-all")).to be == {
          directive: {
            qualifier: '-',
            name: "all"
          }
        }
      end

      it "should also parse a modifier" do
        expect(subject.parse('redirect=_spf.example.com')).to be == {
          modifier: {
            name: 'redirect',
            value: {macro_string: [{literal: '_spf.example.com'}]}
          }
        }
      end
    end

    describe "directive" do
      subject { super().directive }

      it "should parse a mechanism" do
        expect(subject.parse("all")).to be == {directive: {name: "all"}}
      end

      it "should parse a mechanism with a qualifier" do
        expect(subject.parse("-all")).to be == {
          directive: {
            qualifier: '-',
            name: "all"
          }
        }
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

    describe "mechanism" do
      subject { super().mechanism }

      it "should parse a mechanism" do
        expect(subject.parse('all')).to be == {name: 'all'}
      end
    end

    describe "all" do
      subject { super().all }

      it "should parse \"all\"" do
        expect(subject.parse('all')).to be == {name: 'all'}
      end
    end

    describe "include" do
      subject { super().include }

      let(:domain) { 'example.com' }

      it "should parse \"include:domain\"" do
        expect(subject.parse("include:#{domain}")).to be == {
          name: 'include',
          value: {macro_string: [{literal: domain}]}
        }
      end
    end

    describe "a" do
      subject { super().a }

      let(:domain) { 'example.com' }

      it "should parse \"a:domain\"" do
        expect(subject.parse("a:#{domain}")).to be == {
          name: 'a',
          value: {
            macro_string: [{literal: domain}],
          }
        }
      end

      let(:cidr_length) { '30' }

      it "should parse \"a:domain/cidr-length\"" do
        expect(subject.parse("a:#{domain}/#{cidr_length}")).to be == {
          name: 'a',
          value: {
            macro_string: [{literal: "#{domain}/#{cidr_length}"}]
          }
        }
      end

      it "should parse \"a:/cidr-length\"" do
        expect(subject.parse("a:/#{cidr_length}")).to be == {
          name: 'a',
          value: {
            macro_string: [{literal: "/#{cidr_length}"}]
          }
        }
      end
    end

    describe "mx" do
      subject { super().mx }

      let(:domain) { 'example.com' }

      it "should parse \"mx:domain\"" do
        expect(subject.parse("mx:#{domain}")).to be == {
          name: 'mx',
          value: {
            macro_string: [{literal: domain}]
          }
        }
      end

      let(:cidr_length) { '30' }

      it "should parse \"mx:domain/cidr-length\"" do
        expect(subject.parse("mx:#{domain}/#{cidr_length}")).to be == {
          name: 'mx',
          value: {
            macro_string: [{literal: "#{domain}/#{cidr_length}"}]
          }
        }
      end

      it "should parse \"mx:/cidr-length\"" do
        expect(subject.parse("mx:/#{cidr_length}")).to be == {
          name: 'mx',
          value: {
            macro_string: [{literal: "/#{cidr_length}"}]
          }
        }
      end
    end

    describe "ip4" do
      subject { super().ip4 }

      let(:ip) { '1.2.3.4' }

      it "should parse \"ip4:ip\"" do
        expect(subject.parse("ip4:#{ip}")).to be == {
          name: 'ip4',
          value: {ip: ip}
        }
      end

      let(:cidr_length) { '24' }

      it "should parse \"ip4:ip/cidr-length\"" do
        expect(subject.parse("ip4:#{ip}/#{cidr_length}")).to be == {
          name: 'ip4',
          value: {ip: ip, cidr_length: cidr_length}
        }
      end
    end

    describe "ip6" do
      subject { super().ip6 }

      let(:ip) { '2001:0db8:85a3:0000:0000:8a2e:0370:7334' }

      it "should parse \"ip6:ip\"" do
        expect(subject.parse("ip6:#{ip}")).to be == {
          name: 'ip6',
          value: {ip: ip}
        }
      end

      let(:cidr_length) { '32' }

      it "should parse \"ip6:ip/cidr-length\"" do
        expect(subject.parse("ip6:#{ip}/#{cidr_length}")).to be == {
          name: 'ip6',
          value: {ip: ip, cidr_length: cidr_length}
        }
      end
    end

    describe "ipv4_cidr_length" do
      subject { super().ipv4_cidr_length }

      it "should not match \"/\"" do
        expect { subject.parse("/") }.to raise_error(Parslet::ParseFailed)
      end

      it "should match \"/1\"" do
        expect(subject.parse("/1")).to be == {cidr_length: '1'}
      end

      it "should match \"/123\"" do
        expect(subject.parse("/123")).to be == {cidr_length: '123'}
      end
    end

    describe "ipv6_cidr_length" do
      subject { super().ipv6_cidr_length }

      it "should not match \"/\"" do
        expect { subject.parse("/") }.to raise_error(Parslet::ParseFailed)
      end

      it "should match \"/1\"" do
        expect(subject.parse("/1")).to be == {cidr_length: '1'}
      end

      it "should match \"/123\"" do
        expect(subject.parse("/123")).to be == {cidr_length: '123'}
      end
    end

    describe "exists" do
      subject { super().exists }

      it "should parse \"exists:domain\"" do
        expect(subject.parse('exists:%{ir}.sbl.spamhaus.example.org')).to be == {
          name: 'exists',
          value: {macro_string: [
            {macro: {letter: 'i', reverse: 'r'}},
            {literal: '.sbl.spamhaus.example.org'}
          ]}
        }
      end
    end

    describe "modifier" do
      subject { super().modifier }

      it "should parse a modifier" do
        expect(subject.parse('redirect=_spf.example.com')).to be == {
          modifier: {
            name: 'redirect',
            value: {macro_string: [{literal: '_spf.example.com'}]}
          }
        }
      end
    end

    describe "redirect" do
      subject { super().redirect }

      it "should parse \"redirect=domain\"" do
        expect(subject.parse('redirect=_spf.example.com')).to be == {
          name: 'redirect',
          value: {macro_string: [{literal: '_spf.example.com'}]}
        }
      end
    end

    describe "explanation" do
      subject { super().explanation }

      it "should parse \"exp=domain\"" do
        expect(subject.parse("exp=explain._spf.%{d}")).to be == {
          name: 'exp',
          value: {macro_string: [
            {literal: 'explain._spf.'},
            {macro: {letter: 'd'}}
          ]}
        }
      end
    end

    describe "unknown_modifier" do
      subject { super().unknown_modifier }

      it "should parse \"name=\"" do
        expect(subject.parse("foo=")).to be == {name: 'foo', value: nil}
      end

      it "should parse \"name=value\"" do
        expect(subject.parse("foo=bar")).to be == {
          name: 'foo',
          value: {macro_string: [{literal: 'bar'}]}
        }
      end
    end

    describe "domain_spec" do
      subject { super().domain_spec }

      it "should not parse \"\"" do
        expect { subject.parse('') }.to raise_error(Parslet::ParseFailed)
      end

      it "should parse macro_literals" do
        expect(subject.parse('AAA')).to be == {macro_string: [{literal: 'AAA'}]}
      end

      it "should parse macro_expands" do
        expect(subject.parse('%{s}%{d}')).to be == {macro_string: [
          {macro: {letter: 's'}},
          {macro: {letter: 'd'}}
        ]}
      end

      it "should parse a mixture of macro_literals and macro_expands" do
        expect(subject.parse('foo.%{s}.bar.%{d}')).to be == {macro_string: [
          {literal: 'foo.'},
          {macro: {letter: 's'}},
          {literal: '.bar.'},
          {macro: {letter: 'd'}}
        ]}
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

    describe "macro_string" do
      subject { super().macro_string }

      it "should not parse ''" do
        expect { subject.parse('') }.to raise_error(Parslet::ParseFailed)
      end

      it "should parse macro_literals" do
        expect(subject.parse('AAA')).to be == {macro_string: [{literal: 'AAA'}]}
      end

      it "should parse macro_expands" do
        expect(subject.parse('%{s}%{d}')).to be == {macro_string: [
          {macro: {letter: 's'}},
          {macro: {letter: 'd'}}
        ]}
      end

      it "should parse a mixture of macro_literals and macro_expands" do
        expect(subject.parse('foo.%{s}.bar.%{d}')).to be == {macro_string: [
          {literal: 'foo.'},
          {macro: {letter: 's'}},
          {literal: '.bar.'},
          {macro: {letter: 'd'}}
        ]}
      end
    end

    describe "macro_string?" do
      subject { super().macro_string? }

      it "should parse ''" do
        expect(subject.parse('')).to be == ''
      end
    end

    describe "macro_expand" do
      subject { super().macro_expand }

      %w[%% %_ %-].each do |str|
        it "should parse #{str.inspect}" do
          expect(subject.parse(str)).to be == {macro: str}
        end
      end

      it "should parse \"%{s}\"" do
        expect(subject.parse("%{s}")).to be == {
          macro: {letter: 's'}
        }
      end

      it "should parse \"%{d4}\"" do
        expect(subject.parse("%{d4}")).to be == {
          macro: {
            letter: 'd', 
            digits: '4'
          }
        }
      end

      it "should parse \"%{dr}\"" do
        expect(subject.parse("%{dr}")).to be == {
          macro: {
            letter: 'd', 
            reverse: 'r'
          }
        }
      end

      it "should parse \"%{d2r}\"" do
        expect(subject.parse("%{d2r}")).to be == {
          macro: {
            letter: 'd', 
            digits: '2',
            reverse: 'r'
          }
        }
      end

      it "should parse \"%{l-}\"" do
        expect(subject.parse("%{l-}")).to be == {
          macro: {
            letter: 'l', 
            delimiters: [{char: '-'}]
          }
        }
      end

      it "should parse \"%{lr-}\"" do
        expect(subject.parse("%{lr-}")).to be == {
          macro: {
            letter: 'l', 
            reverse: 'r',
            delimiters: [{char: '-'}]
          }
        }
      end

      it "should parse \"%{l1r-}\"" do
        expect(subject.parse("%{l1r-}")).to be == {
          macro: {
            letter: 'l', 
            digits: '1',
            reverse: 'r',
            delimiters: [{char: '-'}]
          }
        }
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
          expect(subject.parse(char)).to be == char
        end
      end
    end

    describe "transformers" do
      subject { super().transformers }

      it "should parse \"\"" do
        expect(subject.parse("")).to be == ""
      end

      it "should parse a single digit" do
        expect(subject.parse("1")).to be == {digits: "1"}
      end

      it "should parse a multiple digits" do
        expect(subject.parse("123")).to be == {digits: "123"}
      end

      it "should parse 'r'" do
        expect(subject.parse("r")).to be == {reverse: "r"}
      end

      it "should parse a single digit then 'r'" do
        expect(subject.parse("1r")).to be == {digits: "1", reverse: "r"}
      end

      it "should parse a multiple digits then 'r'" do
        expect(subject.parse("123r")).to be == {digits: "123", reverse: "r"}
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

  describe Parser::Transform do
    describe "literal" do
      let(:string) { '_spf.google.com' }

      subject { super().apply(literal: string) }

      it "should convert to a String" do
        expect(subject).to be == string
      end
    end

    describe "macro_string" do
      context "containing a single literal string" do
        let(:string) { '_spf.google.com' }

        subject { super().apply(macro_string: [{literal: string}]) }

        it "should convert to a String" do
          expect(subject).to be == string
        end
      end

      context "containing a mix of macro_expands and literals" do
        let(:string1) { 'foo'  }
        let(:macro)   { 's'    }
        let(:string2) { 'bar'  }

        subject do
          super().apply(
            macro_string: [
              {literal: string1},
              {macro: {letter: macro}},
              {literal: string2}
            ]
          )
        end

        it "should convert to a String" do
          expect(subject).to           be_kind_of(MacroString)
          expect(subject[0]).to        be == string1
          expect(subject[1]).to        be_kind_of(Macro)
          expect(subject[1].letter).to be == macro.to_sym
          expect(subject[2]).to        be == string2
        end
      end
    end

    describe "directive" do
      subject do
        super().apply(directive: {qualifier: '~', name: 'all'})
      end

      it "should map directives to Mechanism objects" do
        expect(subject).to be_kind_of(Mechanism)
      end

      it "should set the name" do
        expect(subject.name).to be == :all
      end

      it "should map qualifier to a Symbol" do
        expect(subject.qualifier).to be :soft_fail
      end
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
end
