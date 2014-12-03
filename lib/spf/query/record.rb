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
      # @return [Array<Directive, Modifier>]
      attr_reader :rules

      #
      # Initializes the SPF record.
      #
      # @param [:spf1] version
      #   The SPF version.
      #
      # @param [Array<Directive, Modifier>] rules
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
            return parse(spf)
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
      # @yieldparam [Directive, Modifier] rule
      #   A directive or modifier rule.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator will be returned.
      #
      def each(&block)
        @rules.each(&block)
      end

    end
  end
end
