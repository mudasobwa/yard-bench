# encoding: utf-8

class BenchmarkHandler < YARD::Handlers::Ruby::Base
  handles method_call(:benchmark)
#  namespace_only

  def process
    (obj ||= {})[:benchmarks] ||= []
    statement.parameters.each { |astnode|
      obj[:benchmarks] << {
        name: astnode.jump(:string_content).source,
        file: statement.file,
        line: statement.line
      } if astnode.respond_to? :jump
    }
    puts obj
    puts
    puts
    obj
#    parse_block(statement.last.last, owner: obj)
  rescue YARD::Handlers::NamespaceMissingError
  end
end
