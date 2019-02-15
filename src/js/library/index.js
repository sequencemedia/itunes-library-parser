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

let immediate = null
const queue = []

export const parse = (jar, xml, destination = './iTunes Library') => (
  new Promise((resolve, reject) => {
    exec(`java -jar "${path.resolve(jar)}" -s:"${path.resolve(xml)}" -xsl:"${xsl}" destination="${path.resolve(destination)}"`, { cwd }, (e) => (!e) ? resolve() : reject(e))
  })
)

export async function toM3U (jar, xml, destination) {
  try {
    /**
     *  Permit only one set of values in the queue
     */
    if (!queue.some(({ jar: j, xml: x, destination: d }) => (
      j === jar &&
      x === xml &&
      d === destination)
    )) {
      /**
       *  Something is parsing, so
       */
      if (immediate) {
        /**
         *  En-queue the values
         */
        queue.push({ jar, xml, destination })
        /**
         *  (... if the XML changes while it's being parsed
         *  it should be parsed again immediately after,
         *  so the second of two identical calls will be
         *  put into the queue while the first is executing
         *
         *  In other words: the first call isn't put into the
         *  queue in order to allow that second call to be
         *  put into the queue!)
         */
      } else {
        /**
         *  Nothing is parsing, so
         */
        immediate = setImmediate(async () => {
          /**
           *  Parse the values
           */
          await clear(destination)
          await parse(jar, xml, destination)

          log(`Succeeded parsing "${xml}"`)

          immediate = null

          if (queue.length) {
            /**
             *  De-queue the values
             */

            const {
              jar: j,
              xml: x,
              destination: d
            } = queue.shift()

            return toM3U(j, x, d)
          }
        })
      }
    }
    return immediate
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

export * as tracks from './tracks'
export * as playlists from './playlists'
export * as transform from './transform'
