<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:seq="http://sequencemedia.net"
	xmlns:url-decoder="java:java.net.URLDecoder"
	exclude-result-prefixes="xsl seq url-decoder">
	<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />

	<xsl:variable name="tracks" select="/plist/dict/key[. = 'Tracks']/following-sibling::dict" />

	<xsl:function name="seq:normalize-for-path">
		<xsl:param name="s" />

		<xsl:value-of select="translate(translate(replace(normalize-unicode($s, 'NFD'), '[%\[\]*?]', '_'), '\/:', '___'), '&#x0300;&#x0301;&#x0308;&#x0313;&#x0314;&#x0342;&#x0345;', '')" />
	</xsl:function>

	<xsl:function name="seq:get-album-path">
		<xsl:param name="albumArtist" />
		<xsl:param name="album" />

		<xsl:variable name="filePath" select="seq:normalize-for-path($albumArtist)" />
		<xsl:variable name="fileName" select="seq:normalize-for-path($album)" />

		<xsl:text>iTunes Library/Tracks/</xsl:text>
		<xsl:value-of select="$filePath" />
		<xsl:text>/</xsl:text>
		<xsl:value-of select="$fileName" />
		<xsl:text>.m3u8</xsl:text>
	</xsl:function>

	<xsl:function name="seq:get-album-path">
		<xsl:param name="album" />

		<xsl:variable name="fileName" select="seq:normalize-for-path($album)" />

		<xsl:text>iTunes Library/Tracks/Compilations/</xsl:text>

		<xsl:value-of select="$fileName" />

		<xsl:text>.m3u8</xsl:text>
	</xsl:function>

	<xsl:template match="key[. = 'Tracks']">

		<!-- Albums -->
		<xsl:for-each-group group-by="key[. = 'Album']/following-sibling::string[1]/text()" select="following-sibling::dict[1]/dict[
				key[. = 'Track Type']/following-sibling::string[1]/text() = 'File' and
				contains(lower-case(key[. = 'Kind']/following-sibling::string[1]/text()), 'audio') and
				not(local-name(key[. = 'Compilation']/following-sibling::*[1]) = 'true') and
				key[. = 'Album'] and
				key[. = 'Disc Number'] and
				key[. = 'Track Number']
			]">
			<xsl:sort select="key[. = 'Album']/following-sibling::string[1]/text()" />

			<xsl:variable name="albumArtist">
				<xsl:choose>
					<xsl:when test="key[. = 'Album Artist']/following-sibling::string[1]/text()">
						<xsl:value-of select="key[. = 'Album Artist']/following-sibling::string[1]/text()" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="key[. = 'Artist']/following-sibling::string[1]/text()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:result-document href="{seq:get-album-path($albumArtist, current-grouping-key())}" method="text">
				<xsl:call-template name="album">
					<xsl:with-param name="current-group" select="current-group()" />
				</xsl:call-template>
			</xsl:result-document>
		</xsl:for-each-group>

		<!-- Compilation albums -->
		<xsl:for-each-group group-by="key[. = 'Album']/following-sibling::string[1]/text()" select="following-sibling::dict[1]/dict[
				key[. = 'Track Type']/following-sibling::string[1]/text() = 'File' and
				contains(lower-case(key[. = 'Kind']/following-sibling::string[1]/text()), 'audio') and
				local-name(key[. = 'Compilation']/following-sibling::*[1]) = 'true' and
				key[. = 'Album'] and
				key[. = 'Disc Number'] and
				key[. = 'Track Number']
			]">
			<xsl:sort select="key[. = 'Album']/following-sibling::string[1]/text()" />

			<xsl:result-document href="{seq:get-album-path(current-grouping-key())}" method="text">
				<xsl:call-template name="album">
					<xsl:with-param name="current-group" select="current-group()" />
				</xsl:call-template>
			</xsl:result-document>
		</xsl:for-each-group>
	</xsl:template>

	<!-- Album: #EXTM3U -->
	<xsl:template name="album" match="dict">
		<xsl:param name="current-group" />

		<xsl:text>#EXTM3U</xsl:text>
		<xsl:text>&#13;</xsl:text>

		<xsl:for-each select="$current-group">
			<xsl:sort select="number(key[. = 'Disc Number']/following-sibling::integer[1]/text())" />
			<xsl:sort select="number(key[. = 'Track Number']/following-sibling::integer[1]/text())" />

			<xsl:apply-templates mode="album-track" select="." />
		</xsl:for-each>
	</xsl:template>

	<!-- Album track: #EXTINF -->
	<xsl:template mode="album-track" match="dict">
		<xsl:variable name="totalTime" select="floor(number(key[. = 'Total Time']/following-sibling::integer[1]) div 1000)" />
		<xsl:variable name="location" select="url-decoder:decode(key[. = 'Location']/following-sibling::string[1]/text())" />

		<xsl:text>#EXTINF:</xsl:text>
		<xsl:choose>
			<xsl:when test="number($totalTime)">
				<xsl:value-of select="$totalTime" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>-1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>,</xsl:text>
		<xsl:value-of select="key[. = 'Name']/following-sibling::string[1]/text()" />
		<xsl:text>&#32;-&#32;</xsl:text>
		<xsl:value-of select="key[. = 'Artist']/following-sibling::string[1]/text()" />
		<xsl:text>&#13;</xsl:text>

		<xsl:choose>
			<xsl:when test="starts-with($location, 'file://')">
				<xsl:value-of select="substring($location, 8)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$location" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#13;</xsl:text>
	</xsl:template>

	<xsl:template match="/">
		<xsl:apply-templates select="plist/dict/key[. = 'Tracks']" />
	</xsl:template>
</xsl:stylesheet>
