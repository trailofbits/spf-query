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
      
      def initialize(name,options={})
        @name = name

        @value     = options[:value]
        @qualifier = options.fetch(:qualifier,:pass)
      end

      def to_s
        str = "#{QUALIFIERS.invert[@qualifier]}#{@name}"
        str << ":#{@value}" if value

        return str
      end

    end
  end
end
