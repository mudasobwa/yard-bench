# encoding: utf-8

require 'set'
require 'benchmark'

require_relative 'monkeypatches'

# This should be a DSL used as:
#   benchmark :time => true, :memory => true
# The information should be normalized and collected in a kind of knowledge base

module Yard
  module Bench
    module Marks
      using Yard::MonkeyPatches
      # Mark specified method of a class to be bemchmarkable
      #
      # @param clazz [Class] the class method is defined on
      # @param meth [Symbol] the method(s) to set as benchmarkable
      def self.∈ clazz, meth
        bm…(clazz) << meth
      end

      # It makes no sense to cache methods, params and other metastuff
      #   since the majority of the time takes benchmarking itself
      def self.⌛
        bm… { |c, m|
          # Deal with class
          clazz = Kernel.const_get(c) # class of the `c`

          meths = []
          m.each { |meth|
            meths |= case meth
              # puts all the methods, defined in this class to benchmarks
              when :⋅ then clazz.instance_methods(false)
              # puts all the methods, defined in this class and superclasses to benchmarks
              when :⋅⋅ then clazz.instance_methods(true)
              # puts all the singleton methods, defined in this class to benchmarks
              when :× then clazz.singleton_methods(false)
              # puts all the singleton methods, defined in this class and superclasses to benchmarks
              when :×× then clazz.singleton_methods(true)
              else [meth]
            end
          }
          
          {
            :class => clazz, :methods => meths.inject({}) { |agg, meth|
            bm = ⌚(clazz, meth)
            yield clazz, meth, bm if block_given?
            agg[meth] = bm
            agg # FIXME Is there _really_ no method to add new value and return Hash instance?!
          }}
        }
      end

    private
      # Standard time for the current processor/ram to normalize benchmarks
      STANDARD_TIME ||= Benchmark.measure { 1_000_000.times { "foo bar baz".capitalize }}.total 

      # Get all the benchmarks for the class. Lazy creates a `Set` to store
      #   benchmarks for future use if there is no benchmarks for the given class yet.
      #
      # @param clazz [Class] the class to return benchmarks for
      # @param &cb [λ] the codeblock to be executed on each benchmarked method
      # @return [Hash] all the benchmarks, collected from DSL as following
      #     benchmarks = {
      #       String.class => <Set: {:capitalize, :split}>,
      #       AClass.class => <Set: {:*}>
      #     }
      def self.bm… clazz = nil
        it = (@@benchmarks ||= {})
        it = (it[clazz] ||= Set.new) unless clazz.nil?
        if block_given?
          it.map(&Proc.new)
        else
          it
        end
      end
      # FIXME Not yet used: errors, yielded during benchmarking
      def self.fails…
        @@fails ||= Set.new
        block_given? ? @@fails.each(&Proc.new) : @@fails
      end
      # Measures the specified method of the class given
      # @param clazz [Class] the class to measure method for
      # @param m [Symbol] the method to measure
      # @param iterations [Fixnum] an amount of iterations to do
      def self.⌚ clazz, m, iterations = 3
        # Let’ calculate the applicable range
        deg = (1..10).each { |v|
          break v if Benchmark.measure { (10**v).times {clazz.☏ m} }.total > 0.01
        }
        {
          :times => 10**deg,
          :benchmarks => (deg...deg+iterations).to_a.map { |d| 10**d }.map { |e|
            Benchmark.measure { e.times {clazz.☏ m} }.total / STANDARD_TIME
          }
        }
      end
    end

    module ::Kernel
      # Mark the task for benchmarking
      # @param *attribs [[:rest]] the list of methods to benchmark
      def ⌚ *attribs
        attribs.each { |a| Yard::Bench::Marks.∈ self.to_s, a.to_sym }
      end
      alias benchmark ⌚
      
    end
  end
end

#BmTests::BmTester.new.do_it
#puts '-'*30
#puts Yard::Bench::Marks.bm…
#puts Yard::Bench::Marks.bm….reject {|c, m| c !~ /Test/}

#puts '-'*30
#Yard::Bench::Marks.bm…(BmTests::BmTester.to_s) { |m|
#  puts "Method: [#{m}]"
#}

#puts '-'*30
#Yard::Bench::Marks.bm… { |clazz, meth|
#  puts "Class: #{clazz}"
#  meth.each { |m|
#    puts "Method: [#{m}]"
##    puts "Method: [#{meth}], Params: [#{meth.parameters}], Time: [#{Yard::Bench::Marks.time meth}]"
#  }
#}

__END__
kb = `ps -o rss= -p #{$$}`.to_i
puts kb
10.times do
  (1..1_000_000).to_a.map { |m| 1000 - m }
  puts kb - (kb = `ps -o rss= -p #{$$}`.to_i)
end
sleep 5
puts `ps -o rss= -p #{$$}`.to_i
