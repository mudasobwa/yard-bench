require "yard-bench/version"

YARD::Templates::Engine.register_template_path File.dirname(__FILE__) + '/../templates'

require File.join(File.dirname(__FILE__), 'dsl', 'monkeypatches')
require File.join(File.dirname(__FILE__), 'dsl', 'bm_dsl')

require File.join(File.dirname(__FILE__), 'yard-bench', 'handler') if RUBY19
require File.join(File.dirname(__FILE__), 'yard-bench', 'legacy')
