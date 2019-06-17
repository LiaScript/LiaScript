const path = require('path');

const elmMinify = require("elm-minify");

const HtmlWebpackPlugin       = require('html-webpack-plugin');
const CleanWebpackPlugin      = require('clean-webpack-plugin');
const CopyWebpackPlugin       = require('copy-webpack-plugin');
const MiniCssExtractPlugin    = require('mini-css-extract-plugin');
const TerserPlugin            = require('terser-webpack-plugin');
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");


module.exports = {
  optimization: {
    minimizer: [
      new TerserPlugin({
        cache: true,
        parallel: true,
        sourceMap: false,
      }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
    'lia/index':     './src/index.js',
    'editor/index':  './src/javascript/webcomponents/ace.js',
    'formula/index': './src/javascript/webcomponents/katex.js'

  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'dist'),
    publicPath: '/'
  },
  plugins: [
    new elmMinify.WebpackPlugin(),
    new MiniCssExtractPlugin(),
    new CleanWebpackPlugin(['dist']),
    new CopyWebpackPlugin([
      { from: 'src/assets/logo.png', to: '.'},
      { from: 'src/assets/README.md', to: '.'},
      { from: 'vendor/responsivevoice.js', to: '.'},

      { from: "vendor/material_icons/material.css", to: 'css'},
      { from: "vendor/roboto/roboto.css", to: 'css'},

      { from: "vendor/material_icons/flUhRq6tzZclQEJ-Vdg-IuiaDsNc.woff2", to: 'css/fonts'},
      { from: "vendor/roboto/fonts", to: 'css/fonts'},

      { from: 'node_modules/katex/dist/katex.min.css', to: 'formula' },

      { from: 'node_modules/ace-builds/src-min-noconflict/', to: 'editor' },
    ], { debug: "info"} ),
    new HtmlWebpackPlugin({
      filename: 'index.html',
      template: 'src/assets/index.html'
    })
  ],
  module: {
    rules: [
      {
        test: /\.scss$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader?sourceMap=false',
          'sass-loader?sourceMap=false',
        ],
      },
      {
        test: /\.css$/,
        use: [
          'style-loader',
          MiniCssExtractPlugin.loader,
          'css-loader?sourceMap=true'
        ]
      },
      {
        test: /\.(png|svg|jpg|gif)$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          'file-loader'
        ]
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf)$/,
        use: [
          'file-loader'
        ]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader?verbose=true',
          options: {
            debug: true,
            //optimize: true,
          },
        },
      }
    ]
  }
};
