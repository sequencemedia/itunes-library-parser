import {
  exec
} from 'child_process'

import {
  readFile
} from 'sacred-fs'

import del from 'del'

import debug from 'debug'

import {
  transform
} from 'itunes-library-parser/transform'

const error = debug('itunes-library-parser:to-json:error')

export const library = (jar, xml, destination = '.itunes-library.json') => (
  new Promise((resolve, reject) => {
    exec(`java -jar ${jar} -s:"${xml}" -xsl:src/xsl/library/to-json.xsl -o:"${destination}"`, (e) => (!e) ? resolve() : reject(e))
  })
)

const execute = (jar, xml) => (
  library(jar, xml, '.itunes-library.json')
    .then(() => readFile('.itunes-library.json'))
    .then((fileData) => (
      del('.itunes-library.json').then(() => fileData)
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

export default {
  toJSON,
  toJS,
  toES
}
