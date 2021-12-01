const presets = [
  [
    '@babel/env',
    {
      targets: {
        node: 'current'
      },
      useBuiltIns: 'usage',
      corejs: 3
    }
  ]
]

const plugins = [
  '@babel/transform-runtime',
  '@babel/proposal-export-default-from',
  '@babel/proposal-export-namespace-from',
  'syntax-async-functions',
  [
    'module-resolver', {
      root: ['./src/js'],
      cwd: 'babelrc',
      alias: {
        '~': './src/js'
      }
    }
  ]
]

module.exports = {
  compact: true,
  comments: false,
  presets,
  plugins
}
