const path = require('path');
const HtmlWebpackPlugin    = require('html-webpack-plugin');
const CleanWebpackPlugin   = require('clean-webpack-plugin');
const CopyWebpackPlugin    = require('copy-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: {
    'editor/index':  './src/javascript/editor/codemirror.js',
    'formula/index': './src/javascript/formula/katex.js',
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

      { from: 'vendor/material_icons', to: 'fonts'},
      { from: "vendor/material_icons/flUhRq6tzZclQEJ-Vdg-IuiaDsNc.woff2", to: 'fonts'},
      { from: "vendor/roboto/fonts", to: 'fonts'},

      { from: 'node_modules/katex/dist/katex.min.css', to: 'katex' },
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
