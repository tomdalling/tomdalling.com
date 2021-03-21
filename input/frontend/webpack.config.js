const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CssMinimizerWebpackPlugin = require('css-minimizer-webpack-plugin');


module.exports = {
  entry: './src/main.css',
  mode: 'development',

  plugins: [
    new MiniCssExtractPlugin({filename: 'main.css'}),
  ],

  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader',
        ],
      },
    ],
  },

  optimization: {
    minimizer: [new CssMinimizerWebpackPlugin()],
  }
}
