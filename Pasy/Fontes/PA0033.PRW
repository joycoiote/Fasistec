#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PA0033     � Autor � Alexandro da Silva� Data �  23/03/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Consulta Faturamento                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Faturamento                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function PA0033()

Private _aCampos, _cNomArq

_aAliOri := GetArea()
_aAliSC5 := SC5->(GetArea())
_aAliSC6 := SC6->(GetArea())
_aAliSF4 := SF4->(GetArea())
_aAliSD2 := SD2->(GetArea())

If !Pergunte("PA0002",.T.)
	Return(_cStatus)
Endif

Private _lFim      := .F.
Private _cMsg01    := ''
Private _lAborta01 := .T.
Private _bAcao01   := {|_lFim| RunProc(@_lFim) }
Private _cTitulo01 := 'Processando'
Processa( _bAcao01, _cTitulo01, _cMsg01, _lAborta01 )

//Pergunte("MTA410",.F.)

dbSelectArea("TRB")
dbCloseArea("TRB")

FErase(_cNomArq+".DBF")

RestArea(_aAliSF4)
RestArea(_aAliSC5)
RestArea(_aAliSC6)
RestArea(_aAliSD2)
RestArea(_aAliOri)

Return(Acols[n][_nPosStat])



Static Function RunProc(_lFim)

Private _nTam := 90
Private _cFimBloc:= CHR(192)+Repli(CHR(196),(_nTam-2))+CHR(217)
Private _cBrancBl:= "�"+Repli(" ",(_nTam-2))+"�"


_aCampos := {}
AADD(_aCampos,{"LINHA","C",92,0 } )

_cNomArq := CriaTrab(_aCampos)
USE &_cNomArq Alias TRB ExClusive NEW VIA __LocalDriver

Private _cCliente := M->EE7_CLIENT
Private _cLoja    := M->EE7_CLLOJA
Private _cProd    := M->EE8_COD_I
Private _cProdCli := M->EE8_CLLOJA
Private _cPedCli  := M->EE8_REFCLI

_lAchou  := .F.

dbSelectArea("SC6")
dbOrderNickname("INDSC61")
If dbSeek(xFilial("SC6")+ _cCliente + _cLoja + _cProd + _cProdCli + _cPedCli)
	
	_lAchou := .T.
	_cChavSC6 :=  SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_PRODUTO+SC6->C6_CPROCLI+SC6->C6_PEDCLI
	
	_cString:= "Movimentos em Aberto: "
	U_PAGRAVA(CHR(218)+_cString+Repli(CHR(196),((_nTam-2)-Len(_cString)))+CHR(191),Alias())
	U_PAGRAVA("�"+Space((_nTam-2))+"�")
	
	_cString:= "Pedido de Venda"
	U_PAGRAVA(CHR(218)+_cString+Repli(CHR(196),((_nTam-2)-Len(_cString)))+CHR(191),Alias())
	U_PAGRAVA("�"+Space((_nTam-2))+"�")

