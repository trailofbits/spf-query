require "spf_parse/version"
require 'resolv'

module SpfParse
  def self.check_host(host, resolver=Resolv::DNS.new)
    begin
      host_without_tld = host[0...host.rindex('.')]
    rescue
      raise StandardError.new('host'), "invalid hostname"
    end
    paths = [host, "_spf.#{host}"]
    spf = nil
    paths.each do |path|
      begin
        spf = resolver.getresource(path, Resolv::DNS::Resource::IN::TXT).strings.join
        if spf.index('v=spf1')
          spf = {:record =>spf, :record_path=>path}
          break
        end
      rescue Resolv::ResolvError
      end
    end
    spf
  end  
end
