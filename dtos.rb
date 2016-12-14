require 'json'
require './lib/libconnect4.rb'

module LibConnect4Dtos
    refine LibConnect4::Cell do
        def to_h # Needed to avoid issues with nested to_json calls on the Board's to_json
            {
                row: @row,
                col: @col,
                value: @value
            }
        end
        def to_json
            self.to_h.to_json
        end
    end
    refine LibConnect4::Cell.singleton_class do
        def from_json input
            if input.is_a? String then
                data = JSON.load input
            else
                data = input
            end
            value = nil
            if data['value'].is_a? String then
                value = data['value'].to_sym
            else
                value = data['value']
            end
            self.new(data['row'], data['col'], value: value)
        end
    end

    refine LibConnect4::Board do
        def to_json
            rows.map {|row| row.map {|cell| cell.to_h } }
        end
    end
    refine LibConnect4::Board.singleton_class do
        def from_json input
            if input.is_a? String then
                data = JSON.load input
            else
                data = input
            end
            cells = data.map {|row| row.map {|cell_json| LibConnect4::Cell.from_json cell_json} }
            self.new(contents: cells)
        end
    end

    refine LibConnect4::Game do
        def to_h
            winner = self.winner
            if winner == nil and @board.available_moves.empty? then
                winner = :Draw
            end
            {
                board: @board.to_json,
                moves: @moves,
                winner: winner
            }
        end
        def to_json
            self.to_h.to_json
        end
    end
    refine LibConnect4::Game.singleton_class do
        def from_json input
            if input.is_a? String then
                data = JSON.load input
            else
                data = input
            end
            board = LibConnect4::Board.from_json data['board']
            self.new(board: board, moves: data['moves'])
        end
    end

    refine LibConnect4::AI_Player do
        def to_h
            {
                my_color: @my_color,
                difficulty: self.difficulty
            }
        end
        def to_json
            self.to_h.to_json
        end
    end
    refine LibConnect4::AI_Player.singleton_class do
        def from_json input
            if input.is_a? String then
                data = JSON.load input
            else
                data = input
            end
            my_color = nil
            if data['my_color'].is_a? String then
                my_color = data['my_color'].to_sym
            else
                my_color = data['my_color']
            end
            difficulty = nil
            if data['difficulty'].is_a? String then
                difficulty = data['difficulty'].to_sym
            else
                difficulty = data['difficulty']
            end
            self.new(my_color, difficulty)
        end
    end
end
