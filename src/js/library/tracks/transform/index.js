import {
  exec
} from 'child_process'

import {
  readFile
} from 'sacred-fs'

import rimraf from 'rimraf'

import debug from 'debug'

import {
  transform
} from 'itunes-library-parser/transform'

const error = debug('itunes-library-parser:to-json:error')

export const tracks = (jar, xml, destination = '.itunes-library/tracks.json') => (
  new Promise((resolve, reject) => {
    exec(`java -jar ${jar} -s:"${xml}" -xsl:src/xsl/library/tracks/to-json.xsl -o:"${destination}"`, (e) => (!e) ? resolve() : reject(e))
  })
)

const execute = (jar, xml) => (
  tracks(jar, xml, '.itunes-library/tracks.json')
    .then(() => readFile('.itunes-library/tracks.json'))
    .then((fileData) => (
      new Promise((resolve, reject) => {
        rimraf('.itunes-library', (e) => (!e) ? resolve(fileData) : reject(e))
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
