import {
  exec
} from 'child_process'

import rimraf from 'rimraf'

export const clear = () => (
  new Promise((resolve, reject) => {
    rimraf('./iTunes Library/*', (e) => (!e) ? resolve() : reject(e))
  })
)

export const library = (jar, xml) => (
  new Promise((resolve, reject) => {
    exec(`java -jar ${jar} -s:"${xml}" -xsl:src/xsl/library.xsl`, (e) => (!e) ? resolve() : reject(e))
  })
)

/**
 *  For watchers
 */
export const execute = (jar, xml) => clear().then(() => library(jar, xml))
