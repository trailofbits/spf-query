require 'parslet'

module SPF
  module Query
    class InvalidRecord < Parslet::ParseFailed
    end
  end
end
