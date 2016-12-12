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
        def self.from_json string
            data = JSON.load string
            self.new(data['row'], data['col'], value: data['value'])
        end
    end

    refine LibConnect4::Board do
        def to_json
            rows.map {|row| row.map {|cell| cell.to_h } }
        end
        def self.from_json string
            data = JSON.load string
            cells = data.map {|row| row.map {|cell_json| LibConnect4::Cell.from_json cell_json} }
            self.new(contents: cells)
        end
    end

    refine LibConnect4::Game do
        def to_h
            {
                board: @board.to_json,
                moves: @moves,
                winner: @winner
            }
        end
        def to_json
            self.to_h.to_json
        end
        def self.from_json string
            data = JSON.load string
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
        def self.from_json string
            data = JSON.load string
            self.new(my_color: data['my_color'], difficulty: data['difficulty'])
        end
    end
end
