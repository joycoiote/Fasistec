#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#DEFINE IMP_SPOOL 2
/*
Programa CR0022
Dat			: 15/08/12
Uso 		: SIGAFAT - FAT
Descri��o 	: Gerar Formulario de Abertura de DNP
*/

USER FUNCTION CR0022()

LOCAL oDlg := NIL

PRIVATE cTitulo    	:= "Formul�rio de DNP"
PRIVATE oPrn       	:= NIL

Private oFont1:= TFont():New("Arial",,-18,,.T.,,,,.F.,.F.)
Private oFont2:= TFont():New("Arial",,-18,,.F.,,,,.F.,.F.)
Private oFont3:= TFont():New("Arial",,-14,,.F.,,,,.F.,.F.)
Private oFont4:= TFont():New("Courier New",14,14,,.F.,,,,.F.,.T.)// Negrito
Private oFont5:= TFont():New("Arial",,-11,,.F.,,,,.F.,.F.)
Private oFont6:= TFont():New("Arial",,-11,,.T.,,,,.F.,.F.)
Private oFont7:= TFont():New("Arial",,-07,,.F.,,,,.F.,.F.)
Private oFont8:= TFont():New("Arial",,14,,.T.,,,,.F.,.F.)

DEFINE MSDIALOG oDlg FROM 0,0 TO 100,250 TITLE cTitulo OF oDlg PIXEL

@ 010,017 SAY "Deseja imprimir o DNP: "+SZF->ZF_CODDNP OF oDlg PIXEL Size 150,010 FONT oFont3 //COLOR CLR_BLUE

@ 30,020 BUTTON "OK" 		 SIZE 036,012 ACTION (CR022A(),oDlg:End()) 	OF oDlg PIXEL
@ 30,080 BUTTON "Sair"       SIZE 036,012 ACTION ( oDlg:End()) 			OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return(Nil)


Static Function CR022A()

Local cLogo      	:= FisxLogo("1")
Local oPrn

_cDir:= "C:\TOTVS\"

If !ExistDir( _cDir )
	If MakeDir( _cDir ) <> 0
		MsgAlert(  "Imposs�vel criar diretorio ( "+_cDir+" ) " )
		Return
	EndIf
EndIf

cTitulo += "_"+SZF->ZF_CODDNP

oPrn :=FWMSPrinter():New(cTitulo,6,.F.,,.T.,,,,,.F.)
oPrn:setDevice(IMP_PDF)
oPrn:cPathPDF := _cDir
oPrn:SetResolution(78)
oPrn:SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4)
oPrn:SetMargin(60,60,60,60)

oPrn:Box(00,00,830,600)
oPrn:SayBitmap(005,005,cLogo,70,40)
oPrn:line(000,085,050,085)

oPrn:Say(020,115,"DNP-FORMUL�RIO DE ABERTURA DE PROCESSO",oFont1)
oPrn:Say(038,230,"E PR�-OR�AMENTO",oFont1)
oPrn:line(000,515,050,515)
oPrn:Say(020,525,"DNP N�",oFont2)
oPrn:Say(038,525,SZF->ZF_CODDNP,oFont1)
oPrn:line(050,000,050,600)

oPrn:Say(065,008,"Dados Cadastrais:",oFont8)
oPrn:Say(085,008,"Cod. Cliente:",oFont3)
oPrn:Say(085,090,SZF->ZF_CLIENTE +"/"+SZF->ZF_LOJA,oFont4)
oPrn:Say(085,350,"Tipo Cliente:",oFont3)
oPrn:Say(085,450,If(SZF->ZF_TIPOCLI = "L","Local","Exporta��o"),oFont4)
oPrn:Say(100,008,"Nome Cliente:",oFont3)
SA1->(dbSetOrder(1))
If SA1->(dbSeek(xFilial("SA1")+SZF->ZF_CLIENTE+SZF->ZF_LOJA))
	oPrn:Say(100,090,Alltrim(SA1->A1_NOME),oFont4)
