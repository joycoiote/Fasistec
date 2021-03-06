#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AjLocP    � Autor � Ivan M. Tor�       � Data �  07/03/01   ���
�������������������������������������������������������������������������͹��
���Descricao � Ajuste do local padrao no Cad. de Produtos, Ped. Com. e NF ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Gen�rico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AjLocP


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Private cString
Private oDlg1

//���������������������������������������������������������������������Ŀ
//� Montagem da tela de processamento.                                  �
//�����������������������������������������������������������������������

@ 200,1 TO 380,380 DIALOG oDlg1 TITLE OemToAnsi("Ajuste Local Padr�o")
@ 02,10 TO 080,190
@ 10,018 Say " Este programa ira ajustar o local padrao do cadastro de Pro- "
@ 18,018 Say " dutos, Pedidos de Compra e Nota Fiscal de Entrada            "
@ 26,018 Say "                                                              "

@ 70,128 BMPBUTTON TYPE 01 ACTION OkProc()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oDlg1)

Activate Dialog oDlg1 Centered

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � OkProc   � Autor � Ivan M. Tore       � Data �  07/03/01   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao chamada pelo botao OK na tela inicial de processamen���
���          � to. Executa o inicio do processamento.                     ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function OkProc

//���������������������������������������������������������������������Ŀ
//� Inicializa a regua de processamento                                 �
//�����������������������������������������������������������������������

Processa({|| RunProc() },"Processando...")
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � RUNProc  � Autor � Ivan M. Tore       � Data �  07/03/01   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunProc

Local cLocPad := Space(02)
Local nRegIni, nRegFim

dbSelectArea("SB1")
dbSetOrder(1)
nRegIni := 1
nRegFim := RecCount()
ProcRegua(RecCount())
dbGoTop()
Do While !Eof()

	IncProc("Processando: " + Str(nRegIni) + " de " + Str(nRegFim))
	cLocPad := Space(02)

	If SB1->B1_TIPO == "PA"
		cLocPad := "99"

	ElseIf SB1->B1_TIPO == "PI"
		If AllTrim(SB1->B1_GRUPO) == "PIC"
			cLocPad := "10"
		ElseIf AllTrim(SB1->B1_GRUPO) == "PIPF"
			cLocPad := "15"
		ElseIf AllTrim(SB1->B1_GRUPO) == "PIPM"
			cLocPad := "15"
		ElseIf AllTrim(SB1->B1_GRUPO) == "PIPB"
			cLocPad := "20"
		Endif

	ElseIf SB1->B1_TIPO == "MP"
		If AllTrim(SB1->B1_GRUPO) == "MPVC"
			cLocPad := "05"
		ElseIf AllTrim(SB1->B1_GRUPO) == "MPVZ"
			cLocPad := "25"
		ElseIf AllTrim(SB1->B1_GRUPO) == "MPIM"
			cLocPad := "01"
		ElseIf AllTrim(SB1->B1_GRUPO) == "MPC"
			cLocPad := "01"
		ElseIf AllTrim(SB1->B1_GRUPO) == "MPG"
			cLocPad := "01"			
		Endif
	
	ElseIf SB1->B1_TIPO == "MC"	
		cLocPad := "01"
	
	ElseIf SB1->B1_TIPO == "FE"
		cLocPad := "70"
	
	ElseIf SB1->B1_TIPO == "AF"
		cLocPad := "60"

	ElseIf SB1->B1_TIPO == "SE"
		cLocPad := "01"
	Endif
	
	dbSelectArea("SB1")
	RecLock("SB1",.F.)
	SB1->B1_LOCPAD := cLocPad
	MsUnLock("SB1")
	
	AjPedNF(SB1->B1_COD,cLocPad)

	dbSelectArea("SB1")
    nRegIni++
	dbSkip()
EndDo

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � AjPedNF  � Autor � Ivan M. Tore       � Data �  07/03/01   ���
�������������������������������������������������������������������������͹��
���Descri��o � Ajuste do Pedido de Compra e da Nota Fiscal                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function AjPedNF(cProduto,cLocal)

dbSelectArea("SC7")
dbSetOrder(2)
dbGoTop()
If dbSeek(xFilial("SC7")+cProduto)
	Do While !Eof() .and. SC7->C7_PRODUTO == cProduto
		RecLock("SC7",.F.)
		SC7->C7_LOCAL := cLocal
		MsUnLock("SC7")
		dbSkip()
	EndDo
Endif

dbSelectArea("SD1")
dbSetOrder(2)
dbGoTop()
If dbSeek(xFilial("SD1")+cProduto)
	Do While !Eof() .and. SD1->D1_COD == cProduto
		RecLock("SD1",.F.)
		SD1->D1_LOCAL := cLocal
		MsUnLock("SD1")
		dbSkip()
	EndDo
Endif

Return