<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:seq="http://sequencemedia.net">
	<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />

	<xsl:import href="tracks.xsl" />

	<xsl:import href="playlists.xsl" />

	<xsl:template match="/">
		<xsl:apply-templates select="plist/dict/key[. = 'Tracks']" />

		<xsl:apply-templates select="plist/dict/key[. = 'Playlists']" />
	</xsl:template>
</xsl:stylesheet>
