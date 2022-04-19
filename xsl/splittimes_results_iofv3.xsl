<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <!-- <link href="sidroidSimpleResults.css" rel="stylesheet" type="text/css"/> -->
        <title>Splittimes <xsl:value-of select="ResultList/Event/Name"/></title>
      </head>
      <body>
        <!-- Hlavička eventu -->
        <header>
          <!-- Název závodu -->
          <h1>Splittimes <xsl:value-of select="ResultList/Event/Name"/></h1>
          
          <!-- Datum závodu -->
          <h2><xsl:value-of select="ResultList/Event/StartTime/Date"/></h2>
        </header>
        
        <!-- Pruchod po kategoriích -->
        <xsl:for-each select="ResultList/ClassResult">
        <xsl:variable name = "numberOfControlsInCategory" select = "count(PersonResult/Result/SplitTime)"/>
        Počet kontrol <xsl:value-of select="$numberOfControlsInCategory"/>
          <section>
            <p class="cat-title">
              <span class="category"><xsl:value-of select="Class/Name"/></span>
              <xsl:choose>
                <!-- Délka, převýšení a počet kontrol -->
                <xsl:when test="(Course/Length) or (Course/Climb) or (Course/NumberOfControls &gt; 0)">
                  <span class="controls">
                    <xsl:if test="Course/Length">
                      <xsl:value-of select="format-number(Course/Length div 1000,'.0')"/>km
                    </xsl:if>
                    <xsl:if test="Course/Climb">
                      &#8593;<xsl:value-of select="Course/Climb"/>m
                    </xsl:if>
                    <xsl:if test="Course/NumberOfControls">
                      <xsl:value-of select="Course/NumberOfControls"/> Controls
                    </xsl:if>
                  </span>
                </xsl:when>
                
                <!-- Úplně prázdné -->
                <xsl:otherwise>
                  <span class="controls">
                    <xsl:text></xsl:text>
                  </span>
                </xsl:otherwise>
              </xsl:choose>
            </p>
            
            <!-- Pruchod po závodnících -->            
            <table>
              <xsl:for-each select="PersonResult">
                <tr>
                  <!-- Umístění -->
                  <td class='pos'>
                    <xsl:choose>
                      <xsl:when test="Result/Position">
                        <xsl:value-of select="Result/Position"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>-</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>
                  
                  <!-- Jméno závodníka -->
                  <td class='name'>
                    <xsl:value-of select="Person/Name/Given"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="Person/Name/Family"/>
                  </td>
                  
                  <!-- Klub závodníka -->
                  <td class='club'>
                    <xsl:choose>
                      <!-- SI Droid -->
                      <xsl:when test="Organisation/Name">
                        <xsl:value-of select="Organisation/Name"/>
                      </xsl:when>
                      
                      <!-- Quick Event -->
                      <xsl:when test="Organisation/ShortName">
                        <xsl:value-of select="Organisation/ShortName"/>
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
                      <xsl:when test="(Result/Time) and (Result/Status = 'OK')">
                        <xsl:variable name="seconds" select="Result/Time"/>
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
                          <xsl:when test="Result/Status = 'MissingPunch'">
                            <xsl:text>MP</xsl:text>
                          </xsl:when>
                          <xsl:when test="Result/Status = 'Disqualified'">
                            <xsl:text>DQ</xsl:text>
                          </xsl:when>
                          <xsl:when test="Result/Status = 'DidNotFinish'">
                            <xsl:text>DNF</xsl:text>
                          </xsl:when>
                          <xsl:when test="Result/Status = 'OverTime'">
                            <xsl:text>OT</xsl:text>
                          </xsl:when>
                          <xsl:when test="Result/Status = 'NotCompeting'">
                            <xsl:text>NC</xsl:text>
                          </xsl:when>
                          <xsl:when test="Result/Status = 'DidNotStart'">
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
                    <xsl:if test="Result/TimeBehind = 0 ">
                      <xsl:text></xsl:text>
                    </xsl:if>
                    
                    <!-- Zbytek se ztrátou -->
                    <xsl:if test="Result/TimeBehind &gt; 0">
                      <xsl:text>+</xsl:text>
                      <xsl:variable name="seconds" select="Result/TimeBehind"/>
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
                  
                  <!-- Časy na postupech -->                  
                  <xsl:for-each select="Result/SplitTime">
                    <td class='leg'>
                      <xsl:variable name="seconds" select="Time"/>
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
                    </td>
                  </xsl:for-each>
                  
                  <!-- Cílový čas -->
                  <td class='finish'>
                    <xsl:variable name="seconds" select="Result/Time"/>
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
                  </td>
                  
                </tr>
              </xsl:for-each>
            </table>
          </section>
        </xsl:for-each>
        
        <xsl:apply-templates select="ResultList"/> 

      </body>
    </html>
  </xsl:template>
  
  <!-- Rozlišení kdo vytvořil -->
  <xsl:template match="ResultList">
    <footer>
      <p>
        <xsl:choose>              
          <!-- QuickEvent -->
          <xsl:when test="./@creator = 'QuickEvent'">          
            Created <xsl:value-of select="./@createTime"/> with <a href='https://github.com/Quick-Event/quickbox'>
              <xsl:value-of select="./@creator"/></a> and transformed with SI Droid Live Results Service
          </xsl:when>
          
          <!-- SI-Droid -->
          <xsl:when test="contains(./@creator,'SI-Droid Event')">
            Created <xsl:value-of select="./@createTime"/> with <a href='https://play.google.com/store/apps/details?id=se.joja.sidroid.event.full'>
              <xsl:value-of select="./@creator"/></a> and transformed with SI Droid Live Results Service
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