require 'parslet'

module SPFParse
  class Parser < Parslet::Parser

    root :record
    rule(:record)    { version >> sp.repeat(1) >> terms >> sp.repeat(0) }
    rule(:version)   { str('v=') >> str('spf1').as(:version) }
    rule(:terms)     { term >> (sp.repeat(1) >> term).repeat(0) }
    rule(:term)      { directive | modifier }
    rule(:directive) { qualifier.maybe >> mechanism }
    rule(:qualifier) { match['+\-~?'].as(:qualifier) }

    rule(:mechanism) do
      (
        all     |
        include |
        a       |
        mx      |
        ptr     |
        ip4     |
        ip6     |
        exists
      ).as(:mechanism)
    end

    rule(:all) { str('all').as(:name) }

    #
    # Section 5.2:
    #
    #   include          = "include"  ":" domain-spec
    #
    rule(:include) do
      str('include').as(:name) >> str(':') >> domain_spec.as(:value)
    end

    #
    # Section 5.3:
    #
    #   A                = "a"      [ ":" domain-spec ] [ dual-cidr-length ]
    #
    rule(:a) do
      str('a').as(:name) >>
      ((str(':') >> domain_spec).maybe >> dual_cidr_length.maybe).as(:value)
    end

    #
    # Section 5.4:
    #
    #   MX               = "mx"     [ ":" domain-spec ] [ dual-cidr-length ]
    #
    rule(:mx) do
      str('mx').as(:name) >>
      (
        (str(':') >> domain_spec).maybe >>
         dual_cidr_length.maybe
      ).as(:value)
    end

    #
    # Section 5.5:
    #
    #   PTR              = "ptr"    [ ":" domain-spec ]
    #
    rule(:ptr) do
      str('ptr').as(:name) >> (str(':') >> domain_spec.as(:value)).maybe
    end

    #
    # Section 5.6:
    #
    #   IP4              = "ip4"      ":" ip4-network   [ ip4-cidr-length ]
    #
    rule(:ip4) do
      str('ip4').as(:name) >> str(':') >> (ipv4_address >> ipv4_cidr_length.maybe).as(:ip).as(:value)
    end

    #
    # Section 5.6:
    #
    #   IP6              = "ip6"      ":" ip6-network   [ ip6-cidr-length ]
    #
    rule(:ip6) do
      str('ip6').as(:name) >> str(':') >> (ipv6_address >> ipv6_cidr_length.maybe).as(:ip).as(:value)
    end

    rule(:dual_cidr_length) do
      ipv4_cidr_length.maybe >> (str('/') >> ipv6_cidr_length).maybe
    end
    rule(:ipv4_cidr_length) { str('/') >> digit.repeat(1) }
    rule(:ipv6_cidr_length) { str('/') >> digit.repeat(1) }

    #
    # Section 5.7:
    #
    #   exists           = "exists"   ":" domain-spec
    #   
    rule(:exists) do
      str('exists').as(:name) >> str(':') >> domain_spec.as(:value)
    end

    rule(:modifier) do
      (redirect | explanation | unknown_modifier).as(:modifier)
    end
    rule(:redirect) do
      str('redirect').as(:name) >> str('=') >> domain_spec.as(:value)
    end
    rule(:explanation) do
      str('exp').as(:name) >> str('=') >> domain_spec.as(:value)
    end
    rule(:unknown_modifier) do
      name.as(:name) >> equals >> macro_string?.as(:value)
    end

    rule(:domain_spec) { macro_string.as(:domain) }
    rule(:name) { alpha >> (alpha | digit | match['-_\.'] ).repeat(0) }

    #
    # Macro rules
    #
    # See RFC 4408, Section 8.1.
    #
    rule(:macro_string) do
      (macro_expand | macro_literal.repeat(1).as(:literal)).repeat(1)
    end
    rule(:macro_string?) { macro_string.maybe }
    rule(:macro_expand) do
      (
        (
          str('%{') >>
          macro_letter.as(:letter) >>
          transformers.as(:transformers) >>
          delimiter.repeat(1).as(:delimiters).maybe >>
          str('}')
        ) | str('%%') | str('%_') | str('%-')
      ).as(:macro)
    end
    rule(:macro_literal) { match['\x21-\x24'] | match['\x26-\x7e'] }
    rule(:macro_letter) { match['slodiphcrt'] }
    rule(:transformers) do
      digit.repeat(1).as(:digits).maybe >> str('r').as(:reverse).maybe
    end
    rule(:delimiter) { match['-\.+,/_='].as(:char) }

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
