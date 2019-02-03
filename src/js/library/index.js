import {
  exec
} from 'child_process'

import path from 'path'

import debug from 'debug'

import {
  clear
} from '~'

const error = debug('itunes-library-parser:to-m3u:error')
const log = debug('itunes-library-parser:to-m3u:log')

const cwd = path.resolve(__dirname, '../../..')
const xsl = path.resolve(cwd, 'src/xsl/library.xsl')

export const parse = (jar, xml, destination = './iTunes Library') => (
  new Promise((resolve, reject) => {
    exec(`java -jar "${path.resolve(jar)}" -s:"${path.resolve(xml)}" -xsl:"${xsl}" destination="${path.resolve(destination)}"`, { cwd }, (e) => (!e) ? resolve() : reject(e))
  })
)

export const toM3U = async (jar, xml, destination) => {
  try {
    await clear(destination)
    await parse(jar, xml, destination)

    log(`Succeeded parsing "${xml}"`)
  } catch ({ code, message }) {
    if (code === 2) {
      error('I/O error in Saxon. Sitting this one out')
    } else {
      error(message)
    }
  }
}

export * as tracks from './tracks'
export * as playlists from './playlists'
export * as transform from './transform'
