require_relative './constants.rb'
require_relative './cell.rb'
require_relative './board.rb'

module LibConnect4
    class Game
        attr_reader :board
        attr_reader :moves

        def initialize(board: nil, moves: [])
            if board != nil then
                @board = LibConnect4::Board.new(contents: board.rows)
            else
                @board = LibConnect4::Board.new
            end
            @moves = moves
        end

        def move(player, column) 
            if @board.is_full? column then
                raise InvalidMoveError, "You cannot move there"
            else
                row = @board.columns[column].find_index { |cell| cell.value == LibConnect4::Empty } 
                @board[row, column] = player
                moves.push({player: player, column: column})
            end
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
        end

        protected
        def check_cell_groups(cell_groups)
            for group in cell_groups do
                for a,b,c,d in group.each_cons(4) do
                    winner_exists = self.all_the_same_color([a,b,c,d])
                    if (winner_exists) then
                        return a.value
                    end
                end
            end
            return nil
        end
        def all_the_same_color(cells) 
            if cells.any? {|c| c.value == LibConnect4::Empty } then
                false
            else 
                cells.all? {|c| c.value == cells[0].value }
            end
        end
    end
end
