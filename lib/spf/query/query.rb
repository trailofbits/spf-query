require 'resolv'

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
      [domain, "_spf.#{domain}"].each do |host|
        begin
          spf = resolver.getresource(host, Resolv::DNS::Resource::IN::TXT).strings.join

          if spf.include?('v=spf1')
            return spf
          end
        rescue Resolv::ResolvError
        end
      end

      return nil
    end
  end
end
