import { Difficulty, Game, State } from "./gameObjects";

export type Action =
      {type: "NEW_GAME", difficulty: Difficulty, dispatch: (a: Action) => any }
    | {type: "NEW_GAME_CREATED", state: State}
    | {type: "PLAY_MOVE", column: number, dispatch: (a: Action) => any}
    | {type: "MOVE_PLAYED", updatedState: State}

export const newGame = (difficulty: Difficulty, dispatch: (a: Action) => any) : Action => ({type: "NEW_GAME", difficulty, dispatch})
export const newGameCreated = (state: State) : Action => ({type: "NEW_GAME_CREATED", state})
export const playMove = (column: number, dispatch: (a: Action) => any) : Action => ({type:"PLAY_MOVE", column, dispatch})
export const movePlayed = (updatedState: State) : Action => ({type: "MOVE_PLAYED", updatedState})
