import { Action } from "./actions"
import { Game, State } from "./gameObjects"

export const initialState: State = { game: null }

export function appState(state: State = initialState, action: Action): State {
    switch(action.type){
        case "NEW_GAME":{
            // Request to the backend for a new game
            console.log(`New Game: ${action.difficulty}`)
            break;
        }
        case "PLAY_MOVE": {
            // Request to the backend to play a move and get updated board
            console.log(`Play Move: ${action.column}`)
            break;
        }
    }
    return state;
}
