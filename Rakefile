require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

namespace :coverage do
  desc "Open coverage report"
  task :report do
    require 'simplecov'
    `open "#{File.join SimpleCov.coverage_path, 'index.html'}"`
  end
end

task :spec do
  Rake::Task[:'coverage:report'].invoke unless ENV['TRAVIS_RUBY_VERSION']
end

require 'rainbow/ext/string' unless String.respond_to?(:color)
require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: :spec
