require 'bundler/setup'

Rake::TaskManager.record_task_metadata = true

require 'bueller'
Bueller::Tasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:examples) do |examples|
  examples.rspec_opts = '-Ispec'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rspec_opts = '-Ispec'
  spec.rcov = true
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format Yard::ColorCommentFormatter"
end

task :default => :examples

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['features/**/*.feature', 'features/**/*.rb']
  t.options = ['--any', '--extra', '--opts'] # optional
end

task :list do
  Rake.application.tasks.each do |task|
    print task.name() + ' #' + task.comment.to_s() + "\n"
  end
end
