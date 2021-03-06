#Include 'PROTHEUS.ch'
#INCLUDE "GPEM410.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MZ0134     � Autor � R.H. - Mauro          � Data � 10.04.96 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao de Liquidos em disquete                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/

User Function MZ0134()

Local nOpca

Local aSays			:={ }, aButtons:= { } //<== arrays locais de preferencia
Local aRegs         := {}
Private cCadastro 	:= OemToAnsi(STR0001) //"Gera��o de liquido em disquete"
Private nSavRec  	:= RECNO()
Private cPerg   	:= "GPM410"
nOpca := 0

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte(cPerg,.F.)

AADD(aSays,OemToAnsi(STR0002) )  //" Este programa tem o objetivo de gerar o arquivo de liquido em disco."
AADD(aSays,OemToAnsi(STR0003) )  //" Antes de rodar este programa  �  necess�rio cadastrar o lay-out do  "
AADD(aSays,OemToAnsi(STR0004) )  //" arquivo. Modulo SIGACFG op��o CNAB a Receber. "

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gpconfOK(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//����������������������������������������������������������������
If nOpca == 1
	Processa({|lEnd| MZ134_01(),STR0005})  //"Gera��o de liquido em disquete"
Endif

Return

*-------------------------------*
Static Function MZ134_01()
*-------------------------------*

//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Programa)                           �
//����������������������������������������������������������������
Local nExtra
Local aCodFol:={}
Local lHeader:=.F.,lFirst:=.F.,lGrava:=.F.
Local aBenefCop := {}
Local nCntP
Local nNumDec
Local cAux			:= ""
Local cStartPath	:= GetSrvProfString("StartPath","")
Local cNomArq		:= ""
Local cNomDir		:= ""
Local cPath 		:= GETTEMPPATH()
Local cNewArq		:= ""
Local nCont			:= 1
Local nAt			:= 0
Local nX			:= 0
Local lCpyS2T		:= .F.
Local nTpRemote		:= 0

//--Arquivo meses Anteriores
Local cMesArqRef 	:= ""
Local cAliasMov	 	:= ""
Local cArqMov	 	:= ""
Local aOrdBag	 	:= {}
Local cAliasRI	 	:= ""
Local cArqMovRI	 	:= ""
Local aOrdBagRI	 	:= {}
Local cCompetencia 	:= SuperGetMv( "MV_FOLMES",,Space(06) )

//Variaveis para identificacao do arquivo de movimento (apenas para TOP)
Local cRCName
Local cRIName

Local nS		:= 0
Local aStruSRA	:= {}
Local cAliasSRA := "SRA" 	//Alias da Query
Local cSitQuery := ""
Local cCatQuery := ""
Local cSRCExist := ""
Local cSRIExist := ""
Local cSRHExist := ""
Local cSR1Exist := ""
Local cSRGExist := ""
Local lDtItens	:= .F.

Private cNome,cBanco,cConta,cCPF
Private aValBenef := {}

//��������������������������������������������������������������Ŀ
//� Variaveis de Acesso do Usuario                               �
//����������������������������������������������������������������
Private cAcessaSRA	:= &( " { || " + ChkRH( "GPEM410" , "SRA" , "2" ) + " } " )
Private cAcessaSR1	:= &( " { || " + ChkRH( "GPEM410" , "SR1" , "2" ) + " } " )
Private cAcessaSRC	:= &( " { || " + ChkRH( "GPEM410" , "SRC" , "2" ) + " } " )
Private cAcessaSRG	:= &( " { || " + ChkRH( "GPEM410" , "SRG" , "2" ) + " } " )
Private cAcessaSRH	:= &( " { || " + ChkRH( "GPEM410" , "SRH" , "2" ) + " } " )
Private cAcessaSRI	:= &( " { || " + ChkRH( "GPEM410" , "SRI" , "2" ) + " } " )
Private cAcessaSRR	:= &( " { || " + ChkRH( "GPEM410" , "SRR" , "2" ) + " } " )

//��������������������������������������������������������������Ŀ
//� Define Variaveis PRIVADAS BASICAS                            �
//����������������������������������������������������������������
Private aABD := { STR0013,STR0014,STR0015 } //"Drive A"###"Drive B"###"Abandona"
Private aTA  := { STR0016,STR0017 } //"Tenta Novamente"###"Abandona"

//��������������������������������������������������������������Ŀ
//� Define Variaveis PRIVADAS DO PROGRAMA                        �
//����������������������������������������������������������������
Private nEspaco := nDisco := nGravados := 0
Private cDrive := " "
Private nArq, cTipInsc

//��������������������������������������������������������������Ŀ
//� Variaveis Usadas no Arquivo de Cadastramento                 �
//����������������������������������������������������������������
Private nSeq      := 0
Private nValor    := 0
Private nTotal    := 0
Private nTotFunc  := 0

Private nHdlBco :=0,nHdlSaida:=0
Private xConteudo

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        //  Adiantamento                             �
//� mv_par02        //  Folha                                    �
//� mv_par03        //  1�Parc. 13� Sal�rio                      �
//� mv_par04        //  2�Parc. 13� Sal�rio                      �
//� mv_par05        //  F�rias                                   �
//� mv_par06        //  Extras                                   �
//� mv_par07        //  Numero da Semana                         �
//� mv_par08        //  Filial  De                               �
//� mv_par09        //  Filial  Ate                              �
//� mv_par10        //  Centro de Custo De                       �
//� mv_par11        //  Centro de Custo Ate                      �
//� mv_par12        //  Banco /Agencia De                        �
//� mv_par13        //  Banco /Agencia Ate                       �
//� mv_par14        //  Matricula De                             �
//� mv_par15        //  Matricula Ate                            �
//� mv_par16        //  Nome De                                  �
//� mv_par17        //  Nome Ate                                 �
//� mv_par18        //  Conta Corrente De                        �
//� mv_par19        //  Conta Corrente Ate                       �
//� mv_par20        //  Situacao                                 �
//� mv_par21        //  Arquivo de configuracao                  �
//� mv_par22        //  nome do arquivo de saida                 �
//� mv_par23        //  data de credito                          �
//� mv_par24        //  Data de Pagamento De                     �
//� mv_par25        //  Data de Pagamento Ate                    �
//� mv_par26        //  Categorias                               �
//� mv_par27        //  Configura��o CNAB                        �
//� mv_par28        //  Rescisao			                     �
//� mv_par29        //  Imprimir			                     �
//� mv_par30        //  Data de Referencia                       �
//� mv_par31        //  Linha Vazia no Fim do Arquivo            �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
//����������������������������������������������������������������
lAdianta  := If(mv_par01 == 1,.T.,.F.)
lFolha    := If(mv_par02 == 1,.T.,.F.)
lPrimeira := If(mv_par03 == 1,.T.,.F.)
lSegunda  := If(mv_par04 == 1,.T.,.F.)
lFerias   := If(mv_par05 == 1,.T.,.F.)
lExtras   := If(mv_par06 == 1,.T.,.F.)
Semana    := mv_par07
cFilDe    := mv_par08
cFilAte   := mv_par09
cCcDe     := mv_par10
cCcate    := mv_par11
cBcoDe    := mv_par12
cBcoAte   := mv_par13
cMatDe    := mv_par14
cMatAte   := mv_par15
cNomDe    := mv_par16
cNomAte   := mv_par17
cCtaDe    := mv_par18
cCtaAte   := mv_par19
cSituacao := mv_par20
cArqent   := mv_par21
cArqSaida := mv_par22
dDataPgto := mv_par23
dDataDe   := mv_par24
dDataAte  := mv_par25
cCategoria:= mv_par26
nModelo	  := mv_par27
lRescisao := If(mv_par28 == 1,.T.,.F.)
nFunBenAmb:= mv_par29  // 1-Funcionarios  2-Beneficiarias  3-Ambos
dDataRef  := If (Empty(mv_par30), dDataBase,mv_par30)
lLnVazia  := If (mv_par31 == 1,.T.,.F.)

//���������������������������������������������������������������������Ŀ
//� Abre o SRC                                                          �
//�����������������������������������������������������������������������
If !Empty( cCompetencia )
	If !Empty( cCompetencia ) .And. MesAno( dDataRef ) > cCompetencia
		Aviso( STR0019, STR0020 + ": "+Subs(MesAno(dDataRef),5,2)+"/"+Subs(MesAno(ddataref),1,4), { STR0021 } ) //##"Atencao"##"Nao existe arquivo de fechamento referente a data base solicitada"##"Ok"
		Return .F.
	Endif
Endif

cMesArqRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)

