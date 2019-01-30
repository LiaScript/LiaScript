const path = require('path');
const HtmlWebpackPlugin    = require('html-webpack-plugin');
const CleanWebpackPlugin   = require('clean-webpack-plugin');
const CopyWebpackPlugin    = require('copy-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: {
    'editor/index':  './src/javascript/webcomponents/ace.js',
    'formula/index': './src/javascript/webcomponents/katex.js',
    'lia/index':     './src/index.js'
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'dist'),
    publicPath: '/'
  },
  plugins: [
    new MiniCssExtractPlugin(),
    new CleanWebpackPlugin(['dist']),
    new CopyWebpackPlugin([
      { from: 'src/assets/logo.png', to: '.'},
      { from: 'vendor/responsivevoice.js', to: '.'},

      { from: "vendor/material_icons/material.css", to: 'css'},
      { from: "vendor/roboto/roboto.css", to: 'css'},

      { from: "vendor/material_icons/flUhRq6tzZclQEJ-Vdg-IuiaDsNc.woff2", to: 'css/fonts'},
      { from: "vendor/roboto/fonts", to: 'css/fonts'},

      { from: 'node_modules/katex/dist/katex.min.css', to: 'katex' },

      { from: 'node_modules/ace-builds/src-noconflict/', to: 'ace' },
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
          'css-loader'
        ]
      },
      {
        test: /\.(png|svg|jpg|gif)$/,
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
  /*    {
        test: /\.js$/,
        loader: 'babel-loader'
      },*/
      {
        test: /.elm$/,
        use: {
          loader: 'elm-webpack-loader?verbose=true',
          options: {
            debug: true,
          },
        },
      }
    ]
  }
};
