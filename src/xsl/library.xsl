<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="xsl">
	<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />

	<xsl:import href="library/tracks.xsl" />
	<xsl:import href="library/playlists.xsl" />

	<xsl:template match="/">
		<xsl:apply-templates select="plist/dict/key[. = 'Tracks']" />

		<xsl:apply-templates select="plist/dict/key[. = 'Playlists']" />
	</xsl:template>
</xsl:stylesheet>
