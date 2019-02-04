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

const cwd = path.resolve(__dirname, '../../../..')
const xsl = path.resolve(cwd, 'src/xsl/library/playlists.xsl')

export const parse = (jar, xml, destination = './iTunes Library') => (
  new Promise((resolve, reject) => {
    exec(`java -jar "${path.resolve(jar)}" -s:"${path.resolve(xml)}" -xsl:"${xsl}" destination="${path.resolve(destination)}"`, { cwd }, (e) => (!e) ? resolve() : reject(e))
  })
)

export async function toM3U (jar, xml, destination) {
  try {
    await clear(destination)
    await parse(jar, xml, destination)

    log(`Succeeded parsing "${xml}"`)
  } catch ({ code, ...e }) {
    if (code === 2) {
      error('I/O error in Saxon')
    } else {
      const {
        message
      } = e

      error(message)
    }
  }
}

export * as transform from './transform'
