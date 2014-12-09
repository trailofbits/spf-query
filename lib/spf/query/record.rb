require 'spf/query/parser'

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
        [domain, "_spf.#{domain}"].each do |host|
          begin
            spf = resolver.getresource(host, Resolv::DNS::Resource::IN::TXT).strings.join

            if spf.include?('v=spf1')
              return parse(spf)
            end
          rescue Resolv::ResolvError
          end
        end

        return nil
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
      # Enumerates over only the mechanisms.
      #
      # @yield [mechanism]
      #   The given block will be passed each mechanism.
      #
      # @yieldparam [Mechanism] mechanism
      #   A mechanism within the record.
      #
      # @return [Enumerator]
      #   If no block was given, an Enumerator will be returned.
      #
      def each_mechanism
        return enum_for(__method__) unless block_given?

        each do |term|
          case term
          when Mechanism then yield term
          end
        end
      end

      #
      # @return [Enumerator]
      #
      # @see #each_mechanism
      #
      def mechanisms
        each_mechanism
      end

      #
      # Enumerates over only the modifiers.
      #
      # @yield [modifier]
      #   The given block will be passed each modifier.
      #
      # @yieldparam [Modifier] modifier
      #   A mechanism within the record.
      #
      # @return [Enumerator]
      #   If no block was given, an Enumerator will be returned.
      #
      def each_modifier
        return enum_for(__method__) unless block_given?

        each do |term|
          case term
          when Modifier then yield term
          end
        end
      end

      #
      # @return [Enumerator]
      #
      # @see #each_modifier
      #
      def modifiers
        each_modifier
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
