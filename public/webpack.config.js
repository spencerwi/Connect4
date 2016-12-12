module.exports = {
    entry: "./src/main.ts",
    output: {
        filename: "app.js",
        path: __dirname + "/dist"
    },
    devtool: "source-map",
    resolve: {
        extensions: ["", ".ts", ".js"]
    },
    module: {
        loaders: [
            {test: /\.ts$/, loader: "awesome-typescript-loader"}
        ],
        preLoaders: [
            {test: /\.js$/, loader: "source-map-loader"}
        ]
    }
}
