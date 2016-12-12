require_relative './constants.rb'
require_relative './cell.rb'
require_relative './board.rb'
require_relative './game.rb'

module LibConnect4
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

        def difficulty 
            case @lookahead_distance
            when 1 then LibConnect4::AI_Player::Easy
            else LibConnect4::AI_Player::Hard
            end

        end

        def score_possible_board_state(board_state)
            winner_score = 1000
            one_move_away_score = 100
            two_moves_away_score = 10

            game_for_this_board = Game.new(board: board_state)
            winner = game_for_this_board.winner
            if winner != nil then
                case winner 
                    when @my_color then winner_score
                    when @opponent_color then -(winner_score) 
                end
            else
                (score_columns board_state, one_move_away_score, two_moves_away_score)
                +
                (score_rows_and_diagonals board_state, one_move_away_score, two_moves_away_score)
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


        def decide_next_move(board)
            best_move = nil
            best_score = -(Float::INFINITY)
            board.available_moves.each do |possible_move|
                game_for_next_move = Game.new(board: board)
                game_for_next_move.move @my_color, possible_move
                board_after_next_move = game_for_next_move.board
                score = alphabeta(board_after_next_move, 0, -(Float::INFINITY), Float::INFINITY, false)
                if score > best_score then
                    best_move = possible_move
                    best_score = score
                end
            end
            best_move
        end

        def alphabeta(board, current_moves_ahead, alpha, beta, is_my_move)
            if should_stop_searching? board, current_moves_ahead then
                score_possible_board_state(board)
            else
                if is_my_move then
                    board.available_moves.each do |possible_move|
                        game_after_next_move = LibConnect4::Game.new(board: board)
                        game_after_next_move.move(@my_color, possible_move)
                        alpha = [alpha, alphabeta(game_after_next_move.board, current_moves_ahead+1, alpha, beta, false)].max
                        break if beta <= alpha
                    end
                    alpha
                else
                    board.available_moves.each do |possible_move|
                        game_after_next_move = LibConnect4::Game.new(board: board)
                        game_after_next_move.move(@opponent_color, possible_move)
                        beta = [beta, alphabeta(game_after_next_move.board, current_moves_ahead+1, alpha, beta, false)].min
                        break if beta <= alpha
                    end
                    beta
                end
            end
        end
        def should_stop_searching?(board, moves_ahead)
            game_with_this_board = LibConnect4::Game.new(board: board)
            (board.available_moves.empty? || (moves_ahead >= @lookahead_distance) || (game_with_this_board.winner != nil))
        end
    end
end
