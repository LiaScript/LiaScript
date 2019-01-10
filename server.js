const webpackDevServer = require('webpack-dev-server');
const webpack = require('webpack');

const config = require('./webpack.dev.js');
const options = {
  contentBase: [ './dist', './demos' ],
  host: 'localhost',
  // hot: true,
};

webpackDevServer.addDevServerEntrypoints(config, options);
const compiler = webpack(config);
const server = new webpackDevServer(compiler, options);

server.listen(3333, 'localhost', () => {
  console.log('dev server listening on port 3333');
});
