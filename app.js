require('@babel/register')

console.log(JSON.stringify(require('./iTunes Library.json'), null, ' '))

module.exports = require('./src/js')
