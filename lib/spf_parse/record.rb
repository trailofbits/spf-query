require 'spf_parse/parser'

require 'resolv'

module SPFParse
  class Record

    include Enumerable

    # The SPF version of the record.
    #
    # @return [:spf1]
    attr_reader :version

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
      @rules = rules
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

  end
end
