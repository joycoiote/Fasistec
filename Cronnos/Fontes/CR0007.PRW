#include "rwmake.ch"
#include "protheus.ch"
//#include "EECRDM.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CR0007   �                               � Data � 18.03.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rela��o de Borderos para cobranca / pagamentos             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR170(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CR0007()

SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
SetPrvt("NOPCA,TITULO,ARETURN,NOMEPROG,ALINHA,NLASTKEY")
SetPrvt("CPERG,CCOMPLE1,CCOMPLE2,CCOMPLE3,WNREL,NVALOR")
SetPrvt("NVALTOT,NCONTADOR,NTOTBORD,NABAT,NREGEMP,LACHOUFIL")
SetPrvt("ATAM,ACOLU,NDECS,CBTXT,CBCONT,LI")
SetPrvt("M_PAG,CFILDE,CFILATE,CFILANT,DVENCTO,CCODIGO")
SetPrvt("CNOME,CLOJA,ADRIVER,LWIN,LFIRST,NCHAR")
SetPrvt("NLARGURA,")


cDesc1 := "Este programa tem a fun��o de emitir os borderos de cobran�a"
cDesc2 := "ou pagamentos gerados pelo usuario."
cDesc3 := ""
//wnrel
tamanho:= "P"
limite := 080
cString:= "SEA"
nOpca	 := 0

PRIVATE cabec1
PRIVATE cabec2
PRIVATE titulo  := "Emiss�o de Borderos"
PRIVATE aReturn := { OemToAnsi("Zebrado"), 1,OemToAnsi("Administracao"), 2, 2, 1, "",1 }
PRIVATE nomeprog:="CR0007"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="CR0007"
PRIVATE cComple1 :=Space(79)
PRIVATE cComple2 :=Space(79)
PRIVATE cComple3 :=Space(79)

pergunte("CR0007")

//�������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                        �
//� mv_par01        	// Carteira (R/P)                       �
//� mv_par02        	// Numero do Bordero                    �
//� mv_par03        	// Considera filiai                     �
//� mv_par04        	// da filial                            �
//� mv_par05        	// ate a filial                         �
//� mv_par06        	// moeda                                �
//� mv_par07        	// imprime outras moedas                �
//���������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel := "CR0007"
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

DEFINE MSDIALOG oDlg FROM  92,70 TO 221,463 TITLE OemToAnsi("Mensagem Complementar") PIXEL
@ 09, 02 SAY "Linha 1" SIZE 24, 7 OF oDlg PIXEL
@ 24, 02 SAY "Linha 2" SIZE 25, 7 OF oDlg PIXEL
@ 38, 03 SAY "Linha 3" SIZE 25, 7 OF oDlg PIXEL
@ 07, 31 MSGET cComple1 Picture "@S48" SIZE 163, 10 OF oDlg PIXEL
@ 21, 31 MSGET cComple2 Picture "@S48" SIZE 163, 10 OF oDlg PIXEL
@ 36, 31 MSGET cComple3 Picture "@S48" SIZE 163, 10 OF oDlg PIXEL

DEFINE SBUTTON FROM 50, 139 TYPE 1 ENABLE OF oDlg ACTION (nOpca:=1,oDlg:End())
DEFINE SBUTTON FROM 50, 167 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca#1
	cComple1 :=""
	cComple2 :=""
	cComple3 :=""
EndIf

RptStatus({|lEnd| Fa170Imp(@lEnd,wnRel,cString)},Titulo)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FA170Imp � Autor � Wagner Xavier         � Data � 05.10.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rela��o de Borderos para cobranca / pagamentos             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FA170Imp(lEnd,wnRel,cString)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd     -  A��o do CodeBlock                              ���
���          � wnRel    -  T�tulo do relat�rio                            ���
���          � cString  -  Mensagem                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FA170Imp(lEnd,wnRel,cString)

LOCAL cCodigo,cNome,nValor:=0,nValTot:=0,dVencto
LOCAL nContador := 0
LOCAL cbcont,CbTxt
LOCAL cSituaca,nTotBord:=0
LOCAL nAbat := 0
LOCAL cLoja
LOCAL cFilDe,cFilAte
Local nRegEmp:=SM0->(RecNo())
Local lAchouFil:=.F.
Local aTam := TAMSX3("E1_CLIENTE")
Local aColu := {}
Local ndecs:=Msdecimais(mv_par06)

cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nContador := 0

SetRegua(RecCount())

If mv_par03 == 1
	cFilDe  := mv_par04
	cFilAte := mv_par05
ELSE
	cFilDe  := xFilial("SEA")
	cFilAte := xFilial("SEA")
Endif

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

aColu := IIF (aTam[1] > 6,{040,041,066,067,077,079,095},{026,027,052,053,063,065,079})

While !Eof() .and. M0_CODIGO == cEmpAnt .and. M0_CODFIL <= cFilAte
	cFilAnt := M0_CODFIL

	dbSelectArea("SEA")
	dbSetOrder( 1 )

	IF !dbSeek(xFilial()+mv_par02)
		DbSelectArea("SM0")
		DbSkip()
		LOOP
	Else
		lAchouFil := .T.
	EndIf

	While !Eof() .And. EA_NUMBOR==mv_par02 .and. EA_FILIAL == xFilial()

		IF ( lEnd )
			@Prow()+1,001 PSAY OemToAnsi("CANCELADO PELO OPERADOR")
			Exit
		EndIf

		IncRegua()

		IF ( Empty(EA_NUMBOR) )
			dbSkip()
			Loop
		EndIf

		IF ( mv_par01 == 1 .and. EA_CART = "P" )
			dbSkip()
			Loop
		EndIf

		IF ( mv_par01 == 2 .and. EA_CART = "R" )
			dbSkip()
			Loop
		EndIf

		If SEA->EA_TIPO $ MV_CRNEG+"/"+MV_CPNEG+"/"+MVABATIM
			dbSkip()
			LOOP
		Endif

		IF ( li > 55 )
			IF ( m_pag != 1 )
				li++
				@li, 0 PSAY REPLICATE("-",IIf(aTam[1] > 6,96,79))
			EndIf
			li++
			fr170cabec()
			m_pag++
		EndIf
		_cLoja  := ""
		IF ( mv_par01 == 1 )
			If !(SEA->EA_TIPO $ MV_CRNEG+"/"+MVABATIM)
				dbSelectArea("SE1")
				dbSeek( cFilial+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA )
				While !Eof() .and. SEA->EA_FILIAL+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA==SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
    	    		If mv_par07 == 2
			          if SE1->E1_MOEDA != mv_par06
			         	dbSkip()
    			    	Loop
	        	      endif
   			        endif

					If SE1->E1_TIPO $ MV_CRNEG+"/"+MVABATIM
						nAbat += xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,mv_par06,SE1->E1_EMISSAO,ndecs+1)
					Endif
					dbSkip()
				Enddo
			Endif

			dbSelectArea( "SE1" )
			dbSeek( cFilial+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO )
			nValor:=xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,mv_par06,SE1->E1_EMISSAO,ndecs+1)
			dVencto:=E1_VENCTO
			cCodigo:=E1_CLIENTE
			_cLoja := SE1->E1_LOJA
			dbSelectArea( "SA1" )
			dbSeek(cFilial+cCodigo+SE1->E1_LOJA)
			cNome  := SubStr(A1_NOME,1,25)
		Else
			If !(SEA->EA_TIPO $ MV_CPNEG+"/"+MVABATIM)
				dbSelectArea("SE2")
				dbSeek( cFilial+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA )
				While !Eof() .and. SEA->EA_FILIAL+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA==SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA
            		if mv_par07 == 2
         			    if SE2->E2_MOEDA != mv_par06
		        	    	dbSkip()
			            	Loop
        			    endif
		            endif

					If SE2->E2_TIPO $ MV_CPNEG+"/"+MVABATIM .AND. SEA->EA_FORNECE==SE2->E2_FORNECE
						nAbat += xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,mv_par06,SE1->E1_EMISSAO,ndecs+1)
					Endif
					dbSkip()
				Enddo
			Endif
			cLoja := Iif ( Empty(SEA->EA_LOJA) , "" , SEA->EA_LOJA )
			dbSelectArea( "SE2" )
			dbSeek( cFilial+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE + cLoja )
			nValor:=xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,mv_par06,SE1->E1_EMISSAO,ndecs+1)
			dVencto:=E2_VENCTO
			cCodigo:=E2_FORNECE
			dbSelectArea( "SA2" )
			dbSeek(cFilial+cCodigo+SE2->E2_LOJA)
			cNome  :=SubStr(A2_NOME,1,25)
		EndIf
		dbSelectArea( "SEA" )
		IF  nValor > 0
			li++
