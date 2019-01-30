import {
  exec
} from 'child_process'

import path from 'path'

import {
  readFile
} from 'sacred-fs'

import rimraf from 'rimraf'

import debug from 'debug'

import {
  transform
} from 'itunes-library-parser/transform'

const error = debug('itunes-library-parser:to-json:error')

const cwd = path.resolve(__dirname, '../../../../..')
const xsl = path.resolve(cwd, 'src/xsl/library/tracks/to-json.xsl')
const DESTINATION = path.resolve(cwd, '.itunes-library/playlists.json')

export const parse = (jar, xml, destination = DESTINATION) => (
  new Promise((resolve, reject) => {
    exec(`java -jar "${path.resolve(jar)}" -s:"${path.resolve(xml)}" -xsl:"${xsl}" -o:"${destination}"`, { cwd }, (e) => (!e) ? resolve() : reject(e))
  })
)

const execute = (jar, xml) => (
  parse(jar, xml, DESTINATION)
    .then(() => readFile(DESTINATION))
    .then((fileData) => (
      new Promise((resolve, reject) => {
        rimraf(path.resolve(cwd, '.itunes-library'), (e) => (!e) ? resolve(fileData) : reject(e))
      })
    ))
)

export const toJSON = async (jar, xml) => {
  try {
    const fileData = await execute(jar, xml)

    return fileData.toString('utf8')
  } catch (e) {
    error(e)

    throw new Error('Failed to process XML to JSON')
  }
}

export const toJS = async (jar, xml) => {
  try {
    return JSON.parse(await toJSON(jar, xml))
  } catch (e) {
    error(e)

    throw new Error('Failed to process XML to JS')
  }
}

export const toES = async (jar, xml) => {
  try {
    return transform(JSON.parse(await toJSON(jar, xml)))
  } catch (e) {
    error(e)

    throw new Error('Failed to process XML to ES')
  }
}
