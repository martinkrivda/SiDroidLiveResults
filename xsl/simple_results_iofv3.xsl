<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
				xmlns:iof="http://www.orienteering.org/datastandard/3.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="utf-8" indent="yes"/>
	<xsl:template match="/">
		<html>
			<head>
				<meta charset="UTF-8"/>
				<meta name="description" content="Orienteering live results."/>
				<meta name="keywords" content="SI, droid, results, výsledky, online, live, ob, orienteering, ol"/>
				<meta name="author" content="Lukáš Kettner"/>
				<meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
				<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
				<meta http-equiv="refresh" content="60"/>
				<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"/>
				<meta http-equiv="Pragma" content="no-cache"/>
				<meta http-equiv="Expires" content="0"/>
				<link href="../xsl/sidroidSimpleResults.css" rel="stylesheet" type="text/css"/>
				<title>Results <xsl:value-of select="iof:ResultList/iof:Event/iof:Name"/></title>
			</head>
			<body>
				<!-- Hlavička eventu -->
				<header>
					<!-- Název závodu -->
					<h1>Results <xsl:value-of select="iof:ResultList/iof:Event/iof:Name"/>
					</h1>
					<!-- Datum závodu -->
					<h2>
						<xsl:value-of select="iof:ResultList/iof:Event/iof:StartTime/iof:Date"/>
					</h2>
					<!-- <h2>2022-03-30</h2> -->
				</header>
				<!-- Po kategoriích -->
				<xsl:for-each select="iof:ResultList/iof:ClassResult">
					<section>
						<p class="cat-title">
							<span class="category">
								<xsl:value-of select="iof:Class/iof:Name"/>
							</span>
							<xsl:choose>
								<!-- Délka, převýšení a počet kontrol -->
								<xsl:when test="(iof:Course/iof:Length) or (iof:Course/iof:Climb) or (iof:Course/iof:NumberOfControls &gt; 0)">
									<span class="controls">
										<xsl:if test="iof:Course/iof:Length">
											<xsl:value-of select="format-number(iof:Course/iof:Length div 1000,'.0')"/>km
						</xsl:if>
										<xsl:if test="iof:Course/iof:Climb">
						  &#8593;<xsl:value-of select="iof:Course/iof:Climb"/>m
						</xsl:if>
										<xsl:if test="iof:Course/iof:NumberOfControls">
											<xsl:value-of select="iof:Course/iof:NumberOfControls"/> Controls
						</xsl:if>
									</span>
								</xsl:when>
								<!-- Úplně prázdné -->
								<xsl:otherwise>
									<span class="controls">
										<xsl:text/>
									</span>
								</xsl:otherwise>
							</xsl:choose>
						</p>
						<!-- Po závodnících -->
						<table>
							<xsl:for-each select="iof:PersonResult">
								<tr>
									<!-- Umístění -->
									<td class='pos'>
										<xsl:choose>
											<xsl:when test="iof:Result/iof:Position">
												<xsl:value-of select="iof:Result/iof:Position"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>-</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</td>
									<!-- Jméno závodníka -->
									<td class='name'>
										<xsl:value-of select="iof:Person/iof:Name/iof:Given"/>
										<xsl:text> </xsl:text>
										<xsl:value-of select="iof:Person/iof:Name/iof:Family"/>
									</td>
									<!-- Klub závodníka -->
									<td class='club'>
										<xsl:choose>
											<!-- SI Droid -->
											<xsl:when test="iof:Organisation/iof:Name">
												<xsl:value-of select="iof:Organisation/iof:Name"/>
											</xsl:when>
											<!-- Quick Event -->
											<xsl:when test="iof:Organisation/iof:ShortName">
												<xsl:value-of select="iof:Organisation/iof:ShortName"/>
											</xsl:when>
											<!-- Zbytek -->
											<xsl:otherwise>
												<xsl:text>-</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</td>
									<!-- Čas závodníka -->
									<!--
						   <xs:enumeration value="OK"/>
						   <xs:enumeration value="Finished"/>
						   <xs:enumeration value="MissingPunch"/>
						   <xs:enumeration value="Disqualified"/>
						   <xs:enumeration value="DidNotFinish"/>
						   <xs:enumeration value="Active"/>
						   <xs:enumeration value="Inactive"/>
						   <xs:enumeration value="OverTime"/>
						   <xs:enumeration value="SportingWithdrawal"/>
						   <xs:enumeration value="NotCompeting"/>
						   <xs:enumeration value="Moved"/>
						   <xs:enumeration value="MovedUp"/>
						   <xs:enumeration value="DidNotStart"/>
						   <xs:enumeration value="DidNotEnter"/>
						   <xs:enumeration value="Cancelled"/>
					  -->
									<td class='time'>
										<xsl:choose>
											<!-- Pokud má čas -->
											<xsl:when test="(iof:Result/iof:Time) and (iof:Result/iof:Status = 'OK')">
												<xsl:variable name="seconds" select="iof:Result/iof:Time"/>
												<xsl:choose>
													<xsl:when test="floor($seconds div 3600) &gt; 0">
														<xsl:value-of select="format-number(floor($seconds div 3600), '0')"/>
														<xsl:value-of select="format-number(floor($seconds div 60) mod 60, ':00')"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="format-number(floor($seconds div 60) mod 60, '00')"/>
													</xsl:otherwise>
												</xsl:choose>
												<xsl:value-of select="format-number($seconds mod 60, ':00')"/>
											</xsl:when>
											<xsl:otherwise>
												<!-- Proč je disk -->
												<xsl:choose>
													<xsl:when test="iof:Result/iof:Status = 'MissingPunch'">
														<xsl:text>MP</xsl:text>
													</xsl:when>
													<xsl:when test="iof:Result/iof:Status = 'Disqualified'">
														<xsl:text>DQ</xsl:text>
													</xsl:when>
													<xsl:when test="iof:Result/iof:Status = 'DidNotFinish'">
														<xsl:text>DNF</xsl:text>
													</xsl:when>
													<xsl:when test="iof:Result/iof:Status = 'OverTime'">
														<xsl:text>OT</xsl:text>
													</xsl:when>
													<xsl:when test="iof:Result/iof:Status = 'NotCompeting'">
														<xsl:text>NC</xsl:text>
													</xsl:when>
													<xsl:when test="iof:Result/iof:Status = 'DidNotStart'">
														<xsl:text>DNS</xsl:text>
													</xsl:when>
													<xsl:otherwise>
														<xsl:text>Not implemented</xsl:text>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:otherwise>
										</xsl:choose>
									</td>
									<!-- Ztráta -->
									<td class='loss'>
										<!-- Vítězové bez nulové ztráty -->
										<xsl:if test="iof:Result/iof:TimeBehind = 0 ">
											<xsl:text/>
										</xsl:if>
										<!-- Zbytek se ztrátou -->
										<xsl:if test="iof:Result/iof:TimeBehind &gt; 0">
											<xsl:text>+</xsl:text>
											<!-- <xsl:value-of select="Result/TimeBehind"/> -->
											<xsl:variable name="seconds" select="iof:Result/iof:TimeBehind"/>
											<xsl:choose>
												<xsl:when test="floor($seconds div 3600) &gt; 0">
													<xsl:value-of select="format-number(floor($seconds div 3600), '0')"/>
													<xsl:value-of select="format-number(floor($seconds div 60) mod 60, ':00')"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="format-number(floor($seconds div 60) mod 60, '0')"/>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:value-of select="format-number($seconds mod 60, ':00')"/>
										</xsl:if>
									</td>
									<!-- Číslo čipu -->
									<td class='card'>
										<xsl:value-of select="iof:Result/iof:ControlCard"/>
									</td>
								</tr>
							</xsl:for-each>
						</table>
					</section>
				</xsl:for-each>
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>
	<!-- Rozlišení kdo vytvořil -->
	<xsl:template match="iof:ResultList">
		<footer>
			<p>
				<xsl:choose>
					<!-- QuickEvent -->
					<xsl:when test="./@creator = 'QuickEvent'">          
				Created <xsl:value-of select="./@createTime"/> with <a href='https://github.com/Quick-Event/quickbox'>
							<xsl:value-of select="./@creator"/>
						</a> and transformed with SI Droid Live Results Service
			  </xsl:when>
					<!-- SI-Droid -->
					<xsl:when test="contains(./@creator,'SI-Droid Event')">
				Created <xsl:value-of select="./@createTime"/> with <a href='https://play.google.com/store/apps/details?id=se.joja.sidroid.event.full'>
							<xsl:value-of select="./@creator"/>
						</a> and transformed with SI Droid Live Results Service
			  </xsl:when>
					<!-- Jiný -->
					<xsl:when test="./@creator">
				with <xsl:value-of select="./@creator"/> and transformed with SI Droid Live Results Service
			  </xsl:when>
					<xsl:otherwise>
				(atribute Creator not defined)    
			  </xsl:otherwise>
				</xsl:choose>
			</p>
		</footer>
	</xsl:template>
</xsl:stylesheet>