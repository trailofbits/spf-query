require 'parslet'

module SPFParse
  class Parser < Parslet::Parser

    root :record
    rule(:record)    { version >> sp.repeat(1) >> terms >> sp.repeat(0) }
    rule(:version)   { str('v=spf1') }
    rule(:terms)     { term >> (sp.repeat(1) >> term).repeat(0) }
    rule(:term)      { directive | modifier }
    rule(:directive) { qualifier.maybe >> mechanism }

    rule(:qualifier) do
      str('+') |
      str('-') |
      str('~') |
      str('?')
    end

    rule(:mechanism) do
      str('all')    |
      include       |
      a |
      mx |
      ptr |
      ipv4 |
      ipv6 |
      exists
    end

    #
    # Section 5.2:
    #
    #   include          = "include"  ":" domain-spec
    #
    rule(:include) { str('include') >> str(':') >> domain_spec }

    #
    # Section 5.3:
    #
    #   A                = "a"      [ ":" domain-spec ] [ dual-cidr-length ]
    #
    rule(:a) do
      str('a') >> (str(':') >> domain_spec).maybe >> dual_cidr_length.maybe
    end

    #
    # Section 5.4:
    #
    #   MX               = "mx"     [ ":" domain-spec ] [ dual-cidr-length ]
    #
    rule(:mx) do
      str('mx') >> (str(':') >> domain_spec).maybe >> dual_cidr_length.maybe
    end

    #
    # Section 5.5:
    #
    #   PTR              = "ptr"    [ ":" domain-spec ]
    #
    rule(:ptr) do
      str('ptr') >> (str(':') >> domain_spec).maybe
    end

    #
    # Section 5.6:
    #
    #   IP4              = "ip4"      ":" ip4-network   [ ip4-cidr-length ]
    #
    rule(:ipv4) do
      str('ipv4') >> str(':') >> ipv4_address >> ipv4_cidr_length.maybe
    end

    #
    # Section 5.6:
    #
    #   IP6              = "ip6"      ":" ip6-network   [ ip6-cidr-length ]
    #
    rule(:ipv6) do
      str('ipv6') >> str(':') >> ipv6_address >> ipv6_cidr_length.maybe
    end

    rule(:ipv4_cidr_length) { str('/') >> digit.repeat(1) }
    rule(:ipv6_cidr_length) { str('/') >> digit.repeat(1) }
    rule(:dual_cidr_length) do
      ipv4_cidr_length.maybe >> (str('/') >> ipv6_cidr_length).maybe
    end

    #
    # Section 5.7:
    #
    #   exists           = "exists"   ":" domain-spec
    #   
    rule(:exists) do
      str('exists') >> str(':') >> domain_spec
    end

    rule(:modifier) { redirect | explanation | unknown_modifier }
    rule(:redirect) { str('redirect') >> str('=') >> domain_spec }
    rule(:explanation) { str('exp') >> str('=') >> domain_spec }
    rule(:unknown_modifier) { name >> equals >> macro_string }

    rule(:domain_spec) { macro_string >> domain_end }
    rule(:domain_end) do
      (str('.') >> toplabel >> str('.').maybe) |
      macro_expand
    end
    rule(:toplabel) do
      (alphanum.repeat(0) >> alpha >> alphanum.repeat(0)) |
      (alphanum.repeat(1) >> str('-') >> (alphanum | str('-')).repeat(0) >> alphanum)
    end

    rule(:name) { alpha >> (alpha | digit | match['-_\.'] ).repeat(0) }

    #
    # Macro rules
    #
    # See RFC 4408, Section 8.1.
    #
    rule(:explain_string) { (macro_string | sp).repeat(0) }
    rule(:macro_string)   { (macro_expand | macro_literal).repeat(0) }
    rule(:macro_expand) do
      (str('%{') >> macro_letter >> transformers >> delimiter.repeat(0) >> str('}')) |
      str('%%') | str('%_') | str('%-')
    end
    rule(:macro_literal) { match['\x21-\x24'] | match['\x26-\x7e'] }
    rule(:macro_letter) { match['slodiphcrt'] }
    rule(:transformers) { digit.repeat(0) >> str('r').maybe }
    rule(:delimiter) { match['-\.+,/_='] }

    # 
    # IP rules:
    #
    # See https://github.com/kschiess/parslet/blob/master/example/ip_address.rb
    #
    rule(:ipv4_address) do
      dec_octet >> str('.') >>
      dec_octet >> str('.') >>
      dec_octet >> str('.') >>
      dec_octet
    end

    rule(:dec_octet) do
      str('25') >> match("[0-5]") |
      str('2') >> match("[0-4]") >> digit |
      str('1') >> digit >> digit |
      match('[1-9]') >> digit |
      digit
    end

    rule(:ipv6_address) do
      (
        (
          h16r(6) |
          dcolon >> h16r(5) |
          h16.maybe >> dcolon >> h16r(4) |
          (h16 >> h16l(1)).maybe >> dcolon >> h16r(3) |
          (h16 >> h16l(2)).maybe >> dcolon >> h16r(2) |
          (h16 >> h16l(3)).maybe >> dcolon >> h16r(1) |
          (h16 >> h16l(4)).maybe >> dcolon
        ) >> ls32 |

        ((h16 >> h16l(5)).maybe >> dcolon >> h16) |
        ((h16 >> h16l(6)).maybe >> dcolon)
      )
    end

    rule(:h16) { hexdigit.repeat(1,4) }
    rule(:ls32) { (h16 >> colon >> h16) | ipv4_address }

    rule(:sp) { str(' ') }
    rule(:colon) { str(':') }
    rule(:dcolon) { str('::') }
    rule(:slash) { str('/') }
    rule(:equals) { str('=') }
    rule(:alpha) { match['a-zA-Z'] }
    rule(:alphanum) { match['a-zA-Z0-9'] }
    rule(:digit) { match['0-9'] }
    rule(:hexdigit) { match['0-9a-fA-F'] }

    def h16r(times)
      (h16 >> colon).repeat(times, times)
    end

    def h16l(times)
      (colon >> h16).repeat(0,times)
    end

  end
end
