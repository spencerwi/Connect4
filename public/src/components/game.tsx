import * as React from "react";
import * as Domain from "../gameObjects";
import {Board} from "./board";

export interface GameProps {
    game: Domain.Game
    onStartNewGame: (difficulty: Domain.Difficulty) => any
    onMovePlayed: (col: number) => any
}
export const Game = (props: GameProps) => {
    let startNewGame = (difficulty: Domain.Difficulty) => (event: any) => {
        props.onStartNewGame(difficulty);
    }
    if (props.game.winner == null){
        return <Board board={props.game.board} onMovePlayed={props.onMovePlayed}></Board>
    } else {
        return <div className="gameResult">
            <p>Winner: {props.game.winner}!</p>
            <div>
                <button onClick={startNewGame("Easy")}>New Game vs Easy AI</button>
            </div>
            <div>
                <button onClick={startNewGame("Hard")}>New Game vs Hard AI</button>
            </div>
        </div>
    }
}
