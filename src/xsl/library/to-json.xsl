<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="xsl">
	<xsl:output encoding="UTF-8" method="text" omit-xml-declaration="yes" indent="no" />

	<xsl:import href="../to-json.xsl" />

	<xsl:template match="/">
		<xsl:result-document href="iTunes Library.json" method="text">
			<xsl:apply-templates select="plist/dict" />
		</xsl:result-document>
	</xsl:template>
</xsl:stylesheet>
