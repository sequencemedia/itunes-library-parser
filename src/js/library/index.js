import {
  exec
} from 'child_process'

import {
  clear
} from '~'

import path from 'path'

const cwd = path.resolve(__dirname, '../../..')
const xsl = path.resolve(cwd, 'src/xsl/library.xsl')

export const parse = (jar, xml, destination = './iTunes Library') => (
  new Promise((resolve, reject) => {
    exec(`java -jar "${path.resolve(jar)}" -s:"${path.resolve(xml)}" -xsl:"${xsl}" destination="${path.resolve(destination)}"`, { cwd }, (e) => (!e) ? resolve() : reject(e))
  })
)

export const toM3U = (jar, xml, destination) => clear(destination).then(() => parse(jar, xml, destination))

export * as tracks from './tracks'
export * as playlists from './playlists'
export * as transform from './transform'