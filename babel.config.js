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
]

module.exports = {
  compact: true,
  comments: false,
  presets,
  plugins
}
