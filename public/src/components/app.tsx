import * as React from "react";
import { Store as ReduxStore } from "redux";
import * as Domain from "../gameObjects";
import {Game} from "./game";
import { newGame, playMove, Action } from "../actions";

export interface AppProps {
    store: ReduxStore<Domain.State>
}
export const App = (props: AppProps) => {
    let state = props.store.getState();
    let onStartNewGame = (difficulty: Domain.Difficulty) => {
        props.store.dispatch(
            newGame(difficulty, (a: Action) => props.store.dispatch(a))
        );
    }
    let startNewGame = (difficulty: Domain.Difficulty) => (event) => {
        onStartNewGame(difficulty);
    }
    let onMovePlayed = (col: number) => {
        props.store.dispatch(
            playMove(col, (a: Action) => props.store.dispatch(a))
        );
    }
    if (state.game != null){
        return <Game game={state.game} onStartNewGame={onStartNewGame} onMovePlayed={onMovePlayed}></Game>
    } else {
        return <div className="app">
            <h1>Connect 4</h1>
            <div>
                <button onClick={startNewGame("Easy")}>New Game vs Easy AI</button>
            </div>
            <div>
                <button onClick={startNewGame("Hard")}>New Game vs Hard AI</button>
            </div>
        </div>
    }
}
