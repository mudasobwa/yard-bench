# encoding: utf-8

module YARD
  # Monkey patches (🐵) for shorthands.
  #
  # This module introduces new functionality
  # for creation of some standard classes “samples.” It is used to emulate
  # real data to be passed to automatic benchmarks in cases, when the methods
  # have parameters required.
  #
  # @example To produce new random +String+, +Hash+, +Array+, +Fixnum+, one simply calls:
  #   % pry
  #   > require './lib/dsl/monkeypatches'
  #   # ⇒ true
  #   > String.∀ size: 30
  #   # ⇒ "3XсO91Lпр490Rэщ Xза O нL с3VщB"
  #   > Fixnum.∀
  #   # ⇒ 301
  #   > Hash.∀ size: 3
  #   # ⇒ {
  #   #    "aenvxgmsuqhpxgsbhrcjvyvhlrbexa" => "ьюWB4IVачъитяCи жH3O 8илыP Dц Kх",
  #   #   "awohozdxdjzvombswswsfzsqfqfguxc" => 202,
  #   #     "befqyvqhmrncboilgdjwbqpyvfgtp" => "ифMцGSь фъ BубITмPэIHрTJлъ9OдJщ9"
  #   # }
  #   > Array.∀ size: 3
  #   # ⇒ [
  #   #   [0] " эвъуL P 5июоCXъXе AB0 й1DьUфв",
  #   #   [1] 800,
  #   #   [2] 851
  #   # ]
  # @author Alexei Matyushkin <am@mudasobwa.ru>
  module MonkeyPatches

    class ::Array
      # @source def … ; block_given? ? each(&Proc.new) : each ; end
      alias … each
      # def ≠ ; block_given? ? reject(&Proc.new) : reject ; end
      alias ≠ reject
      # def ≡ ; block_given? ? select(&Proc.new) : select ; end
      alias ≡ select
    end
    class ::Hash
      # def … ; block_given? ? each(&Proc.new) : each ; end
      alias … each
    end

    # Enchancement of +String+ class to generate random sample based on the pattern given.
    class ::String
      # Generates random sample of +String+.
      # @example To create the string of length 12, consisting of lowercased latin letters:
      #   s1 = ('a'..'z').to_chars.∀ 12   # ⇒ fughtksnewqp
      #   s2 = "".∀(12, ('a'..'z'))       # ⇒ jiuuoiqwbjty
      # @see Range#to_chars
      # @todo Possible wanna use {http://faker.rubyforge.org Faker} here
      # @param size [Fixnum] the size of the sample to generate.
      # @param symbols [Array<Char>] the list of characters used to generate the sample.
      # @return [String] the string of the given length, consisting of random characters from the given set.
      def ∀(size: 32, symbols: [*('A'..'Z'), *('а'..'я'), *('0'..'9'), *[' ']*10])
        syms = case
               when !self.empty? then self.scan('.')
               when !(Array === symbols) && symbols.respond_to?(:to_a) then symbols.to_a
               else symbols
               end
        raise ArgumentError.new("`:symbols` argument class must support `#sample` method (given #{symbols})") \
          unless syms.respond_to? :sample
        "".tap { |v| size.times { v << syms.sample } }.squeeze
      end
      alias any ∀
    end

    # Enchancement of +Fixnum+ class to generate random number in the interval [0, Fixnum).
    class ::Fixnum
      # Generates random +Fixnum+ in the given interval.
      # @example To create the positive number not greater than 1000:
      #   num = 1000.∀   # ⇒ 634
      # @return a random number in the given interval.
      def ∀
        rand(self)
      end
      alias any ∀
      
      # Generates random +Fixnum+ in the given interval. We need +Fixnum+ implementing
      # +new+ method for instantiating it as parameter in common way.
      # @example To create the positive number not greater than 1000:
      #   num = Fixnum.new 1000   # ⇒ 48
      def self.new val = 1024
        val.∀
      end
    end

    # Enchancement of +Array+ class to generate random array of the given size. The array elements
    # are instances of the samples given. E. g. by default, there is an array of strings and fixnums
    # produced.
    class ::Array
      # Generates random sample of +Array+.
      # @example To create an array of three string elements:
      #   [""].∀ size: 3
      #   # ⇒ [
      #   #   [0] " пт64AVAэеыGN еCйдчDLFUL еPTюQL ",
      #   #   [1] "лW1O Cи 4TZ Yиз моBи2 AзмсU5г о ",
      #   #   [2] "70ZIзQOMXC0нXLPMкGдлэY7Bщ7Eх ой4"
      #   # ]
      # @param size [Fixnum] the size of the sample array to generate.
      # @param samples [Array] the array of samples used to generate the sample array.
      # @return [Array] the array of the given length, consisting of random elements from the given set.
      def ∀(size: 64, samples: ["", 1000])
        samples = self unless self.empty?
        [].tap { |v| size.times { v << ::Kernel::random(:samples => samples) } }
      end
      alias any ∀
    end

    # Enchancement of +Hash+ class to generate random hash of the given size. The hash elements
    # are instances of the samples given. The keys are in the range +(‘a’..‘z’)+.
    # By default, there is a hash having strings and fixnums as values.
    class ::Hash
      # Generates random sample of +Hash+.
      # @note When called on non-empty hash, the random elements are _added_ to the existing.
      # @todo Do we really need to append randoms? Isn’t +{}.∀ | {:foo ⇒ 42}+ clearer?
      # @example To create a hash of three elements:
      #   {}.∀ size: 3
      #   # ⇒ {
      #   #   "pcnoljbhibgjywosztzheuimqfawzi" => 821,
      #   # "rjdrhidkhrowsonpsmaskdjfbhpuwunh" => " рлшеALя н нмкж0отDщ5 MеьFKB1Mъ5",
      #   # "zbalqtiqysdfbartnebvkmwzvudxkzmk" => "Dе904KшNщуO7EывхJбMUV йN Zч энж"
      #   # }
      # @param size [Fixnum] the size of the sample hash to generate.
      # @param samples [Array] the array of samples used to generate the values of the sample hash.
      # @return [Hash] the hash of the given length, consisting of random elements from the given set.
      def ∀(size: 64, samples: ["", 1000])
        self.dup.tap { |v|
          size.times {
            v["".∀(:symbols => [*('a'..'z')])] = ::Kernel::random(:samples => samples)
          }
        }
      end
      alias any ∀
    end

    # Enchancement of +Range+ class to join range elements into string.
    class ::Range
      # Joins range elements into string.
      # @return [String] string representation of the range
      def to_chars
        self.to_a.join
      end
    end

    # @private
    module ::Enumerable
      def sum
        self.inject(0){|accum, i| accum + i }
      end
  
      def mean
        self.sum/self.length.to_f
      end
  
      def sample_variance
        m = self.mean
        sum = self.inject(0){|accum, i| accum +(i-m)**2 }
        sum/(self.length - 1).to_f
      end
  
      def standard_deviation
        return Math.sqrt(self.sample_variance)
      end
    end
    
    class ::ArgumentError
      def argument_data
        /\((?<given>\d+)\s+\w+\s+(?<min_required>\d+)(?<modifier>\+|\.\.)?(?<max_required>\d+)\)/.match(self.to_s) { |m|
          { :given => m[:given],
            :min_required => m[:min_required],
            :max_required => case m[:modifier]
                             when '+' then '∞'
                             when '..' then h[:max_required]
                             else h[:min_required]
                             end
          }
        }
      end
    end
    
    class ::TypeError
      def type_data
        # can't convert Hash into Integer
        # There are two ways to match: either rely on us locale, or find the uppercased classes
        /[^[A-Z]]*(?<given>[A-Z]\w*)[^[A-Z]]*(?<required>[A-Z]\w*)/.match(self.to_s) { |m|
          { :given => m[:given], :required => m[:required] }
        }
      end
    end

    module ::Kernel
      # Alias for lambda
      alias λ lambda
      # Alias for proc
      alias Λ proc
      # default set of classes, supporting `random` feature
      DEFAULT_SAMPLES ||= ["", 1024, {}, []].freeze
      # The stub class for determining parameter list
      class RandomVoid ; def ∀ ; NotImplementedError.new('RandomVoid class is not intended to use.') ; end ; end

    protected
      # Random instance of random class
      # @param samples [Array] the instances of classes supporting `#random` method.
      #        Those will vbe used as initial parameters for calls to `random` on them.
      # @return random instance of one of the classes given as parameters
      def random(samples: DEFAULT_SAMPLES)
        samples.dup.sample.∀
      end
    end

    class ::Class
      # Instance of a class and the result of last call to method with fake params
      attr_reader :★, :☆
      
      # Tries to make a new instance of a class
      def ☎
        fake_parameters unless @★
        @★
      end

      # Tries to call a mthd on a class
      # @param m [Symbol] the method to be called
      def ☏ m = :to_s
        ☎.send(m, *fake_parameters(:m => m))
      end

      # Instantiates the class with applicable random value
      # @return a random value of this Class class
      def ∀ *args
        begin
          inst = self.☎
          raise NotImplementedError.new("The class should implement `∀` instance method") \
            unless inst.respond_to? :∀
          inst.∀ *args
        rescue Exception => e
          raise NotImplementedError.new("No way: #{e}")
        end
      end

