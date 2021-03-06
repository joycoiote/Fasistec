#include "rwmake.ch"

User Function PA0061()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Montagem da tela de processamento.                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

@ 150,1 TO 380,450 DIALOG _oGeraTxt TITLE OemToAnsi("Atualizacao Ult.Preco Compra")
@ 02,10 TO 080,220
@ 10,018 Say " Este programa ira Atualizar o Ultimo Preco de Compra do Cadas-" SIZE 160,7
@ 18,018 Say " tro de Produtos Pela Ultimo Preco das Notas Fiscais de Compra"  SIZE 160,7
@ 26,018 Say " Programa PA0061.PRW                                           " SIZE 160,7
@ 85,128 BMPBUTTON TYPE 01 ACTION Proc1()
@ 85,158 BMPBUTTON TYPE 02 ACTION Close(_oGeraTxt)
//@ 85,188 BMPBUTTON TYPE 05 ACTION Pergunte(_cPerg,.T.)

Activate Dialog _oGeraTxt Centered

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튔un뇙o    � OKGERATXT� Autor � AP5 IDE            � Data �  07/06/02   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒escri뇙o � Funcao chamada pelo botao OK na tela inicial de processamen볍�
굇�          � to. Executa a geracao do arquivo texto.                    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Programa principal                                         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

Static Function Proc1()


Private _lFim      := .F.
Private _cMsg01    := ''
Private _lAborta01 := .T.
Private _bAcao01   := {|_lFim| Proc2(@_lFim) }
Private _cTitulo01 := 'Processando Ultimo Preco de Compra'
Processa( _bAcao01, _cTitulo01, _cMsg01, _lAborta01 )

MSGINFO("Alteracao Efetuada com Sucesso !!! ")

Close(_oGeraTxt)

Return



Static Function Proc2(_lFim)

dbSelectArea("SD1")
dbSetOrder(7)
dbGotop()

ProcRegua(LastRec())

While !Eof()
	
	If _lFim
		Alert("Cancelado Pelo Usuario!!!!")
		Return
	Endif
		
	_cProd    := SD1->D1_COD
	_nUltPrec := 0
	_dUltPrec := ctod("")
	
	While !Eof() .And. _cProd == SD1->D1_COD
		
		IncProc("Produto : "+SD1->D1_COD)
		
		If SD1->D1_TIPO != "N"
			dbSelectArea("SD1")
			dbSkip()
			Loop
		Endif
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+SD1->D1_TES)
		
		If SF4->F4_UPRC == "N"
			dbSelectArea("SD1")
			dbSkip()
			Loop
		Endif
		
		_dUltPrec := SD1->D1_DTDIGIT
		_nUltPrec := SD1->D1_VUNIT
		
		dbSelectArea("SD1")
		dbSkip()
	Enddo
	
	If _nUltPrec > 0
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+_cProd)
			dbSelectArea("SB1")
			RecLock("SB1",.F.)
			SB1->B1_UPRC := _nUltPrec
			SB1->B1_UCOM := _dUltPrec
			MsUnlock()
		Endif
	Endif
	
	dbSelectArea("SD1")
	
EndDo

Return