If !OpenSrc( cMesArqRef, @cAliasMov, @aOrdBag, @cArqMov, dDataRef )
	Return .F.
Endif

//���������������������������������������������������������������������Ŀ
//� Abre o SRI                                                          �
//�����������������������������������������������������������������������
If lSegunda
	If !OpenSrc( "13"+Substr(cMesArqRef,3,4), @cAliasRI, @aOrdBagRI, @cArqMovRI, dDataRef )
		Return .F.
	EndIf
EndIf

If lFerias .and. ("F" $ cSituacao .and. !("A"$cSituacao) )
	cSituacao += "A"
EndIf

For nS:=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nS,1)+"'"
	If ( nS+1) <= Len(cSituacao)
		cSitQuery += ","
	Endif
Next nS

For nS:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nS,1)+"'"
	If ( nS+1) <= Len(cCategoria)
		cCatQuery += ","
	Endif
Next nS

If lFerias
	//��������������������������������������������������������������Ŀ
	//� Verifica existencia do campo RH_DTITENS                      �
	//����������������������������������������������������������������
	dbSelectArea( "SRH" )
	lDtItens := SRH->(FieldPos( "RH_DTITENS" )) # 0
EndIf

cRCName := If( Empty(cAliasMov), RetSqlName("SRC"), cArqMov )
cRIName := If( Empty(cAliasRI), RetSqlName("SRI"), cArqMovRI )

