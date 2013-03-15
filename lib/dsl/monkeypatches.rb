# encoding: utf-8

# @author Alexei Matyushkin
module Yard
  # Monkey patches (🐵) for shorthands.
  module MonkeyPatches

    class ::Array
      # def … ; block_given? ? each(&Proc.new) : each ; end
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

    # Sample for String
    # FIXME Possible wanna use [Faker](http://faker.rubyforge.org/) here
    class ::String
      def ∀(size: 32, symbols: [*('A'..'Z'), *('а'..'я'), *('0'..'9'), *[' ']*10])
        syms = case
               when !self.empty? then self.scan('.')
               when !(Array === symbols) && symbols.respond_to?(:to_a) then symbols.to_a
               else symbols
               end
        raise ArgumentError.new("`:symbols` argument class must support `#sample` method (given #{symbols})") \
          unless syms.respond_to? :sample
        self.dup.tap { |v| size.times { v << syms.sample } }.squeeze
      end
    end

    class ::Fixnum
      def ∀
        rand(self)
      end
      def self.new
        1024.∀
      end
    end

    class ::Array
      def ∀(size: 64, samples: ["", 1000])
        self.dup.tap { |v| size.times { v << ::Kernel::random(:samples => samples) } }
      end
    end

    class ::Hash
      def ∀(size: 64, samples: ["", 1000])
        self.dup.tap { |v|
          size.times {
            v["".∀(:symbols => [*('a'..'z')])] = ::Kernel::random(:samples => samples)
          }
        }
      end
    end

    class ::Range
      def to_chars
        self.to_a.join
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
