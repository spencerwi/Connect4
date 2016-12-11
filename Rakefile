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
        ai = LibConnect4::AI_Player.new LibConnect4::Black
        move_ai = Proc.new do
            move = ai.decide_next_move game.board
            game.move ai.my_color, move
            puts game.board
        end
        move_me = Proc.new do |col|
            game.move LibConnect4::Red, col
            puts game.board
        end
        binding.pry
    rescue LoadError
        puts "Cannot find pry; did you run `bundle install`?"
    end
end
