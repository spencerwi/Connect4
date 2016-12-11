module LibConnect4
    Red   = :Red
    Black = :Black
    Empty = :Empty


    class Cell
        attr_reader :row, :col
        attr_accessor :value
        def initialize(row, col)
            @row = row
            @col = col
            @value = LibConnect4::Empty
        end
    end

    class Board 
        attr_reader :row_count
        attr_reader :column_count

        def initialize(rows: 6, columns: 7)
            @row_count = rows
            @column_count = columns
            @board = (0..(rows - 1)).map do |row| 
                (0..(columns - 1)).map { |col| Cell.new row, col }
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
                        return group[i].value
                    end
                end
            end
            return nil
        end
        def all_the_same_color(cells) 
            for i in (0..(cells.length - 2)) do
                if cells[i].value == LibConnect4::Empty or cells[i].value != cells[i+1].value then
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

        def score_possible_board_state(board_state)
            winner_score = 10000
            one_move_away_score = 1000
            two_moves_away_score = 100

            game_for_this_board = Game.new(board: board_state)
            winner = game_for_this_board.winner
            if winner != nil then
                case winner 
                    when @my_color then winner_score
                    when @opponent_color then -(winner_score) 
                end
            else
                [
                    # Columns are simpler to score than rows or diagonals, so we use a simpler
                    #  check to score them.
                    (score_columns board_state, one_move_away_score, two_moves_away_score),
                    (score_rows_and_diagonals board_state, one_move_away_score, two_moves_away_score)
                ].inject(0, :+)
            end
        end
        def score_columns(board, one_move_away_score, two_moves_away_score)
            # In each non-full column, there's only one available move: 
            #   the first empty slot.
            # So checking how many moves away each column is from victory is
            #  simple: Walk back from the first empty slot, and find the 
            #  longest consecutive chain of a single color
            # Full columns cannot be moved into, so there's no use checking them.
            
            score = 0
            board.columns.each_with_index do |col_cells, col_number| 
                if not (board.is_full? col_number) then
                    lowest_empty = col_cells.find_index { |cell| cell.value == LibConnect4::Empty }
                    # An empty or one-chip column is 3-4 moves from victory, so it's always a 0 score.
                    if lowest_empty == 2 then 
                        # A column with 2 chips in it is at least 2 moves from victory.
                        if col_cells[0].value == col_cells[1].value then
                            # 2 moves from victory! 
                            if col_cells[0].value == @my_color then
                                score += two_moves_away_score
                            else 
                                score -= two_moves_away_score
                            end
                        end
                    elsif lowest_empty >= 3 then
                        # a column with 3 chips in it is at least 1 move from victory.
                        cells_to_check = col_cells[(lowest_empty - 3)..(lowest_empty - 2)]
                        case (cells_to_check.map {|cell| cell.value})
                        when [@my_color, @my_color, @my_color] then score += one_move_away_score
                        when [@opponent_color, @opponent_color, @opponent_color] then score -= one_move_away_score
                        when [@opponent_color, @my_color, @my_color] then score += two_moves_away_score
                        when [@my_color, @opponent_color, @opponent_color] then score -= two_moves_away_score
                        when [@opponent_color, @my_color, @my_color] then score += two_moves_away_score
                        end
                    end
                end
            end
            score
        end

        def score_rows_and_diagonals(board, one_move_away_score, two_moves_away_score)
            # In each row and each diagonal, every empty slot is potentially a "fillable" slot, as long
            #  as the slot below it is filled. Also, "how many moves from victory"
            #  is more complex, because non-consecutive chips of the same color can
            #  still signal near-victory:
            #     R O R R  
            #  is one move away from victory for Red, even though there aren't three 
            #  consecutive Reds.
            #
            #  There are a finite set of patterns like this:
            #     R O R R  counts as 1 move away from victory
            #     R R O R  counts as 1 move away from victory
            #   and
            #     R O O R  counts as 2 moves away from victory
            #   assuming that the empty slots (O) are fillable.
            #
            #  We could write a complex algorithm to figure out a sort of "hamming distance",
            #   but since there are a finite set of known specific patterns for certain 
            #   "moves-away" values , it's likely easiest to simply check for those 
            #   patterns.
            #
            result_score = 0

            score_patterns = {
                one_move_away_score => [
                    [LibConnect4::Empty, @my_color, @my_color, @my_color],
                    [@my_color, LibConnect4::Empty, @my_color, @my_color],
                    [@my_color, @my_color, LibConnect4::Empty, @my_color],
                    [@my_color, @my_color, @my_color, LibConnect4::Empty]
                ],
                -(one_move_away_score) => [
                    [LibConnect4::Empty, @opponent_color, @opponent_color, @opponent_color],
                    [@opponent_color, LibConnect4::Empty, @opponent_color, @opponent_color],
                    [@opponent_color, @opponent_color, LibConnect4::Empty, @opponent_color],
                    [@opponent_color, @opponent_color, @opponent_color, LibConnect4::Empty]
                ],
                two_moves_away_score => [
                    [LibConnect4::Empty, LibConnect4::Empty, @my_color, @my_color],
                    [@my_color, LibConnect4::Empty, LibConnect4::Empty, @my_color],
                    [@my_color, @my_color, LibConnect4::Empty, LibConnect4::Empty]
                ],
                -(two_moves_away_score) => [
                    [LibConnect4::Empty, LibConnect4::Empty, @opponent_color, @opponent_color],
                    [@opponent_color, LibConnect4::Empty, LibConnect4::Empty, @opponent_color],
                    [@opponent_color, @opponent_color, LibConnect4::Empty, LibConnect4::Empty]
                ]
            }

            score_row_or_diag = Proc.new do |row_or_col|
                row_or_col_score = 0

                row_or_col.each_cons(4) do |four_cell_slice|
                    all_empties_are_fillable = four_cell_slice.select {|cell| cell.value == LibConnect4::Empty }
                        .all? {|cell| board.is_fillable? cell.row, cell.col }

                    if all_empties_are_fillable then
                        score_patterns.each_pair do |patterns_score, patterns|
                            if patterns.include? (four_cell_slice.map {|c| c.value}) then
                                row_or_col_score += patterns_score
                            end
                        end
                    end
                end

                row_or_col_score
            end

            rows_and_diags_to_score = board.rows.concat(board.right_diagonals).concat(board.left_diagonals).select {|row_or_diag| row_or_diag.length >= 4}

            rows_and_diags_to_score.each do |row_or_diag|
                result_score += score_row_or_diag.call(row_or_diag)
            end


            result_score
        end

        def should_stop_searching? board_state, moves_ahead
            board_is_full = (board_state.available_moves == [])
            game_with_this_board = LibConnect4::Game.new(board: board_state)
            (board_is_full || (moves_ahead >= @lookahead_distance) || (game_with_this_board.winner != nil))
        end

        def decide_next_move board
            result = alphabeta(board, 0, -(Float::INFINITY), Float::INFINITY, true, nil)
            result[:move]
        end

        def alphabeta board, current_moves_ahead, alpha, beta, is_my_move, previous_move
            # Minimax algorithm using "alpha-beta pruning" to cut off branches that score too far out of range
            # "alpha" is the best score that the AI is guaranteed to get, determined based on board state;
            # "beta" is the worst score that the opponent is guaranteed to get, determined based on board state;
            if should_stop_searching? board, current_moves_ahead then
                {move: previous_move, board: board, score: self.score_possible_board_state(board)}
            else
                if is_my_move then
                    best_move_value_for_this_branch = -(Float::INFINITY) 
                    # Of all the possible moves, since it's our turn, we want to 
                    #   see if there's one we can find that's better than our current "best", so we can pick the best route
                    board_for_next_move = nil
                    next_move = nil
                    board.available_moves.each do |move|
                        board_for_next_move = board.clone
                        next_move = move
                        game_for_next_move = Game.new(board: board_for_next_move)
                        game_for_next_move.move @my_color, move
                        best_move_value_for_this_branch = [best_move_value_for_this_branch, alphabeta(game_for_next_move.board, current_moves_ahead+1, alpha, beta, false, move)[:score]].max
                        alpha = [alpha, best_move_value_for_this_branch].max
                        if beta <= alpha then
                            #  If the most damaging move the opponent can make can make brings them more value than we can get on this branch, don't explore this branch any further
                            break
                        end
                    end
                    return {move: next_move, board: board_for_next_move, score: best_move_value_for_this_branch}
                else
                    board_for_next_move = nil
                    next_move = nil
                    worst_move_value_for_this_branch = Float::INFINITY
                    # Of all the possible moves, since it's the opponent's turn, we want to 
                    #   see what move they could make that'd be worst for us, so we can pick the least-risky route
                    board.available_moves.each do |move|
                        board_for_next_move = board.clone
                        game_for_next_move = Game.new(board: board_for_next_move)
                        game_for_next_move.move @opponent_color, move
                        worst_move_value_for_this_branch = [worst_move_value_for_this_branch, alphabeta(game_for_next_move.board, current_moves_ahead+1, alpha, beta, true, move)[:score]].min
                        beta = [beta, worst_move_value_for_this_branch].min
                        if beta <= alpha then
                            #  If the most damaging move the opponent can make can make brings them more value than we can get on this branch, don't explore this branch any further
                            break
                        end
                    end
                    return {move: next_move, board: board_for_next_move, score: worst_move_value_for_this_branch}
                end
            end
        end
    end

    class InvalidMoveError < RuntimeError
    end
end
