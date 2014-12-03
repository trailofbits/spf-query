module SPFParse
  class IP

    attr_reader :address

    attr_reader :cidr_length

    def initialize(address,cidr_length=nil)
      @address     = address
      @cidr_length = cidr_length
    end

  end
end
