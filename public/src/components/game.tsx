import * as React from "react";
import * as Domain from "../gameObjects";
import {Board} from "./board";

export interface GameProps {
    game: Domain.Game
    onStartNewGame: (Difficulty) => (event: any) => any
}
export const Game = (props: GameProps) => {
    if (props.game.winner == null){
        return <Board board={props.game.board}></Board>
    } else {
        return <div className="gameResult">
            <p>Winner: {props.game.winner}!</p>
            <div>
                <button onClick={props.onStartNewGame("Easy")}>New Game vs Easy AI</button>
            </div>
            <div>
                <button onClick={props.onStartNewGame("Hard")}>New Game vs Hard AI</button>
            </div>
        </div>
    }
}
