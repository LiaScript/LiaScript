const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');


module.exports = {
  entry: {
    'editor/index':  './src/javascript/editor/codemirror.js',
    'formula/index': './src/javascript/formula/katex.js',
    'lia/index':     './src/index.js',
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'dist'),
    publicPath: '/'
  },
  plugins: [
    new CleanWebpackPlugin(['dist']),
    new CopyWebpackPlugin([
      { from: 'node_modules/katex/dist/katex.min.css', to: 'katex' },
      { from: 'src/assets/logo.png', to: '.'}
    ], { debug: "info"} ),
    new HtmlWebpackPlugin({
      filename: 'index.html',
      template: 'src/assets/index.html'
    })
  ],
  module: {
    rules: [
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
          loader: 'elm-webpack-loader',
          options: {
            debug: true,
          },
        },
      },
    ]
  }
};
