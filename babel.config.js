const presets = [
  [
    '@babel/env',
    {
      useBuiltIns: 'usage',
      targets: {
        node: 'current'
      }
    }
  ]
]

const plugins = [
  'syntax-async-functions',
  [
    'module-resolver', {
      alias: {
        'itunes-library-parser': './src/js'
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