private
      # First of all, let′s try to determine parameters needed:
      #
      # method(__method__).parameters.inject([]) { |res, v| (res << v[1]) if v[0] == :req; res }
      # method(__method__).parameters.select { |a| a[0] == :req }.map { |a| a[1] }
      #
      # Rehearsal ----------------------------------------------
      # inject       0.510000   0.000000   0.510000 (  0.507843)
      # select+map   0.470000   0.000000   0.470000 (  0.472166)
      # ------------------------------------- total: 0.980000sec
      # user     system      total        real
      # inject       0.520000   0.000000   0.520000 (  0.518626)
      # select+map   0.470000   0.000000   0.470000 (  0.473081)
      #
      # That’s why we are to use `select+map` version.
      def required_parameters(m: :initialize)
        param_selector = λ{ |type|
          self.instance_method(m).parameters.select { |p| p[0] == type }.map { |p| p[1] }
        }
        { :req  => param_selector.call(:req), :rest => param_selector.call(:rest) }
      end
      # Suggests random parameters for instance method of a class
      # Usage: `String.fake_parameters :method`
      # @param meth [Symbol] the method to suggest parameters for
      # @param inst [Object] an instance to suggest parameters of method for
      # @return [Array] an array of parameters suggested
      def fake_parameters(m: nil)
        if (@☆ ||= {})[m].nil?
          # We need an instance first of all
          if m.nil? || !@★
            params = required_parameters
            guessed = [].∀(:size => params[:req].size, :samples => [RandomVoid.new])
            guessed.map! { |elem|
              begin
                elem if @★ ||= self.new(*guessed)
              rescue TypeError => e
                ::Kernel.const_get(e.type_data[:required]).new.∀
              end
            }
            @★ ||= self.new(*guessed)
            @☆[nil] = guessed.map(&:class)
          end
          
          # Let’s proceed with method
          unless m.nil?
            params = required_parameters :m => m
            
            guessed = [].∀(:size => params[:req].size, :samples => [RandomVoid.new])
            guessed.map! { |elem|
              begin
                elem if @☆=@★.send(m, *guessed)
              rescue TypeError => e
                ::Kernel.const_get(e.type_data[:required]).new.∀
              end
            }
            @☆[m] = guessed.map(&:class)
          end
          
          guessed
        else
          @☆[m].map(&:∀)
        end
      end
    end

  end
end
