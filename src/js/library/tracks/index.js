import {
  exec
} from 'child_process'

import {
  clear
} from 'itunes-library-parser'

export const tracks = (jar, xml) => (
  new Promise((resolve, reject) => {
    exec(`java -jar ${jar} -s:"${xml}" -xsl:src/xsl/library/tracks.xsl`, (e) => (!e) ? resolve() : reject(e))
  })
)

/**
 *  For watchers
 */
export const execute = (jar, xml) => clear().then(() => tracks(jar, xml))
