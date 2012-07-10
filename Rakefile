require "bundler/gem_tasks"
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new("spec")

if ENV['TRAVIS_BUILD'].nil?
  require "yard"
  YARD::Rake::YardocTask.new do |t|
    t.options += ["--title", "Ideal-Mollie #{IdealMollie::VERSION} Documentation"]
  end
end
