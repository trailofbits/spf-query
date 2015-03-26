module SPF
  module Query
    class Mechanism

      QUALIFIERS = {
        '+' => :pass,
        '-' => :fail,
        '~' => :soft_fail,
        '?' => :neuatral
      }

      attr_reader :name
      
      attr_reader :value

      attr_reader :qualifier
      
      def initialize(name,options={})
        @name = name

        @value     = options[:value]
        @qualifier = options.fetch(:qualifier,:pass)
      end

      def pass?
        @qualifier == :pass
      end

      def fail?
        @qualifier == :fail
      end

      def soft_fail?
        @qualifier == :soft_fail
      end

      def neutral?
        @qualifier == :neutral
      end

      def to_s
        str = "#{QUALIFIERS.invert[@qualifier]}#{@name}"
        str << ":#{@value}" if value

        return str
      end

    end
  end
end
