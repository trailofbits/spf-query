require 'parslet'

module SPF
  module Query
    class InvalidRecord < Parslet::ParseFailed
    end

    class SenderIDFound < InvalidRecord
    end
  end
end
