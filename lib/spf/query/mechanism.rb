module SPF
  module Query
    #
    # Represents an SPF mechanism.
    #
    class Mechanism

      # Maps qualifier symbols to Symbols
      QUALIFIERS = {
        '+' => :pass,
        '-' => :fail,
        '~' => :soft_fail,
        '?' => :neutral
      }

      # The mechanism name.
      #
      # @return [Symbol]
      attr_reader :name

      # The mechanism value.
      #
      # @return [String, MacroString, IP, nil]
      attr_reader :value

      #
      # Initializes the mechanism.
      #
      # @param [Symbol] name
      #
      # @param [Hash] options
      #   Additional options.
      #
      # @option options [String, MacroString, IP] :value
      #   Optional value.
      #
      # @option options [Symbol] :qualifier
      #   Mechanism qualifier.
      #
      def initialize(name,options={})
        @name = name

        @value     = options[:value]

        if @value.is_a?(String)
          @value = options[:value].length.zero? ? nil : options[:value]
        end

        @qualifier = options[:qualifier]
      end

      #
      # The mechanism qualifier.
      #
      # @return [:pass, :fail, :soft_fail, :neutral]
      #   The qualifier. Defaults to `:pass`.
      #
      def qualifier
        @qualifier || :pass
      end

      #
      # Determines whether the qualifier is a "pass".
      #
      # @return [Boolean]
      #
      def pass?
        @qualifier == :pass || @qualifier.nil?
      end

      #
      # Determines if the qualifier is a "fail".
      #
      # @return [Boolean]
      #
      def fail?
        @qualifier == :fail
      end

      #
      # Determines whether the qualifier is a "soft_fail".
      #
      # @return [Boolean]
      #
      def soft_fail?
        @qualifier == :soft_fail
      end

      #
      # Determines whether the qualifier is a "neutral".
      #
      # @return [Boolean]
      #
      def neutral?
        @qualifier == :neutral
      end

      #
      # Converts the mechanism to a String.
      #
      # @return [String]
      #
      def to_s
        str = "#{QUALIFIERS.invert[@qualifier]}#{@name}"
        str << ":#{@value}" if value

        return str
      end

    end
  end
end
