import { createStore, Store as ReduxStore } from "redux";
import { State } from "./gameObjects";
import * as reducers from "./reducers";

export const store: ReduxStore<State> = createStore(reducers.appState);
