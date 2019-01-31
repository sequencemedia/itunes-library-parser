import path from 'path'
import rimraf from 'rimraf'

export const clear = (destination = './iTunes Library') => (
  new Promise((resolve, reject) => {
    rimraf(`${path.resolve(destination)}/*`, (e) => (!e) ? resolve() : reject(e))
  })
)

export * as library from './library'
