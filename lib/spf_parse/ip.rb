module SPFParse
  class IP

    attr_reader :address

    attr_reader :cidr_length

    def initialize(address,cidr_length=nil)
      @address     = address
      @cidr_length = cidr_length
    end

    def to_s
      if @cidr_length then "#{@address}/#{@cidr_length}"
      else                 @address
      end
    end

  end
end
