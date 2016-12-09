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

        def is_full?(column)
            not (self.columns[column].any? {|cell| cell == LibConnect4::Empty })
        end

        def available_moves
            (0..(self.column_count-1)).reject {|col| self.is_full? col }
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
        attr_reader :moves

        def initialize(board: LibConnect4::Board.new)
            @board = LibConnect4::Board.new
            @moves = []
        end

        def move(player, column) 
            if @board.is_full? column then
                raise InvalidMoveError, "You cannot move there"
            else
                row = @board.columns[column].find_index { |cell| cell == LibConnect4::Empty } 
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

    class AI_Player 
        attr_reader :my_color, :opponent_color, :lookahead_distance
        Easy = :Easy
        Hard = :Hard

        def initialize(my_color, difficulty = LibConnect4::AI_Player::Easy) 
            @my_color = my_color
            @opponent_color = 
                if @my_color == LibConnect4::Red then 
                    LibConnect4::Black
                else 
                    LibConnect4::Red 
                end
            @lookahead_distance = 
                if difficulty == LibConnect4::AI_Player::Easy then
                    1
                else
                    3
                end
        end

        def score_possible_board_state board_state
            # TODO: scoring mechanism!
        end

        def should_stop_searching? board_state, moves_ahead
            board_is_full = (board_state.available_moves == [])
            game_with_this_board = LibConnect4::Game.new(board: board_state)
            (board_is_full || (moves_ahead >= @lookahead_distance) || (game_with_this_board.winner != nil))
        end

        def decide_next_move board
            alphabeta(board, 0, -(Float::INFINITY), Float::INFINITY, true)[:board]
        end

        def alphabeta board, current_moves_ahead, alpha, beta, is_my_move
            # Minimax algorithm using "alpha-beta pruning" to cut off branches that score too far out of range
            # "alpha" is the best score that the AI is guaranteed to get, determined based on board state;
            # "beta" is the worst score that the opponent is guaranteed to get, determined based on board state;
            if should_stop_searching? board, current_moves_ahead then
                {board: board, score: self.score_possible_board_state(board)}
            else
                if is_my_move then
                    best_move_value_for_this_branch = -(Float::INFINITY) 
                    # Of all the possible moves, since it's our turn, we want to 
                    #   see if there's one we can find that's better than our current "best", so we can pick the best route
                    board.available_moves.each do |move|
                        best_move_value_for_this_branch = board.clone
                        game_for_next_move = Game.new(board: board_for_next_move)
                        game_for_next_move.move @my_color, move
                        best_move_value_for_this_branch = [best_move_value_for_this_branch, alphabeta(game_for_next_move.board, current_moves_ahead+1, alpha, beta, false)[:score]].max
                        alpha = [alpha, best_move_value_for_this_branch].max
                        if beta <= a then
                            #  If the most damaging move the opponent can make can make brings them more value than we can get on this branch, don't explore this branch any further
                            break
                        end
                    end
                    return {board: board_for_next_move, score: best_move_value_for_this_branch}
                else
                    worst_move_value_for_this_branch = Float::INFINITY
                    # Of all the possible moves, since it's the opponent's turn, we want to 
                    #   see what move they could make that'd be worst for us, so we can pick the least-risky route
                    board.available_moves.each do |move|
                        board_for_next_move = board.clone
                        game_for_next_move = Game.new(board: board_for_next_move)
                        game_for_next_move.move @opponent_color, move
                        worst_move_value_for_this_branch = [worst_move_value_for_this_branch, alphabeta(game_for_next_move.board, current_moves_ahead+1, alpha, beta, true)[:score]].min
                        beta = [beta, worst_move_value_for_this_branch].min
                        if beta <= a then
                            #  If the most damaging move the opponent can make can make brings them more value than we can get on this branch, don't explore this branch any further
                            break
                        end
                    end
                    return {board: board_for_next_move, score: worst_move_value_for_this_branch}
                end
            end
        end
    end

    class InvalidMoveError < RuntimeError
    end
end
