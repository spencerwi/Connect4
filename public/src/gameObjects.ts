export type Difficulty = "Easy" | "Hard";
export type PlayerColor = "Red" | "Black";
export type Cell = {
    col: number
    row: number
    value: PlayerColor | "Empty"
}
export type Board = Array<Array<Cell>>;
export type Move = {
    player: PlayerColor,
    column: number
}
export type AIPlayer = {
    difficulty: Difficulty
    my_color: PlayerColor
}
export type Game = {
    board: Board
    moves: Array<Move>;
    winner: PlayerColor | null
}
export type State = {
    game: Game | null
    ai: AIPlayer | null
}