//��������������������������������������������������������������Ŀ
//� Define se devera ser impresso Funcionarios ou Beneficiarios  �
//����������������������������������������������������������������
dbSelectArea( "SRQ" )
lImprFunci  := ( nFunBenAmb # 2 )
lImprBenef  := ( nFunBenAmb # 1 .And. FieldPos( "RQ_BCDEPBE" ) # 0 .And. FieldPos( "RQ_CTDEPBE" ) # 0 )

//��������������������������������������������������������������Ŀ
//� Informa a nao existencia dos campos de bco/age/conta corrente�
//����������������������������������������������������������������
If nFunBenAmb # 1 .And. !lImprBenef
	fAvisoBC()
	Return .F.
Endif

/*
�����������������������������������������������������������������������Ŀ
|Verifica se o usuario definiu um diretorio local para gravacao do arq. |
|de saida, pois nesse caso efetua a geracao do arquivo no servidor e ao |
|fim da geracao copia para o diretorio local e apaga do servidor.       |
�������������������������������������������������������������������������*/
If Substr( cArqSaida, 2, 1 ) == ":"
	
	//?-Checa o SO do Remote (1=Windows, 2=Linux)
	nTpRemote := ( GetRemoteType() )
	
	If nTpRemote = 2
		nAt := RAt( "/", cArqSaida )
	Else
		nAt := RAt( "\", cArqSaida )
	EndIf
	
	If nAt = 0
		//"O endere�o especificado no par�metro 'Arquivo de Sa�da' n�o � v�lido. Digite um endere�o v�lido conforme o exemplo:"
		//"Unidade:\Nome_do_Arquivo"#"/Nome_do_Arquivo"
		Alert( "O endere�o especificado no par�metro 'Arquivo de Sa�da' n�o � v�lido. Digite um endere�o v�lido conforme o exemplo:" + CRLF + CRLF + If(nTpRemote = 1, "Unidade:\Nome_do_Arquivo", "/Nome_do_Arquivo") )
		Return
	EndIf
	
	cNewArq := cArqSaida
	
	If ( cAux := Substr( cArqSaida, Len(cArqSaida), 1 ) ) == " "
		
		While cAux == " "
			cNewArq	:= Substr( cArqSaida, 1, Len(cArqSaida) - nCont )
			cAux	:= Substr( cNewArq, Len(cNewArq), 1 )
			nCont++
		EndDo
	EndIf
	
	cNomArq		:= Right( cNewArq, Len(cNewArq) - nAt )
	cNomDir		:= Left( cNewArq, nAt )
	
	cArqSaida	:= cStartPath + cNomArq
	lCpyS2T		:= .T.
Endif

If !AbrePar()    //Abertura Arquivo ASC II
	Return
Endif

//�����������������������������������������������������������Ŀ
//� Desenha cursor para movimentacao                          �
//�������������������������������������������������������������
ProcRegua(SRA->(RecCount()))

FilAnt := "!!"
BcoAnt := Space(08)
CcAnt  := Space(09)
CtaAnt := Space(12)
NomAnt := Space(30)

//--Posiciona no Primeiro Selecionado no De/Ate
dbSelectArea( "SRA" )

cQuery := "SELECT COUNT(*) TOTAL "
cQuery += "FROM "+	RetSqlName("SRA")	+ " QSRA "
cQuery += "WHERE RA_FILIAL	BETWEEN '" + cFilDe + "' AND '" + cFilAte	+ "' "
cQuery += "AND RA_MAT		BETWEEN '" + cMatDe + "' AND '" + cMatAte	+ "' "
cQuery += "AND RA_NOME		BETWEEN '" + cNomDe + "' AND '" + cNomAte	+ "' "
cQuery += "AND RA_CC		BETWEEN '" + cCcDe  + "' AND '" + cCcate	+ "' "

If nFunBenAmb == 1
	cQuery += "AND RA_BCDEPSA	BETWEEN '" + cBcoDe	+ "' AND '" + cBcoAte	+ "' "
	cQuery += "AND RA_CTDEPSA	BETWEEN '" + cCtaDe	+ "' AND '" + cCtaAte	+ "' "
EndIf

cQuery += "AND RA_CATFUNC	IN (" + Upper(cCatQuery) + ") "
cQuery += "AND RA_SITFOLH	IN (" + Upper(cSitQuery) + ") "
cQuery += "AND QSRA.D_E_L_E_T_ = ' ' "

If lAdianta .Or. lFolha .Or. ( lPrimeira .And. !(cPaisLoc $ "URU|ARG") )
	cSRCExist += "( EXISTS ( SELECT RC_FILIAL, RC_MAT, RC_PD, RC_VALOR, RC_DATA "
	cSRCExist += "FROM " + cRCName + " QSRC "
	cSRCExist += "WHERE RC_FILIAL = RA_FILIAL "
	cSRCExist += "AND RC_MAT = RA_MAT "
	cSRCExist += "AND RC_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	
	If lAdianta .Or. lPrimeira
		cSRCExist += "AND RC_SEMANA	= '" + Semana + "' "
	EndIf
	
	cSRCExist += "AND QSRC.D_E_L_E_T_= ' ' ) ) "
EndIf

If lSegunda .or. If(cPaisLoc $ "URU|ARG",lPrimeira,.F.)
	If !Empty(cSRCExist)
		cSRIExist += "OR "
	EndIf
	
	cSRIExist += "( EXISTS ( SELECT RI_FILIAL, RI_MAT, RI_PD, RI_VALOR, RI_DATA "
	cSRIExist += "FROM " + cRIName + " QSRI "
	cSRIExist += "WHERE RI_FILIAL = RA_FILIAL "
	cSRIExist += "AND RI_MAT = RA_MAT "
	cSRIExist += "AND RI_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	cSRIExist += "AND QSRI.D_E_L_E_T_= ' ' ) ) "
EndIf

If lFerias
	
	fDtItens(.F.) //Retirar em futuras versoes
	
	If !Empty(cSRCExist) .Or. !Empty(cSRIExist)
		cSRHExist += "OR "
	EndIf
	
	cSRHExist += "( EXISTS ( SELECT SRR1.RR_FILIAL, SRR1.RR_MAT, SRR1.RR_PD, SRR1.RR_VALOR, SRR1.RR_DATA, QSRH.RH_DTRECIB "
	cSRHExist += "FROM "+ RetSqlName("SRR") + " SRR1 "
	cSRHExist += "INNER JOIN "+ RetSqlName("SRH") + " QSRH "
	cSRHExist += "ON ( SRR1.RR_FILIAL = RH_FILIAL "
	cSRHExist += "AND SRR1.RR_MAT = RH_MAT "
	
	If lDtItens
		cSRHExist 		+= "AND SRR1.RR_DATA = RH_DTITENS "
	Else
		cSRHExist 		+= "AND SRR1.RR_DATA = RH_DTRECIB "
	EndIf
	
	cSRHExist += "AND SRR1.D_E_L_E_T_ = QSRH.D_E_L_E_T_) "
	cSRHExist += "WHERE RH_FILIAL = RA_FILIAL "
	cSRHExist += "AND RH_MAT = RA_MAT "
	cSRHExist += "AND RH_DTRECIB BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	cSRHExist += "AND QSRH.D_E_L_E_T_= ' ' ) ) "