Endif
oPrn:line(110,000,110,600)

oPrn:Say(125,008,"Infoma��es Or�amento do Cliente:",oFont8)
oPrn:Say(145,008,"N� Sol./Solicitante:",oFont3)
oPrn:Say(145,115,Alltrim(SZF->ZF_NSOLICI),oFont4)
oPrn:Say(145,350,"Data Solicita��o:",oFont3)
oPrn:Say(145,450,DTOC(SZF->ZF_DTSOLIC),oFont4)
oPrn:Say(160,008,"Observa��es:",oFont3)
_cOBS1 := 	SZF->ZF_OBSORCA
oPrn:Say(160,100,Substr(_cOBS1,1,40),oFont4)
oPrn:Say(184,100,Substr(_cOBS1,41,80),oFont4)
oPrn:line(185,000,185,600)

oPrn:Say(200,008,"Infoma��es do Produto",oFont8)
oPrn:Say(220,008,"C�d. Prod. Cliente:",oFont3)
oPrn:Say(220,115,Alltrim(SZF->ZF_CODCLI),oFont4)
oPrn:Say(220,210,"Rev. Desenho:",oFont3)
oPrn:Say(220,300,Alltrim(SZF->ZF_REVISAO),oFont4)
oPrn:Say(220,400,"Fornecido Amostra:",oFont3)
oPrn:Say(220,520,IF(SZF->ZF_AMOSTRA = "S","Sim","N�o"),oFont4)
oPrn:Say(235,008,"Observa��es:",oFont3)
_cOBS2 := 	SZF->ZF_OBSPROD
oPrn:Say(235,100,Substr(_cOBS2,1,40),oFont4)
oPrn:Say(250,100,Substr(_cOBS2,41,80),oFont4)
oPrn:line(265,000,265,600)

oPrn:Say(280,008,"Infoma��es de Demanda",oFont8)
oPrn:Say(300,008,"Quantidade:",oFont3)
oPrn:Say(300,070,Transform(SZF->ZF_QTDEDEM, "@E 999,999.999"),oFont4)
oPrn:Say(300,210,"UM:",oFont3)
oPrn:Say(300,240,SZF->ZF_UM,oFont4)
oPrn:Say(300,350,"Periodicidade:",oFont3)
_cPer := ""
If SZF->ZF_PERIODI = "ME"
	_cPer := "Mensal"
ElseIf SZF->ZF_PERIODI = "AN"
	_cPer := "Mensal"
ElseIf SZF->ZF_PERIODI = "LF"
	_cPer := "Lote Fechado e Unico"
ElseIf SZF->ZF_PERIODI = "CF"
	_cPer := "Lote Fechado com possivel Consumo Futuro"
ElseIf SZF->ZF_PERIODI = "OU"
	_cPer := "Outros(vide obs. comeciais)"
Endif
oPrn:Say(300,430,_cPer,oFont4)
oPrn:line(310,000,310,600)

oPrn:Say(325,008,"Infoma��es de Ferramental",oFont8)
oPrn:Say(345,008,"Cliente possui Ferramental:",oFont3)
oPrn:Say(345,160,IF(SZF->ZF_FERRAME = "S","Sim","N�o"),oFont4)
oPrn:Say(360,008,"Descri��o do Ferramental:",oFont3)
oPrn:Say(360,160,SZF->ZF_DESFERR,oFont4)
oPrn:line(370,000,370,600)

oPrn:Say(385,008,"Infoma��es Comerciais",oFont8)
oPrn:Say(405,008,"Modal para Cota��o:",oFont3)
oPrn:Say(405,130,SZF->ZF_MODAL,oFont4)
oPrn:Say(405,350,"Pre�o Objetivo:",oFont3)
oPrn:Say(405,430,Transform(SZF->ZF_PRECO, "@E 999,999.9999"),oFont4)
oPrn:Say(420,008,"Observa��es:",oFont3)
_cOBS3 := 	SZF->ZF_OBSCOME
oPrn:Say(420,100,Substr(_cOBS3,1,40),oFont4)
oPrn:Say(435,100,Substr(_cOBS3,41,80),oFont4)
oPrn:line(450,000,450,600)