/*
�Produto         Pedido It Emissao  Entrega     Qtde.Pedido  Qtde.Entregue          Saldo
999999999999999	999999 99 99999999 99999999 99999999999999 99999999999999 99999999999999
0               16     23 26       35       44             59             74
*/
	_cString:= "�Produto         Pedido It Emissao  Entrega     Qtde.Pedido  Qtde.Entregue          Saldo�"
	U_PAGRAVA(CHR(218)+_cString+Repli(CHR(196),((_nTam-2)-Len(_cString)))+CHR(191),Alias())
	U_PAGRAVA("�"+Space((_nTam-2))+"�")
	
	_nQtdeTot  := 0
	_nSaldotot := 0
		
	dbSelectArea("SC6")
	_nRec      := LastRec()
	ProcRegua(_nRec)
	
	While !Eof() .And. _cChavSC6 ==  SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_PRODUTO+SC6->C6_CPROCLI+SC6->C6_PEDCLI
		
		IncProc("Selecionando os Pedidos em Aberto")
		
		If _lFim
			Alert("cancelado pelo Operador!!")
			Return
		EndIf
		
		
		_dEmissao := CTOD("  /  /  ")
		dbSelectArea("SC5")
		dbSetOrder(1)
		If dbSeek(SC6->C6_FILIAL+SC6->C6_NUM)
			_dEmissao := SC5->C5_EMISSAO
		Endif
		
		If  (SC6->C6_QTDVEN == SC6->C6_QTDENT)  .Or. Alltrim(SC6->C6_BLQ) == "R"
			dbSelectarea("SC6")
			dbSkip()
			Loop
		Endif
		
		If MV_PAR03 == 2
			dbSelectArea("SF4")
			dbSetOrder(1)
			If dbSeek(xFilial("SF4")+SC6->C6_TES)
				If SF4->F4_TPNFISC == "S"
					dbSelectarea("SC6")
					dbSkip()
					Loop
				ElseIf SF4->F4_ESTOQUE != "S"
					dbSelectarea("SC6")
					dbSkip()
					Loop
				Endif
			Endif
		Else
        	dbSelectArea("SF4")
			dbSetOrder(1)
			If dbSeek(xFilial("SF4")+SC6->C6_TES)
				If SF4->F4_ESTOQUE != "S"
					dbSelectarea("SC6")
					dbSkip()
					Loop
				Endif
			Endif		
		Endif
		_nSaldoTot := _nSaldoTot +  (SC6->C6_QTDVEN - SC6->C6_QTDENT)
		_nQtdeTot  := _nQtdeTot  + SC6->C6_QTDVEN
		
		_cString := "� "+SC6->C6_CPROCLI+" "+SC6->C6_NUM+" "+SC6->C6_ITEM+" "+DTOC(_dEmissao)+" "+;
		DTOC(SC6->C6_ENTREG)+" "+TRANSFORM(SC6->C6_QTDVEN,"@E 999,999,999.99")+" "+;
		TRANSFORM(SC6->C6_QTDENT,"@E 999,999,999.99")+" "+TRANSFORM(SC6->C6_QTDVEN - SC6->C6_QTDENT,"@E 999,999,999.99")
		_cString += Space( ( ( _nTam-Len(_cString) ) - 1 ) )+"�"
		U_PAGRAVA(_cString,Alias())
		
		dbSelectArea("SC6")
		dbSkip()
	EndDo
	U_PAGRAVA(_cFimBloc,Alias())	
	U_PAGRAVA("�"+Space((_nTam-2))+"�")
	
	_cString:= "�Qtde.Total : "+Transform(_nQtdeTot,"@E 999,999,999.99")+" Saldo Total : "+Transform(_nSaldoTot,"@E 999,999,999.99")
	_cString += Space( ( ( _nTam-Len(_cString) ) - 1 ) )+"�"
	U_PAGRAVA(_cString,Alias())
	U_PAGRAVA("�"+Space((_nTam-2))+"�")
Endif

_nQtdeNf := 0
_nValNf  := 0

dbSelectArea("SD2")
dbOrderNickname("INDSD21")
dbSeek(xFilial("SD2")+ _cCliente + _cLoja + _cProd + _cProdCli + _cPedCli +Dtos(MV_PAR01),.T.)

_cChavSD2 :=  SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD+SD2->D2_PROCLI+SD2->D2_PEDCLI
If _cChavSD2 == _cCliente + _cLoja + _cProd + _cProdCli + _cPedCli
	
	_cString:= "�Lancamentos de Saida: �"
	U_PAGRAVA(CHR(218)+_cString+Repli(CHR(196),((_nTam-2)-Len(_cString)))+CHR(191),Alias())
	U_PAGRAVA("�"+Space((_nTam-2))+"�")
	