EndIf

If lExtras
	If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist)
		cSR1Exist += "OR "
	EndIf
	
	cSR1Exist += "( EXISTS ( SELECT R1_FILIAL, R1_MAT, R1_PD, R1_VALOR, R1_DATA "
	cSR1Exist += "FROM " + RetSqlName("SR1") + " QSR1 "
	cSR1Exist += "WHERE R1_FILIAL = RA_FILIAL "
	cSR1Exist += "AND R1_MAT = RA_MAT "
	cSR1Exist += "AND R1_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	cSR1Exist += "AND R1_SEMANA	= '" + Semana + "' "
	cSR1Exist += "AND QSR1.D_E_L_E_T_= ' ' ) ) "
EndIf

If lRescisao
	If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist) .Or. !Empty(cSR1Exist)
		cSRGExist += "OR "
	EndIf
	
	cSRGExist += "( EXISTS ( SELECT SRR2.RR_FILIAL, SRR2.RR_MAT, SRR2.RR_PD, SRR2.RR_VALOR, SRR2.RR_DATA, RG_DATAHOM "
	cSRGExist += "FROM "+ RetSqlName("SRR") + " SRR2 "
	cSRGExist += "INNER JOIN "+ RetSqlName("SRG") + " QSRG "
	cSRGExist += "ON ( SRR2.RR_FILIAL = RG_FILIAL "
	cSRGExist += "AND SRR2.RR_MAT = RG_MAT "
	cSRGExist += "AND SRR2.RR_DATAPAG = RG_DATAHOM "
	cSRGExist += "AND SRR2.D_E_L_E_T_ = QSRG.D_E_L_E_T_) "
	cSRGExist += "WHERE RG_FILIAL = RA_FILIAL "
	cSRGExist += "AND RG_MAT = RA_MAT "
	cSRGExist += "AND RG_DATAHOM BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	cSRGExist += "AND QSRG.D_E_L_E_T_= ' ' ) ) "
EndIf

If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist) .Or. !Empty(cSR1Exist) .Or. !Empty(cSRGExist)
	cQuery += "AND (" + cSRCExist + cSRIExist + cSRHExist + cSR1Exist + cSRGExist +")"
EndIf

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QUERY', .F., .T.)
dbSelectArea("QUERY")
nTotalQ := QUERY->TOTAL
ProcRegua(nTotalQ)		// Total de Elementos da regua
Query->( dbCloseArea() )
dbSelectArea("SRA")

cSRCExist := cSRIExist := cSRHExist := cSR1Exist := cSRGExist := ""

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName("SRA") + " QSRA "
cQuery += "WHERE RA_FILIAL	BETWEEN '" + cFilDe + "' AND '" + cFilAte	+ "' "
cQuery += "AND RA_MAT		BETWEEN '" + cMatDe + "' AND '" + cMatAte	+ "' "
cQuery += "AND RA_NOME		BETWEEN '" + cNomDe + "' AND '" + cNomAte	+ "' "
cQuery += "AND RA_CC		BETWEEN '" + cCcDe  + "' AND '" + cCcate	+ "' "

If nFunBenAmb == 1
	cQuery += "AND RA_BCDEPSA	BETWEEN '" + cBcoDe	+ "' AND '" + cBcoAte	+ "' "
	cQuery += "AND RA_CTDEPSA	BETWEEN '" + cCtaDe	+ "' AND '" + cCtaAte	+ "' "
EndIf

cQuery += "AND RA_CATFUNC	IN (" + Upper(cCatQuery) + ") "
cQuery += "AND RA_SITFOLH	IN (" + Upper(cSitQuery) + ") "
cQuery += "AND QSRA.D_E_L_E_T_ = ' ' "

If lAdianta .Or. lFolha .Or. ( lPrimeira .And. !(cPaisLoc $ "URU|ARG") )
	cSRCExist += "( EXISTS ( SELECT RC_FILIAL, RC_MAT, RC_PD, RC_VALOR, RC_DATA "
	cSRCExist += "FROM " + cRCName + " QSRC "
	cSRCExist += "WHERE RC_FILIAL = RA_FILIAL "
	cSRCExist += "AND RC_MAT = RA_MAT "
	cSRCExist += "AND RC_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	
	If lAdianta .Or. lPrimeira
		cSRCExist += "AND RC_SEMANA	= '" + Semana + "' "
	EndIf
	
	cSRCExist += "AND QSRC.D_E_L_E_T_= ' ' ) ) "
