module SPF
  module Query
    #
    # Represents an IP address in an SPF record.
    #
    class IP

      # The address.
      #
      # @return [String]
      attr_reader :address

      # CIDR length.
      # 
      # @return [Integer, nil]
      attr_reader :cidr_length

      #
      # Initializes the IP.
      #
      # @param [String] address
      #   The IP address.
      #
      # @param [Integer, nil] cidr_length
      #   Optional CIDR length.
      #
      def initialize(address,cidr_length=nil)
        @address     = address
        @cidr_length = cidr_length
      end

      #
      # Converts the IP address to a String.
      #
      # @return [String]
      #
      def to_s
        if @cidr_length then "#{@address}/#{@cidr_length}"
        else                 "#{@address}"
        end
      end

    end
  end
end
