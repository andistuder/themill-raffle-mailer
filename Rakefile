require 'rake'

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  desc 'Disabled as RuboCop gem is unavailable'
  task :rubocop do
    raise 'Disabled as RuboCop gem is unavailable'
  end
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  desc 'Disabled as RSpec gem is unavailable'
  task :spec do
    raise 'Disabled as RSpec gem is unavailable'
  end
end

task default: [:spec, :rubocop]