EndIf

If lSegunda .or. If(cPaisLoc $ "URU|ARG",lPrimeira,.F.)
	If !Empty(cSRCExist)
		cSRIExist += "OR "
	EndIf
	
	cSRIExist += "( EXISTS ( SELECT RI_FILIAL, RI_MAT, RI_PD, RI_VALOR, RI_DATA "
	cSRIExist += "FROM " + cRIName + " QSRI "
	cSRIExist += "WHERE RI_FILIAL = RA_FILIAL "
	cSRIExist += "AND RI_MAT = RA_MAT "
	cSRIExist += "AND RI_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	cSRIExist += "AND QSRI.D_E_L_E_T_= ' ' ) ) "
EndIf

If lFerias
	
	fDtItens(.F.) //Retirar em futuras versoes
	
	If !Empty(cSRCExist) .Or. !Empty(cSRIExist)
		cSRHExist += "OR "
	EndIf
	
	cSRHExist += "( EXISTS ( SELECT SRR1.RR_FILIAL, SRR1.RR_MAT, SRR1.RR_PD, SRR1.RR_VALOR, SRR1.RR_DATA, QSRH.RH_DTRECIB "
	cSRHExist += "FROM "+ RetSqlName("SRR") + " SRR1 "
	cSRHExist += "INNER JOIN "+ RetSqlName("SRH") + " QSRH "
	cSRHExist += "ON ( SRR1.RR_FILIAL = RH_FILIAL "
	cSRHExist += "AND SRR1.RR_MAT = RH_MAT "
	
	If lDtItens
		cSRHExist 		+= "AND SRR1.RR_DATA = RH_DTITENS "
	Else
		cSRHExist 		+= "AND SRR1.RR_DATA = RH_DTRECIB "
	EndIf
	
	cSRHExist += "AND SRR1.D_E_L_E_T_ = QSRH.D_E_L_E_T_) "
	cSRHExist += "WHERE RH_FILIAL = RA_FILIAL "
	cSRHExist += "AND RH_MAT = RA_MAT "
	cSRHExist += "AND RH_DTRECIB BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	cSRHExist += "AND QSRH.D_E_L_E_T_= ' ' ) ) "
EndIf

If lExtras
	If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist)
		cSR1Exist += "OR "
	EndIf
	
	cSR1Exist += "( EXISTS ( SELECT R1_FILIAL, R1_MAT, R1_PD, R1_VALOR, R1_DATA "
	cSR1Exist += "FROM " + RetSqlName("SR1") + " QSR1 "
	cSR1Exist += "WHERE R1_FILIAL = RA_FILIAL "
	cSR1Exist += "AND R1_MAT = RA_MAT "
	cSR1Exist += "AND R1_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	cSR1Exist += "AND R1_SEMANA	= '" + Semana + "' "
	cSR1Exist += "AND QSR1.D_E_L_E_T_= ' ' ) ) "
EndIf

If lRescisao
	If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist) .Or. !Empty(cSR1Exist)
		cSRGExist += "OR "
	EndIf
	
	cSRGExist += "( EXISTS ( SELECT SRR2.RR_FILIAL, SRR2.RR_MAT, SRR2.RR_PD, SRR2.RR_VALOR, SRR2.RR_DATA, RG_DATAHOM "
	cSRGExist += "FROM "+ RetSqlName("SRR") + " SRR2 "
	cSRGExist += "INNER JOIN "+ RetSqlName("SRG") + " QSRG "
	cSRGExist += "ON ( SRR2.RR_FILIAL = RG_FILIAL "
	cSRGExist += "AND SRR2.RR_MAT = RG_MAT "
	cSRGExist += "AND SRR2.RR_DATAPAG = RG_DATAHOM "
	cSRGExist += "AND SRR2.D_E_L_E_T_ = QSRG.D_E_L_E_T_) "
	cSRGExist += "WHERE RG_FILIAL = RA_FILIAL "
	cSRGExist += "AND RG_MAT = RA_MAT "
	cSRGExist += "AND RG_DATAHOM BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
	cSRGExist += "AND QSRG.D_E_L_E_T_= ' ' ) ) "
EndIf

If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist) .Or. !Empty(cSR1Exist) .Or. !Empty(cSRGExist)
	cQuery += "AND (" + cSRCExist + cSRIExist + cSRHExist + cSR1Exist + cSRGExist +")"
EndIf

cQuery   += " ORDER BY RA_FILIAL, RA_MAT"

aStruSRA := SRA->(dbStruct())
SRA->( dbCloseArea() )

cQuery	:= ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSRA, .F., .T.)

For nX := 1 To Len(aStruSRA)
	If ( aStruSRA[nX][2] <> "C" )
		TcSetField(cAliasSRA,aStruSRA[nX][1],aStruSRA[nX][2],aStruSRA[nX][3],aStruSRA[nX][4])
	EndIf
Next nX

