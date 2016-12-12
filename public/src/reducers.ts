import { newGameCreated, movePlayed, Action } from "./actions"
import { Game, State } from "./gameObjects"
import "es6-promise"; // polyfill ES6 Promise if needed
import "whatwg-fetch"; // polyfill fetch() API if needed

export const initialState: State = { game: null, ai: null }

export function appState(state: State = initialState, action: Action): State {
    switch(action.type){
        case "NEW_GAME":{
            console.log(`New Game: ${action.difficulty}`)
            fetch(`/api/game/new?difficulty=${action.difficulty}`)
                .then(response => response.json())
                .then(game => { action.dispatch(newGameCreated(game)) });
            break;
        }
        case "NEW_GAME_CREATED": {
            let {game, ai} = action.state
            state.game = game;
            state.ai = ai;
            break;
        }
        case "PLAY_MOVE": {
            // Request to the backend to play a move and get updated board
            console.log(`Play Move: ${action.column}`)
            fetch("/api/game/move", {
                method: "POST",
                body: JSON.stringify({
                    game: state.game,
                    ai: state.ai,
                    move: action.column
                })
            })
                .then(response => response.json())
                .then(game => { action.dispatch(movePlayed(game)) });
            break;
        }
        case "MOVE_PLAYED": {
            let {game, ai} = action.updatedState;
            state.game = game;
            state.ai = ai;
            break;
        }
    }
    return state;
}
