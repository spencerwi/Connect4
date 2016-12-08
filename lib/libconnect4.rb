module LibConnect4
    Red   = :Red
    Black = :Black
    Empty = :Empty


    class Board 
        attr_reader :row_count
        attr_reader :column_count

        def initialize(rows: 6, columns: 7)
            @row_count = rows
            @column_count = columns
            @board = Array.new(rows) { Array.new(columns) { LibConnect4::Empty }}
        end

        def [](row, col)
            @board[row][col]
        end

        def []=(row, col, value)
            @board[row][col] = value
        end

        def rows
            @board.map {|row| row}
        end

        def columns
            @board.transpose
        end

        def each
            self.rows.flat_map {|row| row.each }
        end

        def to_s
            rows.reverse.map do |row|
                cells = row.map do |cell| 
                    case cell 
                        when LibConnect4::Red then "R" 
                        when LibConnect4::Black then "B" 
                        else "O"
                    end
                end.join(" ")
                "| #{cells} |"
            end.join("\n")
        end

        private
        attr_accessor :board
    end

    class Game
        attr_reader :board

        def initialize
            @board = LibConnect4::Board.new
        end

        def move(player, column) 
            if self.can_move_in_column? column then
                row = @board.columns[column].find_index { |cell| cell == LibConnect4::Empty } 
                @board[row, column] = player
            else
                raise InvalidMoveError, "You cannot move there"
            end
        end

        def can_move_in_column?(col)
            @board.columns[col].any? {|cell| cell == LibConnect4::Empty }
        end
    end

    class InvalidMoveError < RuntimeError
    end
end
