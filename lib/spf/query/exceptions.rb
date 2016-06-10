require 'parslet'

module SPF
  module Query
    #
    # Exception for when the SPF record cannot be parsed.
    #
    class InvalidRecord < Parslet::ParseFailed
    end

    #
    # Exception for when [SenderID] is found in-place of SPF.
    #
    # [SenderID]: http://www.openspf.org/SPF_vs_Sender_ID
    #
    class SenderIDFound < InvalidRecord
    end
  end
end
