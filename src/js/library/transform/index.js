import {
  exec
} from 'child_process'

import path from 'path'

import {
  readFile
} from 'fs/promises'

import debug from 'debug'

import {
  transform
} from '~/transform'

const error = debug('itunes-library-parser:to-json:error')

const cwd = path.resolve(__dirname, '../../../..')
const xsl = path.resolve(cwd, 'src/xsl/library/to-json.xsl')
const DESTINATION = path.resolve(cwd, '.itunes-library.json')

/**
 *  `maxBuffer`
 */
export const parse = (jar, xml, destination = DESTINATION) => (
  new Promise((resolve, reject) => {
    exec(`java -jar "${path.resolve(jar)}" -s:"${path.resolve(xml)}" -xsl:"${xsl}" -o:"${destination}"`, { cwd }, (e) => (!e) ? resolve() : reject(e))
  })
)

const execute = (jar, xml) => parse(jar, xml, DESTINATION).then(() => readFile(DESTINATION, 'utf8'))

export async function toJSON (jar, xml) {
  try {
    const fileData = await execute(jar, xml)

    return fileData.toString('utf8')
  } catch ({ message }) {
    error(message)

    throw new Error('Failed to process XML to JSON')
  }
}

export async function toJS (jar, xml) {
  try {
    return JSON.parse(await toJSON(jar, xml))
  } catch ({ message }) {
    error(message)

    throw new Error('Failed to process XML to JS')
  }
}

export async function toES (jar, xml) {
  try {
    return transform(JSON.parse(await toJSON(jar, xml)))
  } catch ({ message }) {
    error(message)

    throw new Error('Failed to process XML to ES')
  }
}

export default {
  toJSON,
  toJS,
  toES
}
