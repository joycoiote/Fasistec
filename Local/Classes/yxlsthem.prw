#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} yxlsthem
Cria thema do FExcel
@author Saulo Gomes Martins
@since 10/12/2019
@version 1.0
@type function
/*/
user function yxlsthem()
	Local cRet := ""
	cRet += PlainH_1()
	cRet += PlainH_2()
	cRet += PlainH_3()
	cRet += PlainH_4()
	cRet += PlainH_5()
	cRet += PlainH_6()
	cRet += PlainH_7()
	cRet += PlainH_8()
	cRet += PlainH_9()
Return(cRet)


Static Function PlainH_1()

	Local cRet := ""
	cRet += '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + CHR(13)+CHR(10)
	cRet += '<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Tema do Office">' + CHR(13)+CHR(10)
	cRet += "	<a:themeElements>" + CHR(13)+CHR(10)
	cRet += '		<a:clrScheme name="Escritório">' + CHR(13)+CHR(10)
	cRet += "			<a:dk1>" + CHR(13)+CHR(10)
	cRet += '				<a:sysClr val="windowText" lastClr="000000"/>' + CHR(13)+CHR(10)
	cRet += "			</a:dk1>" + CHR(13)+CHR(10)
	cRet += "			<a:lt1>" + CHR(13)+CHR(10)
	cRet += '				<a:sysClr val="window" lastClr="FFFFFF"/>' + CHR(13)+CHR(10)
	cRet += "			</a:lt1>" + CHR(13)+CHR(10)
	cRet += "			<a:dk2>" + CHR(13)+CHR(10)
	cRet += '				<a:srgbClr val="1F497D"/>' + CHR(13)+CHR(10)
	cRet += "			</a:dk2>" + CHR(13)+CHR(10)
	cRet += "			<a:lt2>" + CHR(13)+CHR(10)
	cRet += '				<a:srgbClr val="EEECE1"/>' + CHR(13)+CHR(10)
	cRet += "			</a:lt2>" + CHR(13)+CHR(10)
	cRet += "			<a:accent1>" + CHR(13)+CHR(10)
	cRet += '				<a:srgbClr val="4F81BD"/>' + CHR(13)+CHR(10)
	cRet += "			</a:accent1>" + CHR(13)+CHR(10)
	cRet += "			<a:accent2>" + CHR(13)+CHR(10)
	cRet += '				<a:srgbClr val="C0504D"/>' + CHR(13)+CHR(10)
	cRet += "			</a:accent2>" + CHR(13)+CHR(10)
	cRet += "			<a:accent3>" + CHR(13)+CHR(10)
	cRet += '				<a:srgbClr val="9BBB59"/>' + CHR(13)+CHR(10)
	cRet += "			</a:accent3>" + CHR(13)+CHR(10)
	cRet += "			<a:accent4>" + CHR(13)+CHR(10)
	cRet += '				<a:srgbClr val="8064A2"/>' + CHR(13)+CHR(10)
	cRet += "			</a:accent4>" + CHR(13)+CHR(10)
	cRet += "			<a:accent5>" + CHR(13)+CHR(10)
	cRet += '				<a:srgbClr val="4BACC6"/>' + CHR(13)+CHR(10)
	cRet += "			</a:accent5>" + CHR(13)+CHR(10)
Return(cRet)


Static Function PlainH_2()
	Local cRet := ""
	cRet += "			<a:accent6>" + CHR(13)+CHR(10)
	cRet += '				<a:srgbClr val="F79646"/>' + CHR(13)+CHR(10)
	cRet += "			</a:accent6>" + CHR(13)+CHR(10)
	cRet += "			<a:hlink>" + CHR(13)+CHR(10)
	cRet += '				<a:srgbClr val="0000FF"/>' + CHR(13)+CHR(10)
	cRet += "			</a:hlink>" + CHR(13)+CHR(10)
	cRet += "			<a:folHlink>" + CHR(13)+CHR(10)
	cRet += '				<a:srgbClr val="800080"/>' + CHR(13)+CHR(10)
	cRet += "			</a:folHlink>" + CHR(13)+CHR(10)
	cRet += "		</a:clrScheme>" + CHR(13)+CHR(10)
	cRet += '		<a:fontScheme name="Escritório">' + CHR(13)+CHR(10)
	cRet += "			<a:majorFont>" + CHR(13)+CHR(10)
	cRet += '				<a:latin typeface="Cambria"/>' + CHR(13)+CHR(10)
	cRet += '				<a:ea typeface=""/>' + CHR(13)+CHR(10)
	cRet += '				<a:cs typeface=""/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Arab" typeface="Times New Roman"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Hebr" typeface="Times New Roman"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Thai" typeface="Tahoma"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Ethi" typeface="Nyala"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Beng" typeface="Vrinda"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Gujr" typeface="Shruti"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Khmr" typeface="MoolBoran"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Knda" typeface="Tunga"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Guru" typeface="Raavi"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Cans" typeface="Euphemia"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Cher" typeface="Plantagenet Cherokee"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Yiii" typeface="Microsoft Yi Baiti"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Tibt" typeface="Microsoft Himalaya"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Thaa" typeface="MV Boli"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Deva" typeface="Mangal"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Telu" typeface="Gautami"/>' + CHR(13)+CHR(10)
Return(cRet)
Static Function PlainH_3()
	Local cRet := ""
	cRet += '				<a:font script="Taml" typeface="Latha"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Syrc" typeface="Estrangelo Edessa"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Orya" typeface="Kalinga"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Mlym" typeface="Kartika"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Laoo" typeface="DokChampa"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Sinh" typeface="Iskoola Pota"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Mong" typeface="Mongolian Baiti"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Viet" typeface="Times New Roman"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Uigh" typeface="Microsoft Uighur"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Geor" typeface="Sylfaen"/>' + CHR(13)+CHR(10)
	cRet += "			</a:majorFont>" + CHR(13)+CHR(10)
	cRet += "			<a:minorFont>" + CHR(13)+CHR(10)
	cRet += '				<a:latin typeface="Calibri"/>' + CHR(13)+CHR(10)
	cRet += '				<a:ea typeface=""/>' + CHR(13)+CHR(10)
	cRet += '				<a:cs typeface=""/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Arab" typeface="Arial"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Hebr" typeface="Arial"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Thai" typeface="Tahoma"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Ethi" typeface="Nyala"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Beng" typeface="Vrinda"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Gujr" typeface="Shruti"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Khmr" typeface="DaunPenh"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Knda" typeface="Tunga"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Guru" typeface="Raavi"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Cans" typeface="Euphemia"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Cher" typeface="Plantagenet Cherokee"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Yiii" typeface="Microsoft Yi Baiti"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Tibt" typeface="Microsoft Himalaya"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Thaa" typeface="MV Boli"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Deva" typeface="Mangal"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Telu" typeface="Gautami"/>' + CHR(13)+CHR(10)
Return(cRet)
Static Function PlainH_4()
	Local cRet := ""
	cRet += '				<a:font script="Taml" typeface="Latha"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Syrc" typeface="Estrangelo Edessa"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Orya" typeface="Kalinga"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Mlym" typeface="Kartika"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Laoo" typeface="DokChampa"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Sinh" typeface="Iskoola Pota"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Mong" typeface="Mongolian Baiti"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Viet" typeface="Arial"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Uigh" typeface="Microsoft Uighur"/>' + CHR(13)+CHR(10)
	cRet += '				<a:font script="Geor" typeface="Sylfaen"/>' + CHR(13)+CHR(10)
	cRet += "			</a:minorFont>" + CHR(13)+CHR(10)
	cRet += "		</a:fontScheme>" + CHR(13)+CHR(10)
	cRet += '		<a:fmtScheme name="Escritório">' + CHR(13)+CHR(10)
	cRet += "			<a:fillStyleLst>" + CHR(13)+CHR(10)
	cRet += "				<a:solidFill>" + CHR(13)+CHR(10)
	cRet += '					<a:schemeClr val="phClr"/>' + CHR(13)+CHR(10)
	cRet += "				</a:solidFill>" + CHR(13)+CHR(10)
	cRet += '				<a:gradFill rotWithShape="1">' + CHR(13)+CHR(10)
	cRet += "					<a:gsLst>" + CHR(13)+CHR(10)
	cRet += '						<a:gs pos="0">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:tint val="50000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="300000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
	cRet += '						<a:gs pos="35000">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:tint val="37000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="300000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
Return(cRet)
Static Function PlainH_5()
	Local cRet := ""
	cRet += '						<a:gs pos="100000">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:tint val="15000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="350000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
	cRet += "					</a:gsLst>" + CHR(13)+CHR(10)
	cRet += '					<a:lin ang="16200000" scaled="1"/>' + CHR(13)+CHR(10)
	cRet += "				</a:gradFill>" + CHR(13)+CHR(10)
	cRet += '				<a:gradFill rotWithShape="1">' + CHR(13)+CHR(10)
	cRet += "					<a:gsLst>" + CHR(13)+CHR(10)
	cRet += '						<a:gs pos="0">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:shade val="51000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="130000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
	cRet += '						<a:gs pos="80000">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:shade val="93000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="130000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
	cRet += '						<a:gs pos="100000">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:shade val="94000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="135000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
	cRet += "					</a:gsLst>" + CHR(13)+CHR(10)
	cRet += '					<a:lin ang="16200000" scaled="0"/>' + CHR(13)+CHR(10)
Return(cRet)
Static Function PlainH_6()
	Local cRet := ""
	cRet += "				</a:gradFill>" + CHR(13)+CHR(10)
	cRet += "			</a:fillStyleLst>" + CHR(13)+CHR(10)
	cRet += "			<a:lnStyleLst>" + CHR(13)+CHR(10)
	cRet += '				<a:ln w="9525" cap="flat" cmpd="sng" algn="ctr">' + CHR(13)+CHR(10)
	cRet += "					<a:solidFill>" + CHR(13)+CHR(10)
	cRet += '						<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '							<a:shade val="95000"/>' + CHR(13)+CHR(10)
	cRet += '							<a:satMod val="105000"/>' + CHR(13)+CHR(10)
	cRet += "						</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "					</a:solidFill>" + CHR(13)+CHR(10)
	cRet += '					<a:prstDash val="solid"/>' + CHR(13)+CHR(10)
	cRet += "				</a:ln>" + CHR(13)+CHR(10)
	cRet += '				<a:ln w="25400" cap="flat" cmpd="sng" algn="ctr">' + CHR(13)+CHR(10)
	cRet += "					<a:solidFill>" + CHR(13)+CHR(10)
	cRet += '						<a:schemeClr val="phClr"/>' + CHR(13)+CHR(10)
	cRet += "					</a:solidFill>" + CHR(13)+CHR(10)
	cRet += '					<a:prstDash val="solid"/>' + CHR(13)+CHR(10)
	cRet += "				</a:ln>" + CHR(13)+CHR(10)
	cRet += '				<a:ln w="38100" cap="flat" cmpd="sng" algn="ctr">' + CHR(13)+CHR(10)
	cRet += "					<a:solidFill>" + CHR(13)+CHR(10)
	cRet += '						<a:schemeClr val="phClr"/>' + CHR(13)+CHR(10)
	cRet += "					</a:solidFill>" + CHR(13)+CHR(10)
	cRet += '					<a:prstDash val="solid"/>' + CHR(13)+CHR(10)
	cRet += "				</a:ln>" + CHR(13)+CHR(10)
	cRet += "			</a:lnStyleLst>" + CHR(13)+CHR(10)
	cRet += "			<a:effectStyleLst>" + CHR(13)+CHR(10)
	cRet += "				<a:effectStyle>" + CHR(13)+CHR(10)
	cRet += "					<a:effectLst>" + CHR(13)+CHR(10)
	cRet += '						<a:outerShdw blurRad="40000" dist="20000" dir="5400000" rotWithShape="0">' + CHR(13)+CHR(10)
	cRet += '							<a:srgbClr val="000000">' + CHR(13)+CHR(10)
	cRet += '								<a:alpha val="38000"/>' + CHR(13)+CHR(10)
Return(cRet)
Static Function PlainH_7()
	Local cRet := ""
	cRet += "							</a:srgbClr>" + CHR(13)+CHR(10)
	cRet += "						</a:outerShdw>" + CHR(13)+CHR(10)
	cRet += "					</a:effectLst>" + CHR(13)+CHR(10)
	cRet += "				</a:effectStyle>" + CHR(13)+CHR(10)
	cRet += "				<a:effectStyle>" + CHR(13)+CHR(10)
	cRet += "					<a:effectLst>" + CHR(13)+CHR(10)
	cRet += '						<a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0">' + CHR(13)+CHR(10)
	cRet += '							<a:srgbClr val="000000">' + CHR(13)+CHR(10)
	cRet += '								<a:alpha val="35000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:srgbClr>" + CHR(13)+CHR(10)
	cRet += "						</a:outerShdw>" + CHR(13)+CHR(10)
	cRet += "					</a:effectLst>" + CHR(13)+CHR(10)
	cRet += "				</a:effectStyle>" + CHR(13)+CHR(10)
	cRet += "				<a:effectStyle>" + CHR(13)+CHR(10)
	cRet += "					<a:effectLst>" + CHR(13)+CHR(10)
	cRet += '						<a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0">' + CHR(13)+CHR(10)
	cRet += '							<a:srgbClr val="000000">' + CHR(13)+CHR(10)
	cRet += '								<a:alpha val="35000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:srgbClr>" + CHR(13)+CHR(10)
	cRet += "						</a:outerShdw>" + CHR(13)+CHR(10)
	cRet += "					</a:effectLst>" + CHR(13)+CHR(10)
	cRet += "					<a:scene3d>" + CHR(13)+CHR(10)
	cRet += '						<a:camera prst="orthographicFront">' + CHR(13)+CHR(10)
	cRet += '							<a:rot lat="0" lon="0" rev="0"/>' + CHR(13)+CHR(10)
	cRet += "						</a:camera>" + CHR(13)+CHR(10)
	cRet += '						<a:lightRig rig="threePt" dir="t">' + CHR(13)+CHR(10)
	cRet += '							<a:rot lat="0" lon="0" rev="1200000"/>' + CHR(13)+CHR(10)
	cRet += "						</a:lightRig>" + CHR(13)+CHR(10)
	cRet += "					</a:scene3d>" + CHR(13)+CHR(10)
	cRet += "					<a:sp3d>" + CHR(13)+CHR(10)
	cRet += '						<a:bevelT w="63500" h="25400"/>' + CHR(13)+CHR(10)
Return(cRet)
Static Function PlainH_8()
	Local cRet := ""
	cRet += "					</a:sp3d>" + CHR(13)+CHR(10)
	cRet += "				</a:effectStyle>" + CHR(13)+CHR(10)
	cRet += "			</a:effectStyleLst>" + CHR(13)+CHR(10)
	cRet += "			<a:bgFillStyleLst>" + CHR(13)+CHR(10)
	cRet += "				<a:solidFill>" + CHR(13)+CHR(10)
	cRet += '					<a:schemeClr val="phClr"/>' + CHR(13)+CHR(10)
	cRet += "				</a:solidFill>" + CHR(13)+CHR(10)
	cRet += '				<a:gradFill rotWithShape="1">' + CHR(13)+CHR(10)
	cRet += "					<a:gsLst>" + CHR(13)+CHR(10)
	cRet += '						<a:gs pos="0">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:tint val="40000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="350000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
	cRet += '						<a:gs pos="40000">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:tint val="45000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:shade val="99000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="350000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
	cRet += '						<a:gs pos="100000">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:shade val="20000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="255000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
	cRet += "					</a:gsLst>" + CHR(13)+CHR(10)
	cRet += '					<a:path path="circle">' + CHR(13)+CHR(10)
	cRet += '						<a:fillToRect l="50000" t="-80000" r="50000" b="180000"/>' + CHR(13)+CHR(10)
Return(cRet)
Static Function PlainH_9()
	Local cRet := ""
	cRet += "					</a:path>" + CHR(13)+CHR(10)
	cRet += "				</a:gradFill>" + CHR(13)+CHR(10)
	cRet += '				<a:gradFill rotWithShape="1">' + CHR(13)+CHR(10)
	cRet += "					<a:gsLst>" + CHR(13)+CHR(10)
	cRet += '						<a:gs pos="0">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:tint val="80000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="300000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
	cRet += '						<a:gs pos="100000">' + CHR(13)+CHR(10)
	cRet += '							<a:schemeClr val="phClr">' + CHR(13)+CHR(10)
	cRet += '								<a:shade val="30000"/>' + CHR(13)+CHR(10)
	cRet += '								<a:satMod val="200000"/>' + CHR(13)+CHR(10)
	cRet += "							</a:schemeClr>" + CHR(13)+CHR(10)
	cRet += "						</a:gs>" + CHR(13)+CHR(10)
	cRet += "					</a:gsLst>" + CHR(13)+CHR(10)
	cRet += '					<a:path path="circle">' + CHR(13)+CHR(10)
	cRet += '						<a:fillToRect l="50000" t="50000" r="50000" b="50000"/>' + CHR(13)+CHR(10)
	cRet += "					</a:path>" + CHR(13)+CHR(10)
	cRet += "				</a:gradFill>" + CHR(13)+CHR(10)
	cRet += "			</a:bgFillStyleLst>" + CHR(13)+CHR(10)
	cRet += "		</a:fmtScheme>" + CHR(13)+CHR(10)
	cRet += "	</a:themeElements>" + CHR(13)+CHR(10)
	cRet += "	<a:objectDefaults/>" + CHR(13)+CHR(10)
	cRet += "	<a:extraClrSchemeLst/>" + CHR(13)+CHR(10)
	cRet += "</a:theme>" + CHR(13)+CHR(10)
Return(cRet)