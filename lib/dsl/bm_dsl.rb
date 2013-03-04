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
      
      def self.⌚
        
      end
      
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

    refine Kernel do
      def ⌚ *attribs
        attribs.each { |a| Yard::Bench::Marks.bm∈ self.to_s, a.to_sym }
      end
      alias benchmark ⌚
      
      # It makes no sense to cache methods, params and other metastuff
      #   since the majority of the time takes benchmarking itself
      def ⌛
        Yard::Bench::Marks.bm… { |c, m|
          # Deal with class
          clazz = Kernel.const_get(c) # class of the `c`
          # Get parameters of constructor. There is a problem with
          #   asking ruby about, since it always returns `[[:rest]]
          #   for constructor. So, let’s hack.
          begin
            inst = clazz.new
          rescue ArgumentError => e
            puts e.to_s
            /\((?<given>\d+)\s+\w+\s+(?<required>\d)(?<modifier>.*?)\)/.match(e.to_s) { |mtch|
              puts mtch[:given]
              puts mtch[:required]
              puts mtch[:modifier]
            }
            # Iterate through standard classes and supply args. If no one is OK, report an error.
            
          end
          p clazz.method(:new).parameters
          inst = clazz.new 100

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
            p "#{meth} : #{(inst.method meth).parameters}"
            Benchmark.bm(30) { |x|
              x.report("#{clazz}\##{meth}") { 1_000_000.times { inst.method meth } }
            }
          }
        }
#      begin
#      rescue NameError => e
#        Yard::Bench::Marks.fail e
#      end
      end
    end
  end
end

module Kernel
  
  def benchmarkold!
    (@@benchmarks ||= []).each do |bm|
      puts bm.klass.new("olala").send bm.method
      puts Benchmark.realtime {
        if bm.params.nil? || bm.params.size === 0
          1000.times { bm.klass.new("olala").send bm.method }
        else
          1000.times { bm.klass.new.send bm.method, bm.params }
        end
      }
    end
  end
end

using Yard::Bench

using Yard::MonkeyPatches
p "".random
p '-'*30
p 100.random
p '-'*30
p [].random
p '-'*30
p Hash.new.random


__END__

  
module BmTests
  class BmTester
    benchmark :do_it, :do_other
    attr_reader :value
    def initialize value, *attrs
      p "Inside init: [#{value}]"
      @value = value
    end
    def do_it deg
      @value ** deg
    end
    def do_other base = 2
      base ** @value
    end
  end
end
class String
  ⌚ :capitalize
end

⌛

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
