<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:seq="http://sequencemedia.net">
	<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />

	<xsl:variable name="tracks" select="/plist/dict/key[. = 'Tracks']/following-sibling::dict" />
	<xsl:variable name="playlists" select="/plist/dict/key[. = 'Playlists']/following-sibling::array/dict" />

	<xsl:function name="seq:get-file-path">
		<xsl:param name="playlist" />

		<xsl:variable name="parentId" select="$playlist/key[. = 'Parent Persistent ID']/following-sibling::string[1]/text()" />
		<xsl:variable name="name" select="$playlist/key[. = 'Name']/following-sibling::string[1]/text()" />

		<xsl:if test="string-length($parentId)">
			<xsl:value-of select="seq:get-file-path($playlists[
				key[. = 'Playlist Persistent ID']/following-sibling::string[1]/text() = $parentId
			])" />
			<xsl:text>/</xsl:text>
		</xsl:if>

		<!-- to do: normalise -->
		<xsl:value-of select="normalize-unicode($name, 'NFKD')" />
	</xsl:function>

	<xsl:function name="seq:get-playlist-path">
		<xsl:param name="parentId" />
		<xsl:param name="name" />
		<xsl:param name="position" />

		<xsl:variable name="filePath">
			<xsl:if test="string-length($parentId)">
				<xsl:value-of select="seq:get-file-path($playlists[
					key[. = 'Playlist Persistent ID']/following-sibling::string[1]/text() = $parentId
				])" />
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="fileName" select="normalize-unicode($name, 'NFKD')" />

		<xsl:text>iTunes Library/Playlists/</xsl:text>

		<xsl:if test="$filePath">
			<xsl:value-of select="$filePath" />
			<xsl:text>/</xsl:text>
		</xsl:if>

		<xsl:value-of select="$fileName" />

		<xsl:if test="number($position)">
			<xsl:text>&#32;(</xsl:text>
			<xsl:value-of select="number($position)" />
			<xsl:text>)</xsl:text>
		</xsl:if>

		<xsl:text>.m3u8</xsl:text>
	</xsl:function>

	<xsl:function name="seq:get-playlist-path">
		<xsl:param name="parentId" />
		<xsl:param name="name" />
		<xsl:value-of select="seq:get-playlist-path($parentId, $name, 0)" />
	</xsl:function>

	<xsl:template match="key[. = 'Playlists']">
		<xsl:variable
			name="playlists"
			select="following-sibling::array[1]/dict[
				key[. = 'Playlist Items'] and
				key[. = 'Playlist Items']/following-sibling::array[1]/* and
				not(key[. = 'Distinguished Kind']) and
				not(key[. = 'Smart Info']) and
				not(local-name(key[. = 'Folder']/following-sibling::*[1]) = 'true') and
				not(local-name(key[. = 'Visible']/following-sibling::*[1]) = 'false')
			]"
		/>

		<xsl:for-each select="$playlists">
			<xsl:variable name="parentId" select="key[. = 'Parent Persistent ID']/following-sibling::string[1]/text()" />
			<xsl:variable name="name" select="key[. = 'Name']/following-sibling::string[1]/text()" />

			<xsl:variable name="instances" select="$playlists[
				key[. = 'Parent Persistent ID']/following-sibling::string[1]/text() = $parentId and key[. = 'Name']/following-sibling::string[1]/text() = $name
			]" />

			<xsl:choose>
				<xsl:when test="count($instances) gt 1">
					<xsl:variable name="playlist" select="." />

					<xsl:for-each select="$instances">
						<xsl:if test=". = $playlist">
							<xsl:result-document href="{seq:get-playlist-path($parentId, $name, position())}" method="text">
								<xsl:apply-templates mode="playlist" select="array" />
							</xsl:result-document>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:result-document href="{seq:get-playlist-path($parentId, $name)}" method="text">
						<xsl:apply-templates mode="playlist" select="array" />
					</xsl:result-document>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="playlist" match="array">
		<xsl:text>#EXTM3U</xsl:text>
		<xsl:text>&#13;</xsl:text>

		<xsl:for-each select="dict/key[. = 'Track ID']">
			<xsl:variable name="trackId" select="following-sibling::integer[1]" />
			<xsl:apply-templates mode="playlist-track" select="$tracks[1]/key[. = $trackId]/following-sibling::dict[1]" />
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="playlist-track" match="dict">
		<xsl:variable name="totalTime" select="floor(number(key[. = 'Total Time']/following-sibling::integer[1]) div 1000)" />
		<xsl:variable name="location" select="key[. = 'Location']/following-sibling::string[1]/text()" />

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
		<xsl:value-of select="key[. = 'Album']/following-sibling::string[1]" />
		<xsl:text>&#32;-&#32;</xsl:text>
		<xsl:value-of select="key[. = 'Name']/following-sibling::string[1]" />
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
		<xsl:apply-templates select="plist/dict/key[. = 'Playlists']" />
	</xsl:template>
</xsl:stylesheet>
