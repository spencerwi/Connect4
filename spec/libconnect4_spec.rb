require 'libconnect4'

RSpec.describe LibConnect4 do

    describe "Board" do
        it "can identify all available moves" do
            game = LibConnect4::Game.new

            # At the outset, all moves should be available
            expect(game.board.available_moves).to eq ((0..game.board.column_count-1).to_a)

            # Fill up column 3
            game.board.row_count.times { game.move LibConnect4::Red, 3 }

            # Column 3 should no longer be an available move
            expect(game.board.available_moves).to eq ((0..game.board.column_count-1).select {|col| col != 3 })
        end

        it "can identify whether a particular cell is fillable" do
            game = LibConnect4::Game.new

            # At the outset, only cells on row 0 are fillable
            (0..(game.board.column_count - 1)).each do |col|
                expect(game.board.is_fillable? 0, col).to be true

                (1..(game.board.row_count - 1)).each do |row|
                    expect(game.board.is_fillable? row, col).to be false
                end
            end

            # After the first move in a column, the second row slot in that column is fillable
            game.move LibConnect4::Red, 3
            expect(game.board.is_fillable? 1, 3).to be true
        end
    end

    describe "Game" do
        it "initializes with an empty board" do
            game = LibConnect4::Game.new
            expect(game.board.row_count).to eq 6
            expect(game.board.column_count).to eq 7
            game.board.each do |cell|
                expect(cell.value).to eq LibConnect4::Empty
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

            it "keeps track of all valid moves attempted" do
                @game.move(LibConnect4::Red, 4)
                @game.move(LibConnect4::Black, 5)

                expect(@game.moves).to eq [
                    {player: LibConnect4::Red, column: 4},
                    {player: LibConnect4::Black, column: 5}
                ]
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

    describe "AI_Player" do
        it "knows which color it uses and which color the opponent uses" do
            ai = LibConnect4::AI_Player.new LibConnect4::Red
            expect(ai.my_color).to eq LibConnect4::Red
            expect(ai.opponent_color).to eq LibConnect4::Black

            ai = LibConnect4::AI_Player.new LibConnect4::Black
            expect(ai.my_color).to eq LibConnect4::Black
            expect(ai.opponent_color).to eq LibConnect4::Red
        end

        it "has two difficulty settings, Easy and Hard, which affect how far it looks ahead" do
            easy_ai = LibConnect4::AI_Player.new LibConnect4::Black, LibConnect4::AI_Player::Easy

            hard_ai = LibConnect4::AI_Player.new LibConnect4::Black, LibConnect4::AI_Player::Hard
            expect(easy_ai.lookahead_distance).to be < hard_ai.lookahead_distance
        end

        context "during a game" do
            context "a hard AI" do
                before(:each) do
                    @game = LibConnect4::Game.new
                    @ai = LibConnect4::AI_Player.new(LibConnect4::Black, LibConnect4::AI_Player::Hard)
                end

                it "will block an opponent from a near-win" do
                    3.times { @game.move @ai.opponent_color, 3}

                    expect(@ai.decide_next_move(@game.board)).to eq 3
                end

                it "will take an obvious winning move" do
                    3.times { @game.move @ai.my_color, 5}

                    expect(@ai.decide_next_move(@game.board)).to eq 5
                end
            end
            context "a easy AI" do
                before(:each) do
                    @game = LibConnect4::Game.new
                    @ai = LibConnect4::AI_Player.new(LibConnect4::Black, LibConnect4::AI_Player::Easy)
                end

                it "will block an opponent from a near-win" do
                    3.times { @game.move @ai.opponent_color, 3}

                    expect(@ai.decide_next_move(@game.board)).to eq 3
                end

                it "will take an obvious winning move" do
                    3.times { @game.move @ai.my_color, 5}

                    expect(@ai.decide_next_move(@game.board)).to eq 5
                end
            end
        end
    end
end
