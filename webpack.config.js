const path = require('path');
const webpack = require('webpack');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
    context: path.resolve(__dirname, 'src'),
    entry: {
        // Each entry in here would declare a file that needs to be transpiled
        // and included in the extension source.
        // For example, you could add a background script like:
        // background: './src/background.js',
        options: 'options/options.js',
        background: 'background/background.js',
        content: 'content/content.js',
    },
    output: {
        // This copies each source entry into the extension dist folder named
        // after its entry config key.
        path: path.resolve(__dirname, 'dist'),
        filename: '[name]/[name].js',
    },
    module: {
        // This transpiles all code (except for third party modules) using Babel.
        loaders: [{
            exclude: /node_modules/,
            test: /\.js$/,
            // Babel options are in .babelrc
            loaders: ['babel-loader'],
        }],
    },
    resolve: {
        // This allows you to import modules just like you would in a NodeJS app.
        extensions: ['.js'],
        modules: [path.resolve(__dirname, "src"), "node_modules"]
    },
    plugins: [
        // Since some NodeJS modules expect to be running in Node, it is helpful
        // to set this environment var to avoid reference errors.
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': JSON.stringify('production'),
        }),
        new CopyWebpackPlugin([
            {
                from: 'options/options.html',
                to: 'options',
            },
            {
                from: 'icons',
                to: 'icons',
            },
            'manifest.json',
        ])
    ],
    // This will expose source map files so that errors will point to your
    // original source files instead of the transpiled files.
    devtool: 'sourcemap',
};