WHILE !SRA->( Eof() ) .And. SRA->RA_FILIAL + SRA->RA_MAT <= cFilAte + cMatAte
	
	//�����������������������������������������������������������Ŀ
	//� Movimenta Cursor                                          �
	//�������������������������������������������������������������
	IncProc(STR0018) //"Liquido em Disquete"
	
	nValor     := 0
	aValBenef := {}
	
	If SRA->RA_FILIAL # FilAnt
		If !Fp_CodFol(@aCodFol,SRA->RA_FILIAL)
			Exit
		Endif
		FilAnt := SRA->RA_FILIAL
	Endif
	
	/*
	�����������������������������������������������������������������������Ŀ
	�Consiste Filiais e Acessos                                             �
	�������������������������������������������������������������������������*/
	IF !( SRA->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
		SRA->(dbSkip())
		Loop
	EndIf
	
	fBuscaLiq(@nValor,@aValBenef,aCodFol,,,dDataRef, cRCName, cRIName)
	
	//��������������������������������������������������������������Ŀ
	//� Ponto de Entrada para despresar funcionario caso retorne .F. �
	//����������������������������������������������������������������
	If ExistBlock("GP410DES")
		If !(ExecBlock("GP410DES",.F.,.F.))
			dbSelectArea( "SRA" )
			SRA->(dbSkip(1))
			Loop
		EndIf
	EndIf
	
	If nFunBenAmb # 1
		//��������������������������������������������������������������Ŀ
		//� Consiste parametros de banco e conta do funcionario			 �
		//����������������������������������������������������������������
		If (SRA->RA_BCDEPSA < cBcoDe) .Or. (SRA->RA_BCDEPSA > cBcoAte) .Or.;
			(SRA->RA_CTDEPSA < cCtaDe) .Or. (SRA->RA_CTDEPSA > cCtaAte)
			nValor := 0
		EndIf
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Consiste parametros de banco e conta do beneficiario 		 �
	//� aValBenef: 1-Nome  2-Banco  3-Conta  4-Verba  5-Valor  6-CPF �
	//����������������������������������������������������������������
	If Len(aValBenef) > 0
		aBenefCop  := ACLONE(aValBenef)
		aValBenef  := {}
		Aeval(aBenefCop, { |X| If( ( X[2] >= cBcoDe .And. X[2] <= cBcoAte) .And.;
		( X[3] >= cCtaDe .And. X[3] <= cCtaAte),;
		AADD(aValBenef, X), "" ) })
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Testa Situacao do Funcionario na Folha                       �
	//� Testa Categoria do Funcionario na Folha                      �
	//� Testa se Valor == 0                                          �
	//����������������������������������������������������������������
	If !( SRA->RA_SITFOLH $ cSituacao ) .Or. !(SRA->RA_CATFUNC $ cCategoria) .Or.;
		( nValor == 0 .And. Len(aValBenef) == 0 )
		dbSelectArea( "SRA" )
		dbSkip()
		Loop
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Adiciona o funcionario no array para inclusao no arquivo	 �
	//����������������������������������������������������������������
	If lImprFunci
		Aadd(aValBenef, {  SRA->RA_NOME, SRA->RA_BCDEPSA, SRA->RA_CTDEPSA, "", nValor,SRA->RA_CIC } )
	EndIf
	
	For nCntP := 1 To Len(aValBenef)
		
		cNome   := aValBenef[nCntP,1]
		cBanco  := aValBenef[nCntP,2]
		cConta  := aValBenef[nCntP,3]
		cCPF	:= aValBenef[nCntP,6]
		//��������������������������������������������������������������Ŀ
		//� Verifica valor e banco/agencia dos beneficiarios			 �
		//����������������������������������������������������������������
		If aValBenef[nCntP,5] == 0 .Or. Empty(cBanco) .Or. cBanco < cBcoDe .Or. cBanco > cBcoAte
			Loop
		EndIf
		
		//��������������������������������������������������������������Ŀ
		//� Iguala nas Variaveis Usadas do arquivo de cadastramento      �
		//����������������������������������������������������������������
		nValor  := NoRound(aValBenef[nCntP,5] * 100,0)
		
		nTotal += nValor
		nTotFunc ++
		//nSeq++
		If ( nModelo == 1 )
			//��������������������������������������������������������������Ŀ
			//� Le Arquivo de Parametrizacao                                 �
			//����������������������������������������������������������������
			nLidos:=0
			fSeek(nHdlBco,0,0)
			nTamArq:=FSEEK(nHdlBco,0,2)
			fSeek(nHdlBco,0,0)
			
			While nLidos <= nTamArq
				//��������������������������������������������������������������Ŀ
				//� Verifica o tipo qual registro foi lido                       �
				//����������������������������������������������������������������
				xBuffer:=Space(85)
				FREAD(nHdlBco,@xBuffer,85)
				
				Do case
					Case SubStr(xBuffer,1,1) == CHR(1)
						IF lHeader
							nLidos+=85
							Loop
						EndIF
					Case SubStr(xBuffer,1,1) == CHR(2)
						IF !lFirst
							lFirst := .T.
							FWRITE(nHdlSaida,CHR(13)+CHR(10))
						EndIF
					Case SubStr(xBuffer,1,1) == CHR(3)
						nLidos+=85
						Loop
					Otherwise
						nLidos+=85
						Loop
				EndCase
				
				nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
				nDec := Val(SubStr(xBuffer,23,1))
				cConteudo:= SubStr(xBuffer,24,60)
				lGrava := fM410Grava(nTam,nDec,cConteudo)
				IF !lGrava
					Exit
				End
				nLidos+=85
			EndDO
			IF !lGrava
				Exit
			End
		Else
			lGrava := fM410Grava(,,,)
		EndIf
		If lGrava
			If ( nModelo == 1 )
				fWrite(nHdlSaida,CHR(13)+CHR(10))
				IF !lHeader
					lHeader := .T.
				EndIF
			EndIf
		EndIf
	Next nCntP
	dbSelectArea( "SRA" )
	SRA->( dbSkip( ) )
Enddo

If ( nModelo == 1 )
	//��������������������������������������������������������������Ŀ
	//� Monta Registro Trailler                                      �
	//����������������������������������������������������������������
	nSeq++
	nLidos:=0
	FSEEK(nHdlBco,0,0)
	nTamArq:=FSEEK(nHdlBco,0,2)
	FSEEK(nHdlBco,0,0)
	
	While nLidos <= nTamArq
		
		IF !lGrava
			Exit
		End
		
		//��������������������������������������������������������������Ŀ
		//� Tipo qual registro foi lido                                  �
		//����������������������������������������������������������������
		xBuffer:=Space(85)
		FREAD(nHdlBco,@xBuffer,85)
		
		IF SubStr(xBuffer,1,1) == CHR(3)
			nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
			nDec := Val(SubStr(xBuffer,23,1))
			cConteudo:= SubStr(xBuffer,24,60)
			lGrava:=fM410Grava( nTam,nDec,cConteudo )
			IF !lGrava
				Exit
			End
		EndIF
		nLidos+=85
	EndDO
	If lGrava .And. lLnVazia
		fWrite(nHdlSaida,CHR(13)+CHR(10))
	EndIf
Else
	RodaCnab2(nHdlSaida,cArqent)
EndIf
//��������������������������������������������������������������Ŀ
//� Termino do relatorio                                         �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores      �
//����������������������������������������������������������������
If !Empty( cAliasMov )
	fFimArqMov( cAliasMov , aOrdBag , cArqMov )
EndIf

If !Empty( cAliasRI )
	fFimArqMov( cAliasRI , aOrdBagRI , cArqMovRI )
EndIf

dbSelectArea("SRA")
dbCloseArea()
ChkFile("SRA")

fClose(nHdlSaida)

If lCpyS2T
	If CpyS2T( cStartPath + cNomArq, cNomDir, .F. )
		fErase( cStartPath + cNomArq )
	EndIf
EndIf

//-------------------------------------------------------------------
//Ponto de entrada utilizado para criptografia de arquivo de envio
//-------------------------------------------------------------------
If ExistBlock("GP410CRP")
	ExecBlock("GP410CRP",.F.,.F.)
Endif

dbSelectArea("SRC")
dbSetOrder(1)
dbSelectArea("SRI")
dbSetOrder(1)
dbSelectArea("SRA")
dbSetOrder(1)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AbrePar   � Autor � Wagner Xavier         � Data � 26/05/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Abre arquivo de Parametros                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �AbrePar()                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPEM410                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function AbrePar()

IF !FILE(cArqEnt)
	Help(" ",1,"NOARQPAR")
	Return .F.
Else
	If ( nModelo == 1 )
		nHdlBco:=FOPEN(cArqEnt,0+64)
	EndIf
EndIF

//��������������������������������������������������������������Ŀ
//� Ponto de entrada para alterar o nome da variavel cArqSaida   |
//����������������������������������������������������������������
If ExistBlock("GP410ARQ")
	cArqSaida := ExecBlock( "GP410ARQ", .F., .F., {cArqSaida} )
EndIf

//����������������������������������������������������������Ŀ
//� Cria Arquivo Saida                                       �
//������������������������������������������������������������
If ( nModelo == 1 )
	nHdlSaida:=MSFCREATE(cArqSaida,0)
Else
	nHdlSaida:=HeadCnab2(cArqSaida,cArqent)
EndIf
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fM410Grava� Autor � Wagner Xavier         � Data � 26/05/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de Geracao do Arquivo de Remessa de Comunicacao      ���
���          �Bancaria                                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ExpL1:=fM410Grava(ExpN1,ExpN2,ExpC1)                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GPEM410                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/

STATIC Function fM410Grava( nTam,nDec,cConteudo )

Local lConteudo := .T.

While .T.
	If ( nModelo == 1 )
		//����������������������������������������������������������Ŀ
		//� Analisa conteudo                                         �
		//������������������������������������������������������������
		IF Empty(cConteudo)
			cCampo:=Space(nTam)
		Else
			lConteudo := fM410Orig( cConteudo )
			IF !lConteudo
				Exit
			Else
				IF ValType(xConteudo)="D"
					cCampo := GravaData(xConteudo,.F.)
				Elseif ValType(xConteudo)="N"
					cCampo:=Substr(Strzero(xConteudo,nTam,nDec),1,nTam)
				Else
					cCampo:=Substr(xConteudo,1,nTam)
				End
			End
		End
		IF Len(cCampo) < nTam  //Preenche campo a ser gravado, caso menor
			cCampo:=cCampo+Space(nTam-Len(cCampo))
		End
		Fwrite( nHdlSaida,cCampo,nTam )
	Else
		DetCnab2(nHdlSaida,cArqent)
	EndIf
	Exit
End
Return lConteudo

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fM410Orig � Autor � Wagner Xavier         � Data � 10/11/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se expressao e' valida para Remessa CNAB.          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �GPEM410                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/

Static Function fM410Orig( cForm )

Local bBlock:=ErrorBlock(),bErro := ErrorBlock( { |e| ChecErr260(e,cForm) } )
Private lRet := .T.

BEGIN SEQUENCE
xConteudo := &cForm
END SEQUENCE
ErrorBlock(bBlock)

Return lRet
       

Static Function DetCnab2(nHandle,cLayOut,lIdCnab,cAlias)

Local nHdlLay	 := 0
Local lContinua := .T.
Local cBuffer	 := ""
Local aLayOut	 := {}
Local aDetalhe  := {}
Local nCntFor	 := 0
Local nCntFor2  := 0
Local lFormula  := ""
Local nPosIni	 := 0
Local nPosFim	 := 0
Local nTamanho  := 0
Local nDecimal  := 0
Local bBlock	 := ErrorBlock()
Local bErro 	 := ErrorBlock( { |e| ChecErr260(e,xConteudo) } )
Local aGetArea  := GetArea()
Local cIdCnab
Local aArea
Local nOrdem

DEFAULT cAlias 	:= ""
DEFAULT lIdCnab 	:= .F.
Private xConteudo := ""

nQtdLinLote := If(Type("nQtdLinLote") != "N",0,nQtdLinLote)

If ( File(cLayOut) )
	nHdlLay := FOpen(cLayOut,64)
	While ( lContinua )
		cBuffer := FreadStr(nHdlLay,502)
		If ( !Empty(cBuffer) )
			If ( SubStr(cBuffer,1,1)=="1" )
				If ( SubStr(cBuffer,3,1) == "D" )
					aadd(aLayOut,{ SubStr(cBuffer,02,03),;
					SubStr(cBuffer,05,30),;
					SubStr(cBuffer,35,255)})
				EndIf
			Else
				If ( SubStr(cBuffer,3,1) == "D" )
					aadd(aDetalhe,{SubStr(cBuffer,02,03),;
					SubStr(cBuffer,05,15),;
					SubStr(cBuffer,20,03),;
					SubStr(cBuffer,23,03),;
					SubStr(cBuffer,26,01),;
					SubStr(cBuffer,27,255)})
				EndIf
			EndIf
		Else
			lContinua := .F.
		EndIf
	End
	FClose(nHdlLay)
EndIf
If nHandle > 0
	For nCntFor := 1 To Len(aLayOut)
		Begin Sequence
		lFormula := &(AllTrim(aLayOut[nCntFor,3]))
		If ( lFormula .And. SubStr(aLayOut[nCntFor,1],2,1)=="D" )
			cBuffer := ""
			// So gera outro identificador, caso o titulo ainda nao o tenha, pois pode ser um re-envio do arquivo
			If !Empty(cAlias) .And. lIdCnab .And. Empty((cAlias)->&(Right(cAlias,2)+"_IDCNAB")) 
				// Gera identificador do registro CNAB no titulo enviado
				nOrdem := If(Alltrim(Upper(cAlias))=="SE1",16,11)
				cIdCnab := GetSxENum(cAlias, Right(cAlias,2)+"_IDCNAB",Right(cAlias,2)+"_IDCNAB"+cEmpAnt,nOrdem)
				// Garante que o identificador gerado nao existe na base
				dbSelectArea(cAlias)
				aArea := (cAlias)->(GetArea())
				dbSetOrder(nOrdem)
				While (cAlias)->(MsSeek(xFilial(cAlias)+cIdCnab))
					ConOut("Id CNAB " + cIdCnab + " j� existe para o arquivo " + cAlias + ". Gerando novo n�mero ")
					If ( __lSx8 )
						ConfirmSX8()
					EndIf
					cIdCnab := GetSxENum(cAlias, Right(cAlias,2)+"_IDCNAB",Right(cAlias,2)+"_IDCNAB"+cEmpAnt,nOrdem)
				EndDo
				(cAlias)->(RestArea(aArea))
				Reclock(cAlias)
				(cAlias)->&(Right(cAlias,2)+"_IDCNAB") := cIdCnab
				MsUnlock()
				ConfirmSx8()
				lIdCnab := .F. // Gera o identificacao do registro CNAB apenas uma vez no
									// titulo enviado
			Endif
			For nCntFor2 := 1 To Len(aDetalhe)
				If ( aDetalhe[nCntFor2,1] == aLayOut[nCntFor,1] )
					xConteudo := aDetalhe[nCntFor2,6]
					If ( Empty(xConteudo) )
						xConteudo := ""
					Else
						xConteudo := &(AllTrim(xConteudo))
					EndIf
					nPosIni   := Val(aDetalhe[nCntFor2,3])
					nPosFim   := Val(aDetalhe[nCntFor2,4])
					nDecimal  := Val(aDetalhe[nCntFor2,5])
					nTamanho  := nPosFim-nPosIni+1
					Do Case
						Case ValType(xConteudo) == "D"
							xConteudo := GravaData(xConteudo,.F.)
						Case ValType(xConteudo) == "N"
							xConteudo := StrZero(xConteudo,nTamanho,nDecimal)
					EndCase
					xConteudo := SubStr(xConteudo,1,nTamanho)
					xConteudo := PadR(xConteudo,nTamanho)
					cBuffer += xConteudo
				EndIf
			Next nCntFor2
			cBuffer += Chr(13)+Chr(10)
			Fwrite(nHandle,cBuffer,Len(cBuffer))
			nQtdLinLote++
			nSeq++
		EndIf
		End Sequence
	Next nCntFor
	ErrorBlock(bBlock)
Endif
RestArea(aGetArea)

Return(.T.)

User Function BRI_INCREM(cNum)

If PCOUNT()==0
	cNum:=StrZero(nSeq,6)
EndIf
Return 1+Val(cNum)