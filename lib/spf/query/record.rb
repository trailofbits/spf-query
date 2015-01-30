require 'spf/query/parser'
require 'spf/query/query'

require 'resolv'

module SPF
  module Query
    class Record

      include Enumerable

      # The SPF version of the record.
      #
      # @return [:spf1]
      attr_reader :version
      alias v version

      # The SPF rules.
      #
      # @return [Array<Mechanism, Modifier>]
      attr_reader :rules

      # All mechanisms within the record.
      #
      # @return [Array<Mechanism>]
      attr_reader :mechanisms

      # All modifiers within the record.
      #
      # @return [Array<Modifier>]
      attr_reader :modifiers

      # The right-most `all:` mechanism.
      #
      # @return [Mechanism, nil]
      attr_reader :all

      # Selects all `include:` mechanisms.
      #
      # @return [Array<Mechanism>]
      attr_reader :include

      # Selects all `a:` mechanisms.
      #
      # @return [Array<Mechanism>]
      attr_reader :a

      # Selects all `mx:` mechanisms.
      #
      # @return [Array<Mechanism>]
      attr_reader :mx

      # Selects all `ptr:` mechanisms.
      #
      # @return [Array<Mechanism>]
      attr_reader :ptr

      # Selects all `ip4:` mechanisms.
      #
      # @return [Array<Mechanism>]
      attr_reader :ip4

      # Selects all `ip6:` mechanisms.
      #
      # @return [Array<Mechanism>]
      attr_reader :ip6

      # Selects all `exists:` mechanisms.
      #
      # @return [Array<Mechanism>]
      attr_reader :exists

      # The `redirect=` modifier.
      #
      # @return [Modifier, nil]
      attr_reader :redirect

      # The `exp=` modifier.
      #
      # @return [Modifier, nil]
      attr_reader :exp

      #
      # Initializes the SPF record.
      #
      # @param [:spf1] version
      #   The SPF version.
      #
      # @param [Array<Mechanism, Modifier>] rules
      #   SPF rules.
      #
      def initialize(version,rules=[])
        @version = version
        @rules   = rules

        @mechanisms = @rules.select { |term| term.kind_of?(Mechanism) }
        @modifiers  = @rules.select { |term| term.kind_of?(Modifier)  }

        # prefer the last `all:` mechanism
        @all = @mechanisms.reverse_each.find do |mechanism|
          mechanism.name == :all
        end

        mechanisms_by_name = lambda { |name|
          @mechanisms.select { |mechanism| mechanism.name == name }
        }

        @include = mechanisms_by_name[:include]
        @a       = mechanisms_by_name[:a]
        @mx      = mechanisms_by_name[:mx]
        @ptr     = mechanisms_by_name[:ptr]
        @ip4     = mechanisms_by_name[:ip4]
        @ip6     = mechanisms_by_name[:ip6]
        @exists  = mechanisms_by_name[:exists]

        modifier_by_name = lambda { |name|
          @modifiers.find { |modifier| modifier.name == name }
        }

        @redirect = modifier_by_name[:redirect]
        @exp      = modifier_by_name[:exp]
      end

      #
      # Parses an SPF record.
      #
      # @see Parser.parse
      #
      # @api public
      #
      def self.parse(spf)
        Parser.parse(spf)
      end

      #
      # Queries the domain for it's SPF record.
      #
      # @param [String] domain
      #   The domain to query.
      #
      # @param [Resolv::DNS] resolver
      #   The optional resolver to use.
      #
      # @return [Record, nil]
      #   The parsed SPF record. If no SPF record could be found,
      #   `nil` will be returned.
      #
      # @api public
      #
      def self.query(domain,resolver=Resolv::DNS.new)
        if (spf = Query.query(domain,resolver))
          parse(spf)
        end
      end

      #
      # Enumerates over the rules.
      #
      # @yield [rule]
      #   The given block will be passed each rule.
      #
      # @yieldparam [Mechanism, Modifier] rule
      #   A directive or modifier rule.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      def each(&block)
        @rules.each(&block)
      end

      #
      # Converts the record back to a String.
      #
      # @return [String]
      #
      def to_s
        "v=#{@version} #{@rules.join(' ')}"
      end

      #
      # Inspects the record.
      #
      # @return [String]
      #
      def inspect
        "#<#{self.class}: #{self}>"
      end

    end
  end
end
