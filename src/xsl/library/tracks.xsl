<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:seq="http://sequencemedia.net"
	xmlns:url-decoder="java:java.net.URLDecoder"
	exclude-result-prefixes="xsl seq url-decoder">
	<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />

	<xsl:param name="destination" />

	<xsl:variable name="tracks" select="/plist/dict/key[. = 'Tracks']/following-sibling::dict" />

	<xsl:function name="seq:normalize-for-path">
		<xsl:param name="s" />

		<xsl:value-of
			select="normalize-space(translate(translate(replace(normalize-unicode($s, 'NFD'), '[%\[\]*?]', '_'), '\/:', '___'), '&#x0300;&#x30c;&#x0301;&#x0308;&#x0313;&#x0314;&#x32c;&#x0342;&#x0345;', ''))"
		/>
	</xsl:function>

	<xsl:function name="seq:get-href-for-album">
		<xsl:param name="albumArtist" />
		<xsl:param name="album" />

		<xsl:variable name="filePath" select="seq:normalize-for-path($albumArtist)" />
		<xsl:variable name="fileName" select="seq:normalize-for-path($album)" />

		<xsl:choose>
			<xsl:when test="$destination">
				<xsl:value-of select="$destination" />
				<xsl:text>/Tracks/</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>iTunes Library/Tracks/</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="$filePath" />
		<xsl:text>/</xsl:text>
		<xsl:value-of select="$fileName" />
		<xsl:text>.m3u8</xsl:text>
	</xsl:function>

	<xsl:function name="seq:get-href-for-album">
		<xsl:param name="album" />

		<xsl:variable name="fileName" select="seq:normalize-for-path($album)" />

		<xsl:choose>
			<xsl:when test="$destination">
				<xsl:value-of select="$destination" />
				<xsl:text>/Tracks/Compilations/</xsl:text>
			</xsl:when>

			<xsl:otherwise>
				<xsl:text>iTunes Library/Tracks/Compilations/</xsl:text>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:value-of select="$fileName" />
		<xsl:text>.m3u8</xsl:text>
	</xsl:function>

	<xsl:template match="key[. = 'Tracks']">
		<!-- Albums: 'Album Artist' -->
		<xsl:for-each-group
			group-by="key[. = 'Album Artist']/following-sibling::*[1]/text()"
			select="following-sibling::dict[1]/dict[
				key[. = 'Album Artist']/following-sibling::*[1]/text() and
				key[. = 'Track Type']/following-sibling::*[1]/text() eq 'File' and
				key[. = 'Album'] and
				contains(lower-case(key[. = 'Kind']/following-sibling::*[1]/text()), 'audio') and
				not(local-name(key[. = 'Podcast']/following-sibling::*[1]) eq 'true') and
				(
					not(key[. = 'Compilation']) or not(local-name(key[. = 'Compilation']/following-sibling::*[1]) eq 'true')
				)
			]">
			<xsl:variable name="albumArtist" select="current-grouping-key()" />

			<xsl:for-each-group group-by="key[. = 'Album']/following-sibling::*[1]/text()" select="current-group()">
				<xsl:result-document href="{seq:get-href-for-album($albumArtist, current-grouping-key())}" method="text">
					<xsl:call-template name="album">
						<xsl:with-param name="current-group" select="current-group()" />
					</xsl:call-template>
				</xsl:result-document>
			</xsl:for-each-group>
		</xsl:for-each-group>

		<!-- Albums: 'Artist' not 'Album Artist' -->
		<xsl:for-each-group
			group-by="key[. = 'Artist']/following-sibling::*[1]/text()"
			select="following-sibling::dict[1]/dict[
				(
					not(key[. = 'Album Artist']/following-sibling::*[1]/text())
				) and
				key[. = 'Track Type']/following-sibling::*[1]/text() eq 'File' and
				key[. = 'Album'] and
				contains(lower-case(key[. = 'Kind']/following-sibling::*[1]/text()), 'audio') and
				not(local-name(key[. = 'Podcast']/following-sibling::*[1]) eq 'true') and
				(
					not(key[. = 'Compilation']) or not(local-name(key[. = 'Compilation']/following-sibling::*[1]) eq 'true')
				)
			]">
			<xsl:variable name="artist" select="current-grouping-key()" />

			<xsl:for-each-group group-by="key[. = 'Album']/following-sibling::*[1]/text()" select="current-group()">
				<xsl:result-document href="{seq:get-href-for-album($artist, current-grouping-key())}" method="text">
					<xsl:call-template name="album">
						<xsl:with-param name="current-group" select="current-group()" />
					</xsl:call-template>
				</xsl:result-document>
			</xsl:for-each-group>
		</xsl:for-each-group>

		<!-- Compilation albums -->
		<xsl:for-each-group
			group-by="key[. = 'Album']/following-sibling::*[1]/text()"
			select="following-sibling::dict[1]/dict[
				key[. = 'Track Type']/following-sibling::*[1]/text() eq 'File' and
				key[. = 'Album'] and
				contains(lower-case(key[. = 'Kind']/following-sibling::*[1]/text()), 'audio') and
				not(local-name(key[. = 'Podcast']/following-sibling::*[1]) eq 'true') and
				(
					key[. = 'Compilation'] and local-name(key[. = 'Compilation']/following-sibling::*[1]) eq 'true'
				)
			]">
			<xsl:result-document href="{seq:get-href-for-album(current-grouping-key())}" method="text">
				<xsl:call-template name="album">
					<xsl:with-param name="current-group" select="current-group()" />
				</xsl:call-template>
			</xsl:result-document>
		</xsl:for-each-group>
	</xsl:template>

	<!-- Album: #EXTM3U -->
	<xsl:template name="album">
		<xsl:param name="current-group" />

		<xsl:text>#EXTM3U</xsl:text>
		<xsl:text>&#13;</xsl:text>

		<xsl:for-each select="$current-group">
			<xsl:sort select="number(key[. = 'Disc Number']/following-sibling::*[1]/text())" />
			<xsl:sort select="number(key[. = 'Track Number']/following-sibling::*[1]/text())" />

			<xsl:apply-templates mode="album-track" select="." />
		</xsl:for-each>
	</xsl:template>

	<!-- Album track: #EXTINF -->
	<xsl:template mode="album-track" match="dict">
		<xsl:variable name="totalTime" select="floor(number(key[. = 'Total Time']/following-sibling::*[1]/text()) div 1000)" />
		<xsl:variable name="location" select="url-decoder:decode(replace(key[. = 'Location']/following-sibling::*[1]/text(), '[&#43;]', '%2b'))" />

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
		<xsl:value-of select="normalize-space(key[. = 'Name']/following-sibling::*[1]/text())" />
		<xsl:text>&#32;-&#32;</xsl:text>
		<xsl:value-of select="normalize-space(key[. = 'Artist']/following-sibling::*[1]/text())" />
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
