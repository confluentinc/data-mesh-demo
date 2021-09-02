'use strict';

const HtmlWebpackPlugin = require('html-webpack-plugin');
const path = require('path');
const webpack = require('webpack');

const isWebpackDevServer = process.argv.some(a => path.basename(a) === 'webpack-dev-server');

const isWatch = process.argv.some(a => a === '--watch');

const plugins =
      isWebpackDevServer || !isWatch ? [] : [
        function() {
          this.plugin('done', function(stats) {
            process.stderr.write(stats.toString('errors-only'));
          });
        }
      ];

module.exports = {
  entry: {
    index: './entry.js',
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {}
        }
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      },
      {
        test: /\.less$/,
        use: ['style-loader', 'css-loader', 'less-loader']
      },
      {
        test: /\.(png|jpg|jpeg|svg|gif)$/,
        type: 'asset/resource',
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf)$/i,
        type: 'asset/resource',
      },
    ],
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js', '.elm', '.ttf'],
  },
  plugins: [
    new webpack.LoaderOptionsPlugin({
      debug: true
    }),
    new HtmlWebpackPlugin({
      template: 'static/index.html',
      title: 'Stream',
      chunks: ['index']
    })
  ].concat(plugins),

  output: {
    filename: '[name]-[fullhash].bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
};