/*
//			@li, 0 PSAY "|"
			@li, 0 PSAY EA_PREFIXO
			@li, 4 PSAY EA_NUM
//			@li,17 PSAY "|"
			@li,11 PSAY EA_PARCELA
//			@li,19 PSAY "|"
			@li,20 PSAY cCodigo
//			@li,aColu[1] PSAY "|"
			@li,aColu[2] PSAY cNome
//			@li,aColu[3] PSAY "|"
			@li,aColu[4] PSAY dVencto
//			@li,aColu[5] PSAY "|"
			@li,aColu[6] PSAY (nValor - nAbat) Picture PesqPict("SE1","E1_VALOR",14,MV_PAR06)
//			@li,aColu[7] PSAY "|"
*/
			_cFat := ""
			dbSelectArea("SD2")
			dbSetOrder(3)
			If dbSeek(xFilial()+SEA->EA_NUM + SEA->EA_PREFIXO + cCodigo + _cLoja )
			   _cFat := SD2->D2_PREEMB
			Endif

			dbSelectArea("SEA")
			@li, 0 PSAY "|"+EA_PREFIXO
			@li, 4 PSAY "|"+EA_NUM
			@li,11 PSAY "|"+Substr(EA_PARCELA,1,1)
			@li,13 PSAY "|"+Substr(_cFat,1,10)
			@li,24 PSAY "|"+Substr(cNome,1,30)
			@li,55 PSAY "|"+Dtoc(dVencto)
			@li,64 PSAY "|"
			@li,65 PSAY (nValor - nAbat) Picture PesqPict("SE1","E1_VALOR",14,MV_PAR06)
			@li,79 PSAY "|"

			nValTot += nValor - nAbat
			nContador ++
			nAbat := 0
		 EndIf
		 dbSkip()
	EndDO
	If Empty(xFilial("SEA"))
		Exit
	Endif
	dbSelectArea("SM0")
	dbSkip()
Enddo

If !lAchouFil
	Set Device to Screen
	Help(" ",1,"NOBORDERO")
	SM0->(dbGoto(nRegEmp))
	cFilAnt := SM0->M0_CODFIL
	dbSelectArea("SEA")
	dbSetOrder(1)
	Set Filter to
	Return
Endif

While ( li <= 49 .and. nValTot != 0 )
	li++
	@li, 0 PSAY "|"
	@li,04 PSAY "|"
	@li,11 PSAY "|"
	@li,13 PSAY "|"
	@li,24 PSAY "|"
	@li,55 PSAY "|"
	@li,64 PSAY "|"
	@li,79 PSAY "|"
Enddo

SM0->(dbGoto(nRegEmp))
cFilAnt := SM0->M0_CODFIL

IF ( nValTot != 0 )
	li++
	@li, 0 PSAY "|"+REPLICATE("-",IIF(aTam[1]>6,94,78))+"|"
	li++
	IF mv_par01 == 1
		@li, 0 PSAY OemToAnsi("|   TOTAL DA RELACAO A CREDITO DE NOSSA CONTA CORRENTE       ")
		@li,64 PSAY "|"
		@li,65 PSAY	nValTot  Picture PesqPict("SE1","E1_VALOR",14,MV_PAR06)
		@li,79 PSAY "|"
	Else
		@li, 0 PSAY OemToAnsi("|   TOTAL DA RELACAO A DEBITO DE NOSSA CONTA CORRENTE        ")
		@li,64 PSAY "|"
		@li,65 PSAY	Transform(nValTot,PesqPict("SE1","E1_VALOR",14,MV_PAR06))
		@li,79 PSAY "|"
	EndIf
	li ++

	@li, 0 PSAY OemToAnsi("|   QUANTIDADE  DE TITULOS IMPRESSOS                         ")
	@li,64 PSAY "|"
	@li,65 PSAY nContador PICTURE "@E 9999999999999"
	@li,79 PSAY "|"

	li++
	@li, 0 PSAY "|"+REPLICATE("-",iif(aTam[1]>6,94,78))+"|"
	li+=2
	@li, 0 PSAY OemToAnsi("Data: ") + DTOC(dDataBase)
	@li,35 PSAY OemToAnsi("Atenciosamente")
	li+=1
	@li,35 PSAY SM0->M0_NOMECOM
	li+=2
	@li,35 PSAY REPLICATE("-",Len(Trim(SM0->M0_NOMECOM)))
	li++
	@li,0  PSAY " "
