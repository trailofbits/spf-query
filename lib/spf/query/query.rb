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
      ["_spf.#{domain}", domain].each do |host|
        begin
          records = resolver.getresources(host, Resolv::DNS::Resource::IN::TXT)

          records.each do |record|
            txt = record.strings.join

            if txt.include?('v=spf1')
              return txt
            end
          end
        rescue Resolv::ResolvError
        end
      end

      return nil
    end
  end
end
