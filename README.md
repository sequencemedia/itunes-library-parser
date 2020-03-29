# @sequencemedia/itunes-library-parser

JavaScript functions and XSL stylesheets to parse an `iTunes Library.xml` file and transform it to [`m3u`](https://en.wikipedia.org/wiki/M3U) files, JSON, or JavaScript.

Requires [Java](https://www.oracle.com/java/technologies/javase-downloads.html) and [Saxon PE](https://www.saxonica.com/welcome/welcome.xml).

## Library

Transforms the entire library.

```javascript
const { toM3U } = require('./lib/js/library')
const {
  toJSON,
  toJS,
  toES
 } = require('./lib/js/library/transform')
```

### `toM3U`

Requires the arguments `jar`, `xml`, and `destination`.

- `jar` - the path to the Saxon binary on your device
- `xml` - the path to the `iTunes Library.xml` file
- `destination` - the path for the `m3u` files to be written

Returns a `Promise` resolving when all `m3u` files are written.

### `toJSON`

Requires the arguments `jar`, and `xml`.

- `jar` - the path to the Saxon binary on your device
- `xml` - the path to the `iTunes Library.xml` file

Returns a `Promise` resolving to a `JSON` string.

### `toJS`

Requires the arguments `jar`, and `xml`.

- `jar` - the path to the Saxon binary on your device
- `xml` - the path to the `iTunes Library.xml` file

Returns a `Promise` resolving to a JavaScript object.

### `toES`

Requires the arguments `jar`, and `xml`.

- `jar` - the path to the Saxon binary on your device
- `xml` - the path to the `iTunes Library.xml` file

Returns a `Promise` resolving to a collection of JavaScript `Map` and `Set` instances.

## Playlists

Transforms the playlists.

```javascript
const { toM3U } = require('./lib/js/library/playlists')
const {
  toJSON,
  toJS,
  toES
 } = require('./lib/js/library/playlists/transform')
```

See **Library**.

## Tracks

Transforms the tracks.

```javascript
const { toM3U } = require('./lib/js/library/tracks')
const {
  toJSON,
  toJS,
  toES
 } = require('./lib/js/library/tracks/transform')
```

See **Library**.
