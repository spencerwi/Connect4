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

        def winner
            # check rows
            winner = self.check_cell_groups(@board.rows)
            if (winner != nil) then 
                return winner 
            end
            # check cols
            winner = self.check_cell_groups(@board.columns)
            if (winner != nil) then 
                return winner 
            end

            # check diagonals
            winner = self.check_cell_groups(@board.right_diagonals.select {|diag| diag.length >=4 })
            if winner != nil then
                return winner
            end

            winner = self.check_cell_groups(@board.left_diagonals.select {|diag| diag.length >=4 })
            if winner != nil then
                return winner
            end


            # Step one: identify diagonals from game board
        end

        protected
        def check_cell_groups(cell_groups)
            for group in cell_groups do
                for i in 0..(group.length - 3) do
                    winner_exists = self.all_the_same_color([
                        group[i],
                        group[i+1],
                        group[i+2],
                        group[i+3]
                    ])
                    if (winner_exists) then
                        return group[i]
                    end
                end
            end
            return nil
        end
        def all_the_same_color(cells) 
            for i in (0..(cells.length - 2)) do
                if cells[i] == LibConnect4::Empty or cells[i] != cells[i+1] then
                    return false
                end
            end
            return true
        end
    end

    class InvalidMoveError < RuntimeError
    end
end
