export type Difficulty = "Easy" | "Hard";
export type PlayerColor = "Red" | "Black";
export type Cell = {
    x: number
    y: number
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
    ai: AIPlayer
}
export type State = {
    game: Game | null
}
