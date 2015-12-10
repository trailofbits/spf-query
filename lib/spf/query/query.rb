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
    # @param [Boolean]
    #   Skip SPF record (discontined at RFC 7208)
    #
    # @return [String, nil]
    #   The SPF record or `nil` if there is none.
    #
    # @api semipublic
    #
    def self.query(domain,resolver=Resolv::DNS.new, skip_spf_record_type=false)

      unless skip_spf_record_type
        # check for an SPF record on the domain
        spf_record = check_for_spf_record(domain, resolver)
        return spf_record unless spf_record.nil?
      end

      # check for SPF in the TXT records
      ["_spf.#{domain}", domain].each do |host|
        begin
          records = resolver.getresources(host, Resolv::DNS::Resource::IN::TXT)

          records.each do |record|
            txt = record.strings.join(' ')

            if txt.include?('v=spf1')
              return txt
            end
          end
        rescue Resolv::ResolvError
        end
      end

      return nil
    end

    #
    # Queries the domain for it's SPF type record.
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
    def self.check_for_spf_record(domain, resolver=Resolv::DNS.new)
      begin
        record = resolver.getresource(domain, Resolv::DNS::Resource::IN::SPF)

        return record.strings.join(' ')
      rescue Resolv::ResolvError
      end
    end
  end
end
