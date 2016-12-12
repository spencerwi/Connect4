require_relative './constants.rb'
require_relative './cell.rb'

module LibConnect4
    class Board 
        attr_reader :row_count
        attr_reader :column_count

        def initialize(rows: 6, columns: 7, contents: nil)
            if contents == nil then
                @row_count = rows
                @column_count = columns
                @board = (0..(rows - 1)).map do |row| 
                    (0..(columns - 1)).map { |col| Cell.new row, col }
                end
            else
                @board = contents.map do |row|
                    row.map {|cell| cell.dup }
                end
                @row_count = contents.length
                @column_count = contents[0].length
            end
        end

        def [](row, col)
            @board[row][col].value
        end

        def []=(row, col, value)
            @board[row][col].value = value
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

        def right_diagonals
            # "shifting" rows from the top down and taking the resulting columns gets you a right-diagonal:
            # | I J K L |
            # | E F G H |
            # | A B C D |
            # gets shifted to
            # | I J K L |
            #   | E F G H |
            #     | A B C D |
            # Then just work your way "up" each column, and you have a right-diagonal.
            (0..(@row_count - 1)).map do |i|
                prefix = Array.new(@row_count - i)
                suffix = Array.new(i)
                prefix.concat(@board[i]).concat(suffix)
            end.transpose.map do |diag|
                diag.select {|x| x != nil }
            end
        end

        def left_diagonals
            # "shifting" rows from the bottom up and taking the resulting columns gets you a left-diagonal:
            # | I J K L |
            # | E F G H |
            # | A B C D |
            # gets shifted to
            #     | I J K L |
            #   | E F G H |
            # | A B C D |
            # Then just work your way "up" each column, and you have a left-diagonal.
            (0..(@row_count - 1)).map do |i|
                prefix = Array.new(i)
                suffix = Array.new(@row_count - i)
                prefix.concat(@board[i]).concat(suffix)
            end.transpose.map do |diag|
                diag.select {|x| x != nil }
            end
        end

        def is_full?(column)
            self.columns[column].none? {|cell| cell.value == LibConnect4::Empty }
        end

        def is_fillable?(row, col)
            cell_is_empty = (self[row,col] == LibConnect4::Empty)
            space_below_is_filled = (row == 0 or self[row-1, col] != LibConnect4::Empty)
            cell_is_empty and space_below_is_filled
        end

        def available_moves
            (0..(@column_count-1)).reject {|col| self.is_full? col }
        end

        def to_s
            rows.reverse.map do |row|
                cells = row.map do |cell| 
                    case cell.value
                        when LibConnect4::Red then "R" 
                        when LibConnect4::Black then "B" 
                        else "O"
                    end
                end.join(" ")
                "| #{cells} |"
            end.join("\n")
        end

        protected
        attr_accessor :board
    end
end