/*
�Tp N.Fisc Ser Emissao   Qtde.Entregue    Valor Total�
99 999999 999 99999999 99999999999999 99999999999999
0  3      10  14       23             38
*/
	_cString:= "�Tp N.Fisc Ser Emissao   Qtde.Entregue    Valor Total�"
	U_PAGRAVA(CHR(218)+_cString+Repli(CHR(196),((_nTam-2)-Len(_cString)))+CHR(191),Alias())
	U_PAGRAVA("�"+Space((_nTam-2))+"�")
	
	_lAchou := .T.
	dbSelectArea("SD2")
	_nRec := LastRec()
	ProcRegua(_nRec)
	
	While !Eof().And. (_cChavSD2 ==  SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD+SD2->D2_PROCLI) .And. SD2->D2_EMISSAO <= MV_PAR02
		
		IncProc("Selecionando as N.Fiscais de Venda")
		
		If _lFim
			Alert("cancelado pelo Operador!!")
			Return
		EndIf
		
		
		If MV_PAR03 == 2
			dbSelectArea("SF4")
			dbSetOrder(1)
			If dbSeek(xFilial("SF4")+SD2->D2_TES)
				If SF4->F4_TPNFISC == "S"
					dbSelectarea("SD2")
					dbSkip()
					Loop
				Endif
			Endif
		Endif

    	dbSelectArea("SF4")
		dbSetOrder(1)
		If dbSeek(xFilial("SF4")+SD2->D2_TES)
			If SF4->F4_ESTOQUE != "S"
				dbSelectarea("SD2")
				dbSkip()
				Loop
			Endif
		Endif				
		_nQtdeNf   := _nQtdeNf +  SD2->D2_QUANT
		_nValNF    := _nValNf  +  SD2->D2_TOTAL

		_cString :="� "+SD2->D2_TIPO+" "+SD2->D2_DOC+" "+SD2->D2_SERIE+" "+DTOC(SD2->D2_EMISSAO)+" "+TRANSFORM(SD2->D2_QUANT,"@E 999,999,999.99")+" "+TRANSFORM(SD2->D2_TOTAL,"@E 999,999,999.99")
		_cString += Space( ( ( _nTam-Len(_cString) ) - 1 ) )+"�"
		U_PAGRAVA(_cString,Alias())
		
		dbSelectArea("SD2")
		dbSkip()
	EndDo

	U_PAGRAVA(_cFimBloc,Alias())		
	U_PAGRAVA("�"+Space((_nTam-2))+"�")
	
	_cString:= "�Qtde.Total : "+Transform(_nQtdeNf,"@E 999,999,999.99")+" Valor Total : "+Transform(_nValNf,"@E 999,999,999.99")
	_cString += Space( ( ( _nTam-Len(_cString) ) - 1 ) )+"�"
	U_PAGRAVA(_cString,Alias())
	U_PAGRAVA("�"+Space((_nTam-2))+"�")
Endif

If _lAchou
	MontaBrow()
Else
	MsgBox("Nao Existe Informacoes Para Essa Consulta ","ERRO!!!","STOP")
Endif

Return


Static Function Fecha()

aHeader := AClone(_aHeadOri)
aCols   := AClone(_aAColOri)
n       := _nOri


dbselectArea(_cAliSX3)
dbSetOrder(_nOrdSX3)
DbGoto(_nRecSX3)

//dbselectArea(_cAliAtu)
//dbSetOrder(_nOrdAtu)
//dbGoto(_nRecAtu)

Close(odlg3)

Return


/*
Static Function PAGRAVA(cVar,cAlias)

cVar := StrTran(cVar,Chr(179)," ")
cVar := StrTran(cVar,Chr(191)," ")
cVar := StrTran(cVar,Chr(192)," ")
cVar := StrTran(cVar,Chr(196)," ")
cVar := StrTran(cVar,Chr(217)," ")
cVar := StrTran(cVar,Chr(218)," ")

dbSelectArea("TRB")
RecLock("TRB",.T.)
TRB->LINHA :=  OemToAnsi(cVar)
MsUnLock()

dbSelectArea(cAlias)

Return

*/

