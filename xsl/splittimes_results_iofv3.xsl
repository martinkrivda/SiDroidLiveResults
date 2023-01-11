<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:iof="http://www.orienteering.org/datastandard/3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="utf-8" indent="yes"/>
  <xsl:template match="/">
    <html>
      <head>
        <meta charset="UTF-8"/>
        <meta name="description" content="Orienteering live splittimes."/>
        <meta name="keywords" content="SI, droid, results, výsledky, mezičasy, splittimes, online, live, ob, orienteering, ol"/>
        <meta name="author" content="Lukáš Kettner"/>
        <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="refresh" content="60"/>
				<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"/>
				<meta http-equiv="Pragma" content="no-cache"/>
        <meta http-equiv="Expires" content="0"/>
        <link href="../xsl/sidroidSplittimes.css" rel="stylesheet" type="text/css"/>
        <title>Splittimes <xsl:value-of select="iof:ResultList/iof:Event/iof:Name"/></title>
      </head>
      <body>
        <!-- Hlavička eventu -->
        <header>
          <!-- Název závodu -->
          <h1>Splittimes <xsl:value-of select="iof:ResultList/iof:Event/iof:Name"/></h1>
          
          <!-- Datum závodu -->
          <h2><xsl:value-of select="iof:ResultList/iof:Event/iof:StartTime/iof:Date"/></h2>
        </header>        
        
        <!-- Pruchod po kategoriích -->
        <xsl:for-each select="iof:ResultList/iof:ClassResult">
          <section>
            <p class="cat-title">
              <span class="category"><xsl:value-of select="iof:Class/iof:Name"/></span>
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
                    <xsl:text></xsl:text>
                  </span>
                </xsl:otherwise>
              </xsl:choose>
            </p>
            
            <!-- Pruchod po závodnících -->            
            <table>
              
              <xsl:variable name="runner_positions" select="iof:PersonResult/iof:Result/iof:Position"/>
              <xsl:for-each select="iof:PersonResult">

                <!-- Hlavičky sloupců -->
                <!-- Nadpisy -->
                <xsl:if test="position() = 1 ">
                  <tr class='split-header'>
                    <td class='pos'>Um.</td>
                    <td class='name'>Jméno</td>
                    <!-- <td class='club'>Klub</td> -->
                    <td class='time'>Čas</td>
                    <td class='loss'>Ztráta</td>
                    <xsl:for-each select="iof:Result/iof:SplitTime">
                      <td class='control-name'>celk. mezi.</td>
                    </xsl:for-each>
                    <td class='control-name'>celk. mezi.</td>
                    <td class='name'>Jméno</td>
                  </tr>
                  

                  <!-- Pořadová čísla a kódy -->
                  <tr class='split-header'>
                    <td class='empty'></td>
                    <td class='club'>Klub</td>
                    <!-- <td class='empty'></td> -->
                    <td class='empty'></td>
                    <td class='empty'></td>
                    <xsl:for-each select="iof:Result/iof:SplitTime">
                      <td class='control-code'>
                      <xsl:value-of select="position()"/> (<xsl:value-of select="iof:ControlCode"/>)
                      </td>
                    </xsl:for-each>
                    <td class='control-code'>Cíl</td>
                    <td class='personid'>Reg. číslo</td>
                  </tr>
                </xsl:if>

                <tr class='split'>    
                  
                  <!-- Umístění -->
                  <xsl:variable name="current_position" select="position()"/>
                  <td class='pos'>
                    <xsl:choose>
                      <xsl:when test="iof:Result/iof:Position">
                        <!-- Pořešení totožného pořadí -->
                        <xsl:choose>
                          <xsl:when test="position() = 1">
                            <xsl:value-of select="iof:Result/iof:Position"/>
                          </xsl:when>
                          <xsl:when test="position() > 1 and $runner_positions[$current_position -1] = $runner_positions[$current_position]">
                            <xsl:text>=</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="iof:Result/iof:Position"/>
                          </xsl:otherwise>
                        </xsl:choose>
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
                      <xsl:text></xsl:text>
                    </xsl:if>
                    
                    <!-- Zbytek se ztrátou -->
                    <xsl:if test="iof:Result/iof:TimeBehind &gt; 0">
                      <xsl:text>+</xsl:text>
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
                  
                  <!-- Celkový čas na postupech -->                  
                  <xsl:for-each select="iof:Result/iof:SplitTime">
                    
                    <!-- Ražení ok -->
                    <xsl:if test="not(./@status)">
                      <td class='split'>
                        <xsl:variable name="seconds" select="iof:Time"/>
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
                    </xsl:if>
                    
                    <!-- Chybí ražení -->
                    <xsl:if test="./@status or ./@status = 'Missing'">
                      <td class='split'>
                        <xsl:text>---</xsl:text>
                      </td>
                    </xsl:if>
                    
                  </xsl:for-each>
                  
                  
                  <!-- Cílový čas -->
                  
                  <!-- Ražení ok -->
                  <xsl:variable name="seconds" select="iof:Result/iof:Time"/>
                  <xsl:if test="iof:Result/iof:Status = 'OK'">
                    <td class='finish'>
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
                  </xsl:if>
                  
                  <!-- Chybí ražení -->
                  <xsl:if test="iof:Result/iof:Status != 'OK'">
                    <td class='finish'>
                      <xsl:text>---</xsl:text>
                    </td>
                  </xsl:if>
                  
                  <!-- Jméno závodníka i na konec -->
                  <td class='name'>
                    <xsl:value-of select="iof:Person/iof:Name/iof:Given"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="iof:Person/iof:Name/iof:Family"/>
                  </td>            
                </tr>
                
                <!-- Časy na postupech -->                  
                <tr class='leg'>
                  <td class='empty'></td>
                  <!-- Klub závodníka -->
                  <td class='club'>
                    <xsl:choose>
                      <!-- Jméno -->
                      <xsl:when test="iof:Organisation/iof:Name">
                        <xsl:value-of select="iof:Organisation/iof:Name"/>
                      </xsl:when>
                      
                      <!-- Případně zkratka -->
                      <xsl:otherwise>
                        <xsl:value-of select="iof:Organisation/iof:ShortName"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>
                  <td class='empty'></td>
                  <td class='empty'></td>
                  
                  <!-- Čas postupu -->
                  <!-- <xsl:variable name="splittimes" select="Result/SplitTime/Time"/> -->
                  <xsl:variable name="splittimes" select="iof:Result/iof:SplitTime"/>
                  <xsl:variable name="finishtime" select="iof:Result/iof:Time"/>
                  <xsl:variable name="competitorStatus" select="iof:Result/iof:Status"/>
                  <xsl:for-each select="iof:Result/iof:SplitTime">
                    <xsl:variable name="current_splittime" select="iof:Time"/>
                    <xsl:variable name="current_pos" select="position()"/>
                    
                    <!-- První postup -->
                    <xsl:if test="$current_pos = 1">
                      
                      <!-- Ražení ok -->
                      <xsl:if test="$current_splittime and $current_splittime != 0">
                        <td class='leg'>
                          <!-- <xsl:value-of select="$current_splittime" /> -->
                          <xsl:choose>
                            <xsl:when test="floor($current_splittime div 3600) &gt; 0">
                              <xsl:value-of select="format-number(floor($current_splittime div 3600), '0')"/>
                              <xsl:value-of select="format-number(floor($current_splittime div 60) mod 60, ':00')"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="format-number(floor($current_splittime div 60) mod 60, '00')"/>
                            </xsl:otherwise>
                          </xsl:choose>
                          <xsl:value-of select="format-number($current_splittime mod 60, ':00')"/>
                        </td>
                      </xsl:if>
                      
                      <!-- Chybí ražení -->
                      <xsl:if test="./@status='Missing'">
                        <td class='leg'>
                          <xsl:text>---</xsl:text>
                        </td>
                      </xsl:if>
                    </xsl:if>
                    
                    <!-- Mezipostupy -->
                    <xsl:if test="$current_pos &lt;= last() and $current_pos &gt; 1">
                      <xsl:if test="$current_splittime and $current_splittime != 0">
                        
                        <!-- Ražení ok -->
                        <xsl:if test="$splittimes[position() = $current_pos - 1]/iof:Time and $splittimes[position() = $current_pos - 1]/iof:Time != 0">
                          <td class='leg'>
                            <xsl:variable name="leg" select="$current_splittime - $splittimes[position() = $current_pos - 1]/iof:Time"/>
                            <xsl:choose>
                              <xsl:when test="floor($leg div 3600) &gt; 0">
                                <xsl:value-of select="format-number(floor($leg div 3600), '0')"/>
                                <xsl:value-of select="format-number(floor($leg div 60) mod 60, ':00')"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="format-number(floor($leg div 60) mod 60, '00')"/>
                              </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="format-number($leg mod 60, ':00')"/>
                          </td>
                        </xsl:if>
                        
                        <!-- Chybí předchozí mezičas, nelze dopočítat -->
                        <xsl:if test="not($splittimes[position() = $current_pos - 1]/iof:Time) or $splittimes[position() = $current_pos - 1]/iof:Time = 0">
                          <td class='leg'>
                            <xsl:text>---</xsl:text>
                          </td>
                        </xsl:if>
                      </xsl:if>
                      
                      <!-- Chybí ražení -->
                      <xsl:if test="./@status='Missing'">
                        <td class='leg'>
                          <xsl:text>---</xsl:text>
                        </td>
                      </xsl:if>
                      
                    </xsl:if>
                    
                    <!-- Čas od sběrky do cíle -->
                    <xsl:if test="$current_pos != 1 and $current_pos &gt;= last()">
                      
                      <!-- Ražení ok = cajk celkový status -->
                      <xsl:if test="$competitorStatus = 'OK' and $finishtime">
                        <td class='leg'>
                          <xsl:variable name="leg" select="$finishtime - $splittimes[last()]/iof:Time"/>
                          <!-- <xsl:value-of select="$finishtime - $splittimes[last()]/Time" /> -->
                          <xsl:choose>
                            <xsl:when test="floor($leg div 3600) &gt; 0">
                              <xsl:value-of select="format-number(floor($leg div 3600), '0')"/>
                              <xsl:value-of select="format-number(floor($leg div 60) mod 60, ':00')"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="format-number(floor($leg div 60) mod 60, '00')"/>
                            </xsl:otherwise>
                          </xsl:choose>
                          <xsl:value-of select="format-number($leg mod 60, ':00')"/>
                        </td>
                      </xsl:if>
                      
                      <!-- Chybí ražení -->
                      <xsl:if test="$competitorStatus != 'OK'">
                        <td class='leg'>
                          <xsl:text>---</xsl:text>
                        </td>
                      </xsl:if>
                      
                    </xsl:if>                    
                  </xsl:for-each>
                  
                  <!-- Registračka i na závěr -->
                  <td class='personid'>
                    <xsl:value-of select="iof:Person/iof:Id"/>
                  </td>
                  
                </tr>
              </xsl:for-each>
            </table>
          </section>
        </xsl:for-each>
        
        <xsl:apply-templates select="iof:ResultList"/>
        
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
            unknown creator(attribute not defined)    
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </footer> 
  </xsl:template>
</xsl:stylesheet>