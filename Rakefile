begin 
    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:spec)

    task :default => :spec
rescue LoadError
    puts "Cannot find rspec; did you run `bundle install`?"
end
