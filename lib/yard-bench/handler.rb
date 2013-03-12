# encoding: utf-8

require_relative '../dsl/bm_dsl'

# FIXME Probably, that class is to be made as Proxy. Then during the methods
#       processing we’ll have an access to it to print the benchmarks out
#       within method scope…
module Yard
  module Handlers
    
#    class BenchmarkObject < YARD::CodeObjects::Base
#      def type ; :benchmark ; end
#      def sep  ; '%'        ; end
#    end
    
    class BenchmarkHandler < YARD::Handlers::Ruby::DSLHandler
      handles method_call(:benchmark)
      # we should only match method calls inside a namespace (class or module), not inside a method
      namespace_only
    
      def process
        ns = namespace.to_s
#        puts ; puts statement.methods ; puts
        cos = []
        statement.parameters.each { |astnode|
          if astnode.respond_to? :jump
            m = "#{astnode.jump(:string_content).source[1..-1]}";
            obj = YARD::CodeObjects::MethodObject.new(namespace, "#{m}")
            
            require_relative "../../examples/#{statement.file}" # FIXME
            bm = Yard::Bench::Marks.⌚(::Kernel.const_get("::#{ns}"), m.to_sym)
            #obj.benchmarks = [ {:name => "#{namespace}\##{m}"} ]
            obj.benchmarks = [ {:name => "#{bm}"} ]
            cos << obj
#              bmo = BenchmarkObject.new(namespace, m)
          end
        }
        cos
      end
    end
  end
end
