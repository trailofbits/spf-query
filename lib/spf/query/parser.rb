require 'spf/query/ip'
require 'spf/query/macro'
require 'spf/query/macro_string'
require 'spf/query/modifier'
require 'spf/query/mechanism'
require 'spf/query/record'

require 'parslet'

module SPF
  module Query
    #
    # SPF parser.
    #
    # @see https://tools.ietf.org/html/rfc7208#section-7.1
    #
    class Parser < Parslet::Parser

      root :record
      rule(:record)    { version >> sp.repeat(1) >> terms.as(:rules) >> sp.repeat(0) }
      rule(:version)   { str('v=') >> str('spf1').as(:version) }
      rule(:terms)     { term >> (sp.repeat(1) >> term).repeat(0) }
      rule(:term)      { directive | modifier }
      rule(:directive) { (qualifier.maybe >> mechanism).as(:directive) }
      rule(:qualifier) { match['+\-~?'].as(:qualifier) }

      rule(:mechanism) do
        all     |
        include |
        a       |
        mx      |
        ptr     |
        ip4     |
        ip6     |
        exists
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
        str('ip4').as(:name) >> str(':') >> (ipv4_address >> ipv4_cidr_length.maybe).as(:value)
      end

      #
      # Section 5.6:
      #
      #   IP6              = "ip6"      ":" ip6-network   [ ip6-cidr-length ]
      #
      rule(:ip6) do
        str('ip6').as(:name) >> str(':') >> (ipv6_address >> ipv6_cidr_length.maybe).as(:value)
      end

      rule(:dual_cidr_length) do
        ipv4_cidr_length.maybe >> (str('/') >> ipv6_cidr_length).maybe
      end
      rule(:ipv4_cidr_length) { str('/') >> digit.repeat(1).as(:cidr_length) }
      rule(:ipv6_cidr_length) { str('/') >> digit.repeat(1).as(:cidr_length) }

      #
      # Section 5.7:
      #
      #   exists           = "exists"   ":" domain-spec
      #   
      rule(:exists) do
        str('exists').as(:name) >> str(':') >> domain_spec.as(:value)
      end

      rule(:modifier) do
        (redirect | explanation).as(:modifier) |
          unknown_modifier.as(:unknown_modifier)
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

      rule(:domain_spec) { macro_string }
      rule(:name) { alpha >> (alpha | digit | match['-_\.'] ).repeat(0) }

      #
      # Macro rules
      #
      # See RFC 4408, Section 8.1.
      #
      rule(:macro_string) do
        (
          (macro_expand | macro_literal.repeat(1).as(:literal)).repeat(1)
        ).as(:macro_string)
      end
      rule(:macro_string?) { macro_string.maybe }
      rule(:macro_expand) do
        (
          (
            str('%{') >>
            macro_letter.as(:letter) >>
            transformers >>
            delimiter.repeat(1).as(:delimiters).maybe >>
            str('}')
          ) | str('%%') | str('%_') | str('%-')
        ).as(:macro)
      end
      rule(:macro_literal) { match['\x21-\x24'] | match['\x26-\x7e'] }
      rule(:macro_letter) { match['slodiphcrtv'] }
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
        (
          dec_octet >> str('.') >>
          dec_octet >> str('.') >>
          dec_octet >> str('.') >>
          dec_octet
        ).as(:ip)
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
        ).as(:ip)
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

      class Transform < Parslet::Transform

        rule(ip: simple(:address)) { IP.new(address) }
        rule(ip: simple(:address), cidr_length: simple(:cidr_length)) do
          IP.new(address.to_s,cidr_length.to_i)
        end

        rule(char: simple(:c)) { c.to_s }
        rule(literal: simple(:text)) { text.to_s }
        rule(macro: subtree(:options)) do
          letter = options.fetch(:letter).to_sym

          Macro.new(letter,options)
        end

        rule(macro_string: sequence(:elements)) do
          if elements.length == 1 && elements.first.kind_of?(String)
            elements.first
          else
            MacroString.new(elements)
          end
        end

        rule(modifier: {name: simple(:name)}) do
          Modifier.new(name.to_sym)
        end

        rule(modifier: {name: simple(:name), value: subtree(:value)}) do
          Modifier.new(name.to_sym,value)
        end

        rule(unknown_modifier: {name: simple(:name), value: simple(:value)}) do
          UnknownModifier.new(name.to_s,value.to_s)
        end

        rule(directive: subtree(:options)) do
          name      = options.delete(:name).to_sym
          value     = options[:value]
          qualifier = if options[:qualifier]
                        Mechanism::QUALIFIERS.fetch(options[:qualifier].to_s)
                      end

          Mechanism.new(name, value: value, qualifier: qualifier)
        end

        rule(version: simple(:version), rules: subtree(:rules)) do
          Record.new(version.to_sym, Array(rules))
        end

      end

      #
      # Parses the SPF record.
      #
      # @param [String] spf
      #   The raw SPF record.
      #
      # @return [Record]
      #   The parsed SPF record.
      #
      # @raise [Parslet::ParseError]
      #
      def self.parse(spf)
        Transform.new.apply(new.parse(spf))
      end

    end
  end
end
