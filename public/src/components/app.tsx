import * as React from "react";
import { Store as ReduxStore } from "redux";
import * as Domain from "../gameObjects";
import {Game} from "./game";
import { newGame } from "../actions";

export interface AppProps {
    store: ReduxStore<Domain.State>
}
export const App = (props: AppProps) => {
    let state = props.store.getState();
    let startNewGame = (difficulty: Domain.Difficulty) => (event) => {
        props.store.dispatch(newGame(difficulty));
    }
    if (state.game != null){
        return <Game game={state.game} onStartNewGame={startNewGame}></Game>
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