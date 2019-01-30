import rimraf from 'rimraf'

export const clear = () => (
  new Promise((resolve, reject) => {
    rimraf('./iTunes Library/*', (e) => (!e) ? resolve() : reject(e))
  })
)

export * as library from './library'
