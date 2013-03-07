# encoding: utf-8
# features/support/color-comment-formatter.rb

require 'rubygems'
require 'cucumber/formatter/pretty'

module Yard
  class ColorCommentFormatter < Cucumber::Formatter::Pretty
    def initialize(step_mother, io, options)
      super(step_mother, io, options)
    end

    def comment_line comment_line
      @io.puts(format_string(comment_line, :comment).indent(@indent))
      @io.flush
    end
  end
end