oPrn:Say(470,008,"Emissor:",oFont3)
oPrn:Say(470,060,Alltrim(SZF->ZF_EMISSOR),oFont4)
oPrn:Say(470,210,"Data abertura:",oFont3)
oPrn:Say(470,300,DTOC(SZF->ZF_EMISSAO),oFont4)
oPrn:Say(470,400,"Prazo Resposta:",oFont3)
oPrn:Say(470,500,DTOC(SZF->ZF_DTRESPO),oFont4)
oPrn:line(480,000,480,600)
oPrn:line(483,000,483,600)

oPrn:line(483,015,800,015)

oPrn:Say(510,018,"Base Econ�mica: ____/____/____",oFont5)
oPrn:Say(510,178,"IPI(Excluso)______%",oFont5)
oPrn:Say(510,400,"Lote m�nimo de venda:_______p�s",oFont5)

oPrn:Say(530,018,"Validade:______dias",oFont5)
oPrn:Say(530,178,"ICMS:     Incluso(al�quota indicada acima)     excluso",oFont5)
oPrn:Box(520,204,530,214)
oPrn:Box(520,351,530,361)
oPrn:Say(530,400,"Lote m�nimo p/ 1� entrega:_______p�s",oFont5)

oPrn:Say(550,018,"Pre�o Unit�rio:_____________",oFont5)
oPrn:Say(550,178,"Cond. Pgto.:_____________",oFont5)
oPrn:Say(550,400,"Prazo p/ apresenta��o amostras:_______dias",oFont5)

oPrn:Say(570,018,"Ferramental:",oFont5)
oPrn:Say(570.5,018,"___________",oFont5)
oPrn:Say(570,178,"Desp.financ. inclusa:__________%",oFont5)
oPrn:Say(570,400,"Prazo p/ entrega do lote:_______dias",oFont5)

oPrn:Box(580,018,590,028)
oPrn:Say(590,034,"Molde de vulcaniza��o por ________________________________________,com _________ cavidades",oFont5)

oPrn:Box(600,018,610,028)
oPrn:Say(610,034,"Ferramenta de corte",oFont5)

oPrn:Box(620,018,630,028)
oPrn:Say(630,034,"____________________________________________________________",oFont5)

oPrn:Say(650,018,"Pre�o:______________",oFont5)
oPrn:Say(650,178,"Cond.pagto: ",oFont5)
oPrn:Box(640,255,650,265)
oPrn:Say(650,270,"_____% c/pedido, saldo c/ _______________",oFont5)

oPrn:Say(670,018,"IPI(excluso):_________%",oFont5)
oPrn:Box(660,255,670,265)
oPrn:Say(670,270,"A vista c/______________________________",oFont5)

oPrn:Box(680,255,690,265)
oPrn:Say(690,270,"_______________________________________",oFont5)

oPrn:Say(710,018,"Observa��es a serem inclusas no or�amento:",oFont5)

oPrn:Box(575,500,800,600)
oPrn:Say(750,515,"VISTO RESPOSPONS�VEL:",oFont6,,,270)

oPrn:Say(760,011,"********** Informa��es p/ Or�amento **********",oFont5,,,270)
oPrn:line(800,000,800,600)

oPrn:Say(820,005,"Or�amento transmitido em: ___/___/___        N� Or�.:                     Visto Resp.:____________________",oFont3)
oPrn:Say(820,290,SZF->ZF_NRORCAM,oFont4)

oPrn:Say(838,553,"Fc70 rev.00",oFont7)

oPrn:EndPage()
oPrn:Preview()
FreeObj(oPrn)
oPrn := Nil

If Empty(SZF->ZF_STATUS)
	SZF->(RecLock("SZF",.F.))
	SZF->ZF_STATUS := 'IM'
	SZF->(MsUnlock())
Endif

Return()

