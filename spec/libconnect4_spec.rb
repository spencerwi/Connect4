require 'libconnect4'

RSpec.describe LibConnect4::Game do
    it "initializes with an empty board" do
        game = LibConnect4::Game.new
        expect(game.board.row_count).to eq 6
        expect(game.board.column_count).to eq 7
        game.board.each do |cell|
            expect(cell).to eq LibConnect4::Empty
        end
    end

    context "during a game" do
        before(:each) do
            @game = LibConnect4::Game.new
        end

        it "updates the board correctly on player moves" do
            @game.move(LibConnect4::Red, 4)
            @game.move(LibConnect4::Black, 4)

            expect(@game.board[0,4]).to eq LibConnect4::Red
            expect(@game.board[1,4]).to eq LibConnect4::Black
        end

        it "disallows moves into a filled-up column" do
            6.times do
                @game.move(LibConnect4::Red, 4)
            end

            expect { @game.move(LibConnect4::Red, 4) }.to raise_error(LibConnect4::InvalidMoveError)
        end

        context "when Red has won" do
            it "can correctly identify Red as the winner across" do
                (0..3).each {|x| @game.move(LibConnect4::Red, x)}
                expect(@game.winner).to eq LibConnect4::Red
            end
            it "can correctly identify Red as the winner down" do
                4.times { @game.move(LibConnect4::Red, 0) }
                expect(@game.winner).to eq LibConnect4::Red
            end
            it "can correctly identify Red as the winner diagonally-left" do
                ###
                # Board should look like:
                #   | O O O O O O |
                #   | O O O O O O |
                #   | R O O O O O |
                #   | B R O O O O |
                #   | R B R O O O |
                #   | B R B R O O |
                # so Red wins diagonally-left
                (0..3).each_with_index do |col, i| 
                    player = if i % 2 == 1 then LibConnect4::Red else LibConnect4::Black end
                    @game.move(player, col)
                end
                (0..2).each_with_index do |col, i| 
                    player = if i % 2 == 0 then LibConnect4::Red else LibConnect4::Black end
                    @game.move(player, col)
                end
                (0..1).each_with_index do |col, i| 
                    player = if i % 2 == 1 then LibConnect4::Red else LibConnect4::Black end
                    @game.move(player, col)
                end
                @game.move(LibConnect4::Red, 0)
                expect(@game.winner).to eq LibConnect4::Red
            end
            it "can correctly identify Red as the winner diagonally-right" do
                ###
                # Board should look like:
                #   | O O O O O O |
                #   | O O O O O O |
                #   | O O O O O R |
                #   | O O O O R B |
                #   | O O O R B R |
                #   | O O R B R B |
                # so Red wins diagonally-right
                last_column = (@game.board.column_count - 1)
                (0..3).each_with_index do |col, i| 
                    player = if i % 2 == 1 then LibConnect4::Red else LibConnect4::Black end
                    @game.move(player, (last_column - col))
                end
                (0..2).each_with_index do |col, i| 
                    player = if i % 2 == 0 then LibConnect4::Red else LibConnect4::Black end
                    @game.move(player, (last_column - col))
                end
                (0..1).each_with_index do |col, i| 
                    player = if i % 2 == 1 then LibConnect4::Red else LibConnect4::Black end
                    @game.move(player, (last_column - col))
                end
                @game.move(LibConnect4::Red, last_column)
                expect(@game.winner).to eq LibConnect4::Red
            end
        end
        context "when Black has won" do
            it "can correctly identify Black as the winner across" do
                (3..6).each {|x| @game.move(LibConnect4::Black, x)}
                expect(@game.winner).to eq LibConnect4::Black
            end
            it "can correctly identify Black as the winner down" do
                4.times { @game.move(LibConnect4::Red, 0) }
                expect(@game.winner).to eq LibConnect4::Red
            end
            it "can correctly identify Black as the winner diagonally-left" do
                ###
                # Board should look like:
                #   | O O O O O O |
                #   | O O O O O O |
                #   | B O O O O O |
                #   | R B O O O O |
                #   | B R B O O O |
                #   | R B R B O O |
                # so Black wins diagonally-left
                (0..3).each_with_index do |col, i| 
                    player = if i % 2 == 1 then LibConnect4::Black else LibConnect4::Red end
                    @game.move(player, col)
                end
                (0..2).each_with_index do |col, i| 
                    player = if i % 2 == 0 then LibConnect4::Black else LibConnect4::Red end
                    @game.move(player, col)
                end
                (0..1).each_with_index do |col, i| 
                    player = if i % 2 == 1 then LibConnect4::Black else LibConnect4::Red end
                    @game.move(player, col)
                end
                @game.move(LibConnect4::Black, 0)
                expect(@game.winner).to eq LibConnect4::Black
            end
            it "can correctly identify Black as the winner diagonally-right" do
                ###
                # Board should look like:
                #   | O O O O O O |
                #   | O O O O O O |
                #   | O O O O O B |
                #   | O O O O B R |
                #   | O O O B R B |
                #   | O O B R B R |
                # so Red wins diagonally-right
                last_column = (@game.board.column_count - 1)
                (0..3).each_with_index do |col, i| 
                    player = if i % 2 == 1 then LibConnect4::Black else LibConnect4::Red end
                    @game.move(player, (last_column - col))
                end
                (0..2).each_with_index do |col, i| 
                    player = if i % 2 == 0 then LibConnect4::Black else LibConnect4::Red end
                    @game.move(player, (last_column - col))
                end
                (0..1).each_with_index do |col, i| 
                    player = if i % 2 == 1 then LibConnect4::Black else LibConnect4::Red end
                    @game.move(player, (last_column - col))
                end
                @game.move(LibConnect4::Black, last_column)
                expect(@game.winner).to eq LibConnect4::Black
            end
        end
        context "when nobody has won" do
            it "can correctly identify that there is no winner" do
                expect(@game.winner).to eq nil
                (0..6).each_with_index do |col, i| 
                    player = if i % 2 == 0 then LibConnect4::Red else LibConnect4::Black end
                    @game.move(player, col)
                end
            end
        end
    end

end
