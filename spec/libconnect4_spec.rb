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
    end
end
