module SPF
  module Query
    #
    # Represents an SPF string macro.
    #
    class Macro

      # The macro letter.
      #
      # @return [Symbol]
      attr_reader :letter

      # Number of times the macro must be repeated.
      #
      # @return [Integer, nil]
      attr_reader :digits

      # Macro delimiter character.
      #
      # @return [Array<String>]
      attr_reader :delimiters

      #
      # Initializes the macro.
      #
      # @param [Symbol] letter
      #   The macro letter.
      #
      # @param [Hash] options
      #   Additional options.
      #
      # @option options [Integer] :digits
      #   Number of times to repeat the macro.
      #
      # @option options [Boolean] :reverse
      #   Whether to reverse the value.
      #
      # @option options [Array<String>, String] :delimiters
      #   Delimiter characters.
      #
      def initialize(letter,options={})
        @letter     = letter
        @digits     = options[:digits]
        @reverse    = options[:reverse]
        @delimiters = Array(options[:delimiters])
      end

      #
      # Specifies if the macro should be reversed.
      #
      # @return [Boolean]
      #
      def reverse?
        @reverse
      end

      #
      # Converts the macro a String.
      #
      # @return [String]
      #
      def to_s
        "%{#{@letter}#{@digits}#{@delimiters.join}}"
      end

    end
  end
end
