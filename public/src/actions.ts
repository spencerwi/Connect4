import { Difficulty } from "./gameObjects";

export type Action =
      {type: "NEW_GAME", difficulty: Difficulty }
    | {type: "PLAY_MOVE", column: number}

export const newGame = (difficulty: Difficulty) : Action => ({type: "NEW_GAME", difficulty})
export const playMove = (column: number) : Action => ({type:"PLAY_MOVE", column})
