import {
  exec
} from 'child_process'

import {
  clear
} from 'itunes-library-parser'

export const playlists = (jar, xml) => (
  new Promise((resolve, reject) => {
    exec(`java -jar ${jar} -s:"${xml}" -xsl:src/xsl/library/playlists.xsl`, (e) => (!e) ? resolve() : reject(e))
  })
)

/**
 *  For watchers
 */
export const execute = (jar, xml) => clear().then(() => playlists(jar, xml))