Static Function MontaBrow()

Local oDlg, oQual
Local cCadastro := "Analise do Produto"
//Local oFont:=TFont():New( "Mono AS", 6, 15 )
Local oFont:=TFont():New( "Mono AS", 6, 15 )

dbSelectArea("TRB")
dbGotop()

/*
DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 To 25,85 OF oMainWnd
@ 5,10 LISTBOX oQual FIELDS TRB->LINHA HEADER "" SIZE 280,120  FONT oFont PIXEL
DEFINE SBUTTON FROM 14,300  TYPE 1 ACTION (oDlg:End()) 				ENABLE OF oDlg
DEFINE SBUTTON FROM 27,300  TYPE 6 ACTION (ImpCons(),oDlg:End())	ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED
*/

DEFINE MSDIALOG oDlg TITLE cCadastro From 8,0 To 25,95 OF oMainWnd
@ 5,10 LISTBOX oQual FIELDS TRB->LINHA HEADER "" SIZE 305,120  FONT oFont PIXEL
DEFINE SBUTTON FROM 14,320  TYPE 1 ACTION (oDlg:End()) 				ENABLE OF oDlg
DEFINE SBUTTON FROM 27,320  TYPE 6 ACTION (ImpCons(),oDlg:End())	ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED
oFont:End()
Return(.T.)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ImpCons  � Autor � Alexandro da Silva    � Data � 15/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia para funcao que faz a impressao da consulta.         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PA0002                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpCons()

LOCAL cTitulo   := "POSICAO ATUAL DE CLIENTE X PRODUTO"
LOCAL cDesc1 	:= "Este programa ira imprimir a Consulta do Produto selecionado,"
LOCAL cDesc2 	:= "informando os dados cadastrais, Movimentacoes em Aberto,"
LOCAL cDesc3 	:= "Historico de Movimentacoes."
LOCAL cString   := "TRB"
LOCAL wnrel     := "PA0002"

PRIVATE cPerg   := "      "
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
PRIVATE nLastKey:=0
nOpc:=2
nOpcA:=2
wnRel:= SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| RelImp(@lEnd,ctitulo,wnRel)},ctitulo)
Return .T.


Static Function RelImp(lEnd,ctitulo,wnRel)

Local cCabec1  := "Consulta Geral ao Produto"
Local cCabec2  := ""
Local cTamanho := "P"
Local cNomeProg:= "PA0002"
Local cbtxt    := SPACE(10)
Local cbcont   := 0

li       := 80
m_pag    := 1

//cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
//li++

dbSelectArea("TRB")
dbGoTop()
SetRegua(RecCount())            // Total de Elementos da Regua

While !EOF()

	IncRegua()

	IF li > 62
//		@ ++li,65 PSay "Continua......."
		cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
		Li:= 9
	EndIF

	// Substituir os caracteres graficos antes da impressao. //
	cCampo:=""
	For x:=1 to Len(TRB->LINHA)
		If Subs(TRB->LINHA,x,1) $ "ڿ��"
			cCampo += "+"
		ElseIf Subs(TRB->LINHA,x,1) == "�"
			cCampo += "-"
		ElseIf Subs(TRB->LINHA,x,1) == "�"
			cCampo += "a"
		ElseIf Subs(TRB->LINHA,x,1) == "�"
			cCampo += "c"
		ElseIf Subs(TRB->LINHA,x,1) == "�"
			cCampo += "|"
		Else
			cCampo += Subs(TRB->LINHA,x,1)
		Endif
	Next

	@ li++,00 PSay cCampo
	dbSkip()

EndDO

IF li != 80
	li++
	roda(cbcont,cbtxt,"P")
EndIF

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

Return (.T.)