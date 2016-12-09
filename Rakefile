begin 
    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:spec)

    task :default => :spec
rescue LoadError
    puts "Cannot find rspec; did you run `bundle install`?"
end

task :repl do
    begin 
        require 'pry'
        load 'lib/libconnect4.rb'
        game = LibConnect4::Game.new
        def rdiag(game)
            (0..3).each do |i|
                (i+1).times { game.move :Red, i }
            end
        end
        binding.pry
    rescue LoadError
        puts "Cannot find pry; did you run `bundle install`?"
    end
end
