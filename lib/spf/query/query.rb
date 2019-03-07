require 'resolv'
require 'resolv/dns/resource/in/spf'

module SPF
  module Query
    #
    # Queries the domain for it's SPF record.
    #
    # @param [String] domain
    #   The domain to query.
    #
    # @param [Resolv::DNS] resolver
    #   The optional resolver to use.
    #
    # @return [String, nil]
    #   The SPF record or `nil` if there is none.
    #
    # @api semipublic
    #
    def self.query(domain,resolver=Resolv::DNS.new)
      begin
        records = resolver.getresources(domain, Resolv::DNS::Resource::IN::TXT)

        records.each do |record|
          txt = record.strings.join

          if txt.include?('v=spf1')
            return txt
          end
        end
      rescue Resolv::ResolvError
      end

      # check for an SPF record on the domain
      begin
        record = resolver.getresource(domain, Resolv::DNS::Resource::IN::SPF)

        return record.strings.join(' ')
      rescue Resolv::ResolvError
      end

      return nil
    end
  end
end
