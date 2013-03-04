# @author Alexei Matyushkin
module Yard
  # Monkey patches for shorthands.
  module MonkeyPatches

    class ::Array
      # alias … each
      def … ; block_given? ? each(&Proc.new) : each ; end
      # alias ≠ reject
      def ≠ ; block_given? ? reject(&Proc.new) : reject ; end
      # alias ≡ select
      def ≡ ; block_given? ? select(&Proc.new) : select ; end
    end
    class ::Hash
      # alias … each
      def … ; block_given? ? each(&Proc.new) : each ; end
    end
    
    # Sample for String
    # FIXME Possible wanna use [Faker](http://faker.rubyforge.org/) here
    refine String do
      def random(size: 32, symbols: [*('A'..'Z'), *('а'..'я'), *('0'..'9'), *[' ']*10])
        if !self.empty? 
          symbols = self.scan('.')
        elsif !(Array === symbols) && symbols.respond_to?(:to_a)
          symbols = symbols.to_a
        end
        raise ArgumentError.new("`:symbols` argument class must support `#sample` method (given #{symbols})") \
          unless symbols.respond_to? :sample
        self.tap { |v| size.times { v << symbols.sample } }.squeeze
      end
    end

    refine Fixnum do
      def random
        rand(self)
      end
    end

    refine Array do
      def random(size: 64)
        self.tap { |v| size.times { v << "".random << size.random } }
      end
    end
    
    refine Hash do
      def random(size: 64)
        self.tap { |v|
          size.times {
            v["".random(:symbols => [*('a'..'z')])] = ::Kernel::random(:samples => ["", 1000])
          }
        }
      end
    end
    
    module ::Kernel
      # Alias for lambda
      alias λ lambda
      # Alias for proc
      alias Λ proc
      # Random instance of random class
      # @param samples [Array] the instances of classes supporting `#random` method.
      #        Those will vbe used as initial parameters for calls to `random` on them.
      # @return random instance of one of the classes given as parameters
      def random(samples: ["", 1000, {}, []])
        samples.sample.random
      end
    end
    
  end
end