EndIf
Set Device To Screen
dbSelectArea("SE1")
dbSetOrder(1)
Set Filter To

If aReturn[5] = 1
	Set Printer To
	dbCommit()
	Ourspool(wnrel)
EndIf

MS_FLUSH()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fr170cabec� Autor � Wagner Xavier         � Data � 24.05.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cabecalho do Bordero                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �fr170cabec()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC Function fr170cabec()

Local aDriver := ReadDriver()
Local lWin := .f.
Local lFirst := .T.
Local nChar:= IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM"))
Local aTam := TAMSX3("E1_CLIENTE")

IF m_pag == 1

	If TYPE("__DRIVER") == "C"
		If "DEFAULT"$__DRIVER
			lWin := .T.
		EndIf
	EndIf
	nLargura:=080

	If GetMv("MV_SALTPAG",,"S") == "N"
		Setprc(0,0)
	EndIf
	If nChar == NIL .and. !lWin .and. __cInternet == Nil
		@ 0,0 PSAY &(aDriver[3])
	ElseIf !lWin .and. __cInternet == Nil
		If nChar == 15
			@ 0,0 PSAY &(aDriver[3])
		Else
			@ 0,0 PSAY &(aDriver[4])
		EndIf
	EndIf

	dbSelectArea("SA6")
	dbSeek(cFilial+SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON)
	@1, 0 PSAY OemToAnsi("AO ")+A6_NOME
	@2, 0 PSAY OemToAnsi("AGENCIA ")+A6_AGENCIA + OemToAnsi(" C/C ")+SEA->EA_NUMCON
	@3, 0 PSAY ALLTRIM(A6_BAIRRO)+" - "+ALLTRIM(A6_MUN)+" - "+ALLTRIM(SA6->A6_EST)
	@4, 0 PSAY OemToAnsi("BORDERO NRO ")+mv_par02
	IF mv_par01 == 1
		@6, 0 PSAY OemToAnsi("Solicitamos proceder o recebimento das duplicatas abaixo relacionadas")
		@7, 0 PSAY OemToAnsi("CREDITANDO-NOS os valores correspondentes.")
	Else
		@6, 0 PSAY OemToAnsi("Solicitamos proceder o pagamento das duplicatas abaixo relacionadas")
		@7, 0 PSAY OemToAnsi("DEBITANDO-NOS os valores correspondentes.")
	EndIf
	li:=8
	If ( !Empty ( cComple1 ) )
		@li++, 0 PSAY cComple1
	EndIf
	If	( !Empty ( cComple2 ) )
		@li++, 0 PSAY cComple2
	EndIf
	If !Empty ( cComple3 )
		@li++ , 0 PSAY cComple3
	EndIf
	li+=2
Else
	li:=1
EndIf
//@li, 0 PSAY REPLICATE("-",IIf(aTam[1] > 6 , 96, 79))

@li, 0 PSAY REPLICATE("-",80)

li++

/*
|NUM|DUPLIC|P|FAT.EXP   |R A Z A O   S O C I A L       | VENCTO |         VALOR|
|999|999999|9|9999999999|999999999999999999999999999999|99999999|99999999999999|
|1  4      1113         24                             55       64             |

NUM DUPLIC P FAT.EXP    R A Z A O   S O C I A L            VENCTO          VALOR

*/
@li, 0 PSAY "|NUM|DUPLIC|P|FAT.EXP   |R A Z A O   S O C I A L       | VENCTO |         VALOR|"
li++
//
//@li, 0 PSAY "|"+REPLICATE("-",IIF(aTam[1]>6,94,78))+"|"

@li, 0 PSAY REPLICATE("-",80)
dbSelectArea( "SEA" )

Return .T.