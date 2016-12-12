import * as React from "react";
import * as ReactDOM from "react-dom";
import { App } from "./components/app"
import { store } from "./store";

ReactDOM.render(
    <App store={store} />,
    document.querySelector("#app")
);

