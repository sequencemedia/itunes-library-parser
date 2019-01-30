import {
  exec
} from 'child_process'

import path from 'path'

import {
  clear
} from 'itunes-library-parser'

const cwd = path.resolve(__dirname, '../../../..')
const xsl = path.resolve(cwd, 'src/xsl/library/playlists.xsl')

export const parse = (jar, xml, destination) => (
  new Promise((resolve, reject) => {
    exec(`java -jar "${path.resolve(jar)}" -s:"${path.resolve(xml)}" -xsl:"${xsl}" destination="${destination ? path.resolve(destination) : ''}"`, { cwd }, (e) => (!e) ? resolve() : reject(e))
  })
)

export const toM3U = (jar, xml, destination) => clear().then(() => parse(jar, xml, destination))

export * as transform from './transform'
