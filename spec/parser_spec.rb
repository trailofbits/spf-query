require 'spec_helper'
require 'spf_parse/parser'

describe Parser do
  describe "rules" do
    describe "record" do
      subject { super().record }

      it "should parse a version then multiple terms" do
        expect(subject.parse("v=spf1 -all redirect=_spf.example.com")).to be == [
          {version: 'spf1'},

          {
            qualifier: '-',
            mechanism: {name: "all"}
          },

          {
            modifier: {
              name: 'redirect',
              value: {domain: [{literal: '_spf.example.com'}]}
            }
          }
        ]
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
          qualifier: '-',
          mechanism: {name: "all"}
        }
      end

      it "should parse multiple terms separated by one or more spaces" do
        expect(subject.parse("-all  redirect=_spf.example.com")).to be == [
          {
            qualifier: '-',
            mechanism: {name: "all"}
          },

          {
            modifier: {
              name: 'redirect',
              value: {domain: [{literal: '_spf.example.com'}]}
            }
          }
        ]
      end
    end

    describe "term" do
      subject { super().term }

      it "should parse a directive" do
        expect(subject.parse("-all")).to be == {
          qualifier: '-',
          mechanism: {name: "all"}
        }
      end

      it "should also parse a modifier" do
        expect(subject.parse('redirect=_spf.example.com')).to be == {
          modifier: {
            name: 'redirect',
            value: {domain: [{literal: '_spf.example.com'}]}
          }
        }
      end
    end

    describe "directive" do
      subject { super().directive }

      it "should parse a mechanism" do
        expect(subject.parse("all")).to be == {
          mechanism: {name: "all"}
        }
      end

      it "should parse a mechanism with a qualifier" do
        expect(subject.parse("-all")).to be == {
          qualifier: '-',
          mechanism: {name: "all"}
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
        expect(subject.parse('all')).to be == {mechanism: {name: 'all'}}
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
          value: {domain: [{literal: domain}]}
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
            domain: [{literal: domain}],
          }
        }
      end

      let(:cidr_length) { '30' }

      it "should parse \"a:domain/cidr-length\"" do
        expect(subject.parse("a:#{domain}/#{cidr_length}")).to be == {
          name: 'a',
          value: {
            domain: [{literal: "#{domain}/#{cidr_length}"}]
          }
        }
      end

      it "should parse \"a:/cidr-length\"" do
        expect(subject.parse("a:/#{cidr_length}")).to be == {
          name: 'a',
          value: {
            domain: [{literal: "/#{cidr_length}"}]
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
            domain: [{literal: domain}]
          }
        }
      end

      let(:cidr_length) { '30' }

      it "should parse \"mx:domain/cidr-length\"" do
        expect(subject.parse("mx:#{domain}/#{cidr_length}")).to be == {
          name: 'mx',
          value: {
            domain: [{literal: "#{domain}/#{cidr_length}"}]
          }
        }
      end

      it "should parse \"mx:/cidr-length\"" do
        expect(subject.parse("mx:/#{cidr_length}")).to be == {
          name: 'mx',
          value: {
            domain: [{literal: "/#{cidr_length}"}]
          }
        }
      end
    end

    describe "ip4" do
      subject { super().ip4 }

      let(:ip) { '1.2.3.4' }

      it "should parse \"ip4:IPv4\"" do
        expect(subject.parse("ip4:#{ip}")).to be == {
          name: 'ip4',
          value: {ip: ip}
        }
      end
    end

    describe "ip6" do
      subject { super().ip6 }

      let(:ip) { '2001:0db8:85a3:0000:0000:8a2e:0370:7334' }

      it "should parse \"ip6:IPv6\"" do
        expect(subject.parse("ip6:#{ip}")).to be == {
          name: 'ip6',
          value: {ip: ip}
        }
      end
    end

    describe "ipv4_cidr_length" do
      subject { super().ipv4_cidr_length }

      it "should not match \"/\"" do
        expect { subject.parse("/") }.to raise_error(Parslet::ParseFailed)
      end

      it "should match \"/1\"" do
        expect(subject.parse("/1")).to be == "/1"
      end

      it "should match \"/123\"" do
        expect(subject.parse("/123")).to be == "/123"
      end
    end

    describe "ipv6_cidr_length" do
      subject { super().ipv6_cidr_length }

      it "should not match \"/\"" do
        expect { subject.parse("/") }.to raise_error(Parslet::ParseFailed)
      end

      it "should match \"/1\"" do
        expect(subject.parse("/1")).to be == "/1"
      end

      it "should match \"/123\"" do
        expect(subject.parse("/123")).to be == "/123"
      end
    end

    describe "exists" do
      subject { super().exists }

      it "should parse \"exists:domain\"" do
        expect(subject.parse('exists:%{ir}.sbl.spamhaus.example.org')).to be == {
          name: 'exists',
          value: {domain: [
            {macro: {letter: 'i', transformers: {reverse: 'r'}}},
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
            value: {domain: [{literal: '_spf.example.com'}]}
          }
        }
      end
    end

    describe "redirect" do
      subject { super().redirect }

      it "should parse \"redirect=domain\"" do
        expect(subject.parse('redirect=_spf.example.com')).to be == {
          name: 'redirect',
          value: {domain: [{literal: '_spf.example.com'}]}
        }
      end
    end

    describe "explanation" do
      subject { super().explanation }

      it "should parse \"exp=domain\"" do
        expect(subject.parse("exp=explain._spf.%{d}")).to be == {
          name: 'exp',
          value: {domain: [
            {literal: 'explain._spf.'},
            {macro: {letter: 'd', transformers: ''}}
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
          value: [{literal: 'bar'}]
        }
      end
    end

    describe "domain_spec" do
      subject { super().domain_spec }

      it "should not parse \"\"" do
        expect { subject.parse('') }.to raise_error(Parslet::ParseFailed)
      end

      it "should parse macro_literals" do
        expect(subject.parse('AAA')).to be == {domain: [{literal: 'AAA'}]}
      end

      it "should parse macro_expands" do
        expect(subject.parse('%{s}%{d}')).to be == {domain: [
          {macro: {letter: 's', transformers: ''}},
          {macro: {letter: 'd', transformers: ''}}
        ]}
      end

      it "should parse a mixture of macro_literals and macro_expands" do
        expect(subject.parse('foo.%{s}.bar.%{d}')).to be == {domain: [
          {literal: 'foo.'},
          {macro: {letter: 's', transformers: ''}},
          {literal: '.bar.'},
          {macro: {letter: 'd', transformers: ''}}
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
        expect(subject.parse('AAA')).to be == [{literal: 'AAA'}]
      end

      it "should parse macro_expands" do
        expect(subject.parse('%{s}%{d}')).to be == [
          {macro: {letter: 's', transformers: ''}},
          {macro: {letter: 'd', transformers: ''}}
        ]
      end

      it "should parse a mixture of macro_literals and macro_expands" do
        expect(subject.parse('foo.%{s}.bar.%{d}')).to be == [
          {literal: 'foo.'},
          {macro: {letter: 's', transformers: ''}},
          {literal: '.bar.'},
          {macro: {letter: 'd', transformers: ''}}
        ]
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
          macro: {
            letter: 's',
            transformers: ''
          }
        }
      end

      it "should parse \"%{d4}\"" do
        expect(subject.parse("%{d4}")).to be == {
          macro: {
            letter: 'd', 
            transformers: {digits: '4'}
          }
        }
      end

      it "should parse \"%{dr}\"" do
        expect(subject.parse("%{dr}")).to be == {
          macro: {
            letter: 'd', 
            transformers: {reverse: 'r'}
          }
        }
      end

      it "should parse \"%{d2r}\"" do
        expect(subject.parse("%{d2r}")).to be == {
          macro: {
            letter: 'd', 
            transformers: {digits: '2', reverse: 'r'}
          }
        }
      end

      it "should parse \"%{l-}\"" do
        expect(subject.parse("%{l-}")).to be == {
          macro: {
            letter: 'l', 
            transformers: '',
            delimiters: [{char: '-'}]
          }
        }
      end

      it "should parse \"%{lr-}\"" do
        expect(subject.parse("%{lr-}")).to be == {
          macro: {
            letter: 'l', 
            transformers: {reverse: 'r'},
            delimiters: [{char: '-'}]
          }
        }
      end

      it "should parse \"%{l1r-}\"" do
        expect(subject.parse("%{l1r-}")).to be == {
          macro: {
            letter: 'l', 
            transformers: {digits: '1', reverse: 'r'},
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
end