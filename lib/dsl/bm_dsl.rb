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
          it.each(&Proc.new)
          nil
        else
          it
        end
      end
      def self.fails…
        @@fails ||= Set.new
        block_given? ? @@fails.each(&Proc.new) : @@fails
      end

      # Mark specified method of a class to be bemchmarkable
      #
      # @param clazz [Class] the class method is defined on
      # @param meth [Symbol] the method(s) to set as benchmarkable
      def self.bm∈ clazz, meth
        bm…(clazz) << meth
      end
    end

    module ::Kernel
      # Mark the task for benchmarking
      # @param *attribs [[:rest]] the list of methods to benchmark
      def ⌚ *attribs
        attribs.each { |a| Yard::Bench::Marks.bm∈ self.to_s, a.to_sym }
      end
      alias benchmark ⌚
      
      # FIXME Don’t do this until it is really needed
      STANDARD_TIME ||= Benchmark.measure { 1_000_000.times { "foo bar baz".capitalize }}.total 

      def ☂⌛ clazz, m, iterations = 3
        # Let’ calculate the applicable range
        deg = (1..10).each { |v|
          break v if Benchmark.measure { (10**v).times {clazz.☏ m} }.total > 0.01
        }
        (deg...deg+iterations).to_a.map { |d| 10**d }.map { |e|
          Benchmark.measure { e.times {clazz.☏ m} }.total / STANDARD_TIME
        }
      end

      # It makes no sense to cache methods, params and other metastuff
      #   since the majority of the time takes benchmarking itself
      def ⌛
        Yard::Bench::Marks.bm… { |c, m|
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
          meths.each { |meth|
            yield clazz, meth, ☂⌛(clazz, meth) if block_given?
          }
        }
      end
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
