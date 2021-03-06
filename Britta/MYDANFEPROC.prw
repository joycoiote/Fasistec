#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "SPEDNFE.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"

#DEFINE WS_CODRET 1  //COD SEFAZ DE RETORNO
#DEFINE WS_MSG    2  //MENSAGEM COMPLETA MONTADA PELA FUNCAO STATUS
#DEFINE WS_MSGSEF 3  //DESCRICAO DA MENSAGEM SEFAZ

#DEFINE WS1_LCONTG  1  //EST� EM CONTINGENCIA ?
#DEFINE WS1_DESCMOD 2  //DESCRICAO DA MODALIDADE

//  U_MyDanfeProc(_cSerie,_cNotaIni,_dDtIni)
User Function MyDanfeProc( _cSerie, _cNota,_dDtIni)

    LOCAL _cMsg:="Processando Transmiss�o"

//TrNF(_cSerie,_cNota,_cNota,_dDtIni,_dDtIni)
//If Upper(Alltrim(GETENVSERVER())) $ "AS"
    AutoNfeEnv(cEmpAnt,SF2->F2_FILIAL,"0","1",SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC)
//Else
//	U_ASC004('TODAS',_cSerie, _cNota, _cNota )
//Endif

    _lParar := .T.

    Processa({|| __MyDanfePr(_cSerie,_cNota, @_cMsg)}, "Aguardando Autorizacao da NF-e...",_cMsg,.F.)

RETURN



Static Function __MyDanfeP(_cSerie, _cNota, _cMsgSt)

    Local _aArea:={}
    LOCAL _oDanfe, _oSetup
    Local _cIdEnt:=""
    Local _cFilePrint := ""
    Local _nFlags:=0
    LOCAL _aWSStat:={"","",""}
    LOCAL _aWSCfg:={"",""}
    LOCAL nVezes, lTEnta
    LOCAL lImprime:=.T.
    Local cModalidade:= ""
    Local nX,_nTenta

    _cIdEnt := GetIdEnt()
//_aWSCfg := SpedCfg(_cIdEnt)
    _aArea  := GetArea()

    IF (SF2->F2_SERIE+SF2->F2_DOC)<>(_cSerie+_cNota)
        SF2->(OrdSetFocus(1))
        IF .NOT. (SF2->(DbSeek(xFilial("SF2")+_cNota+_cSerie)))
            Alert("NOTA FISCAL N�O ENCONTRADA")
            RETURN
        ENDIF
    ENDIF

    aNotas := {}
    aadd(aNotas,{})
    aadd(Atail(aNotas),.F.)
    aadd(Atail(aNotas),"S")
    aadd(Atail(aNotas),SF2->F2_EMISSAO)
    aadd(Atail(aNotas),SF2->F2_SERIE)
    aadd(Atail(aNotas),SF2->F2_DOC)
    aadd(Atail(aNotas),SF2->F2_CLIENTE)
    aadd(Atail(aNotas),SF2->F2_LOJA)

    If IsReady()
        //������������������������������������������������������������������������Ŀ
        //�Obtem o codigo da entidade                                              �
        //��������������������������������������������������������������������������
        cIdEnt := GetIdEnt()
    else
        return
    endif

    cNaoAut := ""
    aXml := GetXML(cIdEnt,aNotas,@cModalidade)

// 1 tentativa a cada segundo, at� que a nf esteja autorizada, m�ximo de 2 min
    for _nTenta:=1 to 120
        _lPassou:=.f.
        _cMensagem:=""
        nLenNotas := Len(aNotas)
        For nX := 1 To nLenNotas

            If !Empty(aXML[nX][2])

                If !Empty(aXml[nX])
                    cAutoriza   := aXML[nX][1]
                    cCodAutDPEC := aXML[nX][5]
                Else
                    cAutoriza   := ""
                    cCodAutDPEC := ""
                EndIf
                //If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. !cModalidade$"1,4,5,6")
                If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. Alltrim(aXML[nX][8]) $ "2,5,7")

                    cAviso := ""
                    cErro  := ""
                    oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)

                    oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)
                    If Empty(cAviso) .And. Empty(cErro)
                        // ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6])
                        _lPassou:=.t.
                    EndIf
                Else
                    _cMensagem:=aNotas[nX][04]+aNotas[nX][05]+CRLF
                EndIf
            EndIf

            if _lPassou
                exit
            else
                // Aguarda antes de tentar de novo
                _nSeconds:=seconds()
                do while seconds()-_nSeconds<1
                enddo
                aXml := GetXML(cIdEnt,aNotas,@cModalidade)
            endif

        Next _nTenta
        cNaoAut+=_cMensagem
    Next NX

//No trecho abaixo, ap�s finalizar a transmiss�o, grava na tabela SZA a hora do processamento.
    IF Type("_cOC") <> "U"
        If !Empty(_cOC) .And. SZA->(FieldPos("ZA_HORA03")) > 0
            _AreaSZA := SZA->(GetArea())
            SZA->(dbsetorder(1))
            If SZA->(msSeek(xFilial("SZA")+_cOc))
                SZA->(Reclock("SZA",.F.))
                SZA->ZA_HORA03	:= Time()
                SZA->(MsUnlock())
            Endif
            RestArea(_AreaSZA)
        Endif
    Endif
//No trecho acima, ap�s finalizar a transmiss�o, grava na tabela SZA a hora do processamento.

    _cFilePrint := "DANFE_"+_cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")

    _oDanfe := FWMSPrinter():New(_cFilePrint, IMP_PDF, .F., /*cPathInServer*/, .T.)
    _oDanfe:nDevice := IMP_PDF
    _oDanfe:cPathPDF := "C:\RELPROTHEUS\"
    _oDanfe:lInJob:=.T.

    IF lImprime
        u_PrtNfeSef(_cIdEnt,_cSerie,_cNota,_oDanfe, _oSetup, _cFilePrint)
    ENDIF

    RestArea(_aArea)

RETURN NIL


/*/
    �����������������������������������������������������������������������������
    �����������������������������������������������������������������������������
    �������������������������������������������������������������������������Ŀ��
    ���Programa  �STATUSNFE � Autor �Eduardo Riera          � Data �18.10.2007���
    �������������������������������������������������������������������������Ĵ��
    ���Descri��o �Rotina de monitoramento da NFe - Consulta NFe               ���
    ���          �COPIA DE SpedNFe4Mn TIRADA DE SPEDNFE.PRX                   ���
    �������������������������������������������������������������������������Ĵ��
    ���Retorno   �Nenhum                                                      ���
    �������������������������������������������������������������������������Ĵ��
    ���Parametros�Nenhum                                                      ���
    �������������������������������������������������������������������������Ĵ��
    ���   DATA   � Programador   �Manutencao efetuada                         ���
    �������������������������������������������������������������������������Ĵ��
    ���          �               �                                            ���
    ��������������������������������������������������������������������������ٱ�
    �����������������������������������������������������������������������������
    �����������������������������������������������������������������������������
/*/
STATIC Function StatusNfe(_cAlias, _cIdEnt, _cSerie, _cDoc)

//Local _cIdEnt     := ""
    Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local cMensagem  := ""
    Local oWS
    LOCAL aReturn:={"","",""}

    If .T. //IsReady()
        //������������������������������������������������������������������������Ŀ
        //�Obtem o codigo da entidade                                              �
        //��������������������������������������������������������������������������
        //_cIdEnt := GetIdEnt()
        If !Empty(_cIdEnt)
            //������������������������������������������������������������������������Ŀ
            //�Instancia a classe                                                      �
            //��������������������������������������������������������������������������
            If !Empty(_cIdEnt)

                oWs:= WsNFeSBra():New()
                oWs:cUserToken   := "TOTVS"
                oWs:cID_ENT      := _cIdEnt
                oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
                oWs:cNFECONSULTAPROTOCOLOID := _cSerie+_cDoc //IIF(_cAlias=="SF1",SF1->F1_SERIE+SF1->F1_DOC,SF2->F2_SERIE+SF2->F2_DOC)

                If oWs:ConsultaProtocoloNfe()
                    cMensagem := ""
                    If !Empty(oWs:oWSCONSULTAPROTOCOLONFERESULT:cVERSAO)
                        cMensagem += "STR0129"+": "+oWs:oWSCONSULTAPROTOCOLONFERESULT:cVERSAO+CRLF
                    EndIf
                    cMensagem += STR0035+": "+IIf(oWs:oWSCONSULTAPROTOCOLONFERESULT:nAMBIENTE==1,STR0056,STR0057)+CRLF //"Produ��o"###"Homologa��o"
                    cMensagem += STR0068+": "+oWs:oWSCONSULTAPROTOCOLONFERESULT:cCODRETNFE+CRLF
                    cMensagem += STR0069+": "+oWs:oWSCONSULTAPROTOCOLONFERESULT:cMSGRETNFE+CRLF
                    If !Empty(oWs:oWSCONSULTAPROTOCOLONFERESULT:cPROTOCOLO)
                        cMensagem += STR0050+": "+oWs:oWSCONSULTAPROTOCOLONFERESULT:cPROTOCOLO+CRLF
                    EndIf
                    //Aviso(STR0107,cMensagem,{STR0114},3)
                    If !Empty(oWs:oWSCONSULTAPROTOCOLONFERESULT:cPROTOCOLO)
                        Do Case
                        Case _cAlias == "SF1" .And. SF1->(FieldPos("F1_FIMP"))<>0
                            RecLock("SF1")
                            SF1->F1_FIMP := "S"
                            MsUnlock()
                        Case _cAlias == "SF2"
                            RecLock("SF2")
                            SF2->F2_FIMP := "S"
                            MsUnlock()
                        EndCase
                    EndIf
                    If oWs:oWSCONSULTAPROTOCOLONFERESULT:cCODRETNFE$"110,301,302,303,304,305,306" // Uso Denegado
                        Do Case
                        Case _cAlias == "SF1" .And. SF1->(FieldPos("F1_FIMP"))<>0
                            RecLock("SF1")
                            SF1->F1_FIMP := "D"
                            MsUnlock()
                        Case _cAlias == "SF2"
                            RecLock("SF2")
                            SF2->F2_FIMP := "D"
                            MsUnlock()
                        EndCase
                    EndIf
                Else
                    //Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
                    cMensagem:=IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
                EndIf
            EndIf
        Else
            Aviso("SPED","STR0021",{"STR0114"},3)	 //"Execute o m�dulo de configura��o do servi�o, antes de utilizar esta op��o!!!"
        EndIf
    Else
        Aviso("SPED","STR0021",{"STR0114"},3) //"Execute o m�dulo de configura��o do servi�o, antes de utilizar esta op��o!!!"
    EndIf

    aReturn[WS_CODRET]:= oWs:oWSCONSULTAPROTOCOLONFERESULT:cCODRETNFE
    aReturn[WS_MSG]   := cMensagem
    aReturn[WS_MSGSEF]:= oWs:oWSCONSULTAPROTOCOLONFERESULT:cMSGRETNFE

Return(aReturn)


//������������������������������������������������������������������������Ŀ
//�Obtem o ambiente de execucao do Totvs Services SPED                     �
//��������������������������������������������������������������������������
STATIC FUNCTION SpedCfg(_cIdEnt)
    LOCAL oWs1

    Local cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)
    LOCAL aReturn:={"",""}

    oWS1:= WsSpedCfgNFe():New()
    oWS1:cUSERTOKEN := "TOTVS"
    oWS1:cID_ENT    := _cIdEnt
    oWS1:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"

    oWs1:nModalidade:= 0
    oWS1:CFGModalidade()
    aReturn[WS1_LCONTG] :=("CONTING"$UPPER(oWS1:cCfgModalidadeResult))

    oWS1:nAmbiente  := 0
    oWS1:CFGAMBIENTE()
    aReturn[WS1_DESCMOD]:=oWS1:cCfgAmbienteResult

RETURN (aReturn)




/*/
    ���������������������������������������������������������������������������
    �����������������������������������������������������������������������������
    �������������������������������������������������������������������������Ŀ��
    ���Programa  �GetIdEnt  � Autor �Eduardo Riera          � Data �18.06.2007���
    �������������������������������������������������������������������������Ĵ��
    ���Descri��o �Obtem o codigo da entidade apos enviar o post para o Totvs  ���
    ���          �Service                                                     ���
    �������������������������������������������������������������������������Ĵ��
    ���Retorno   �ExpC1: Codigo da entidade no Totvs Services                 ���
    �������������������������������������������������������������������������Ĵ��
    ���Parametros�Nenhum                                                      ���
    �������������������������������������������������������������������������Ĵ��
    ���   DATA   � Programador   �Manutencao efetuada                         ���
    �������������������������������������������������������������������������Ĵ��
    ���          �               �                                            ���
    ��������������������������������������������������������������������������ٱ�
    �����������������������������������������������������������������������������
    �����������������������������������������������������������������������������
/*/
Static Function GetIdEnt()

    Local _aArea  := GetArea()
    Local _cIdEnt := ""
    Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local oWs
//������������������������������������������������������������������������Ŀ
//�Obtem o codigo da entidade                                              �
//��������������������������������������������������������������������������
    oWS := WsSPEDAdm():New()
    oWS:cUSERTOKEN := "TOTVS"

    oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
    oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
    oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
    oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
    oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
    oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
    oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
    oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
    oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
    oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
    oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
    oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
    oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
    oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
    oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
    oWS:oWSEMPRESA:cCEP_CP     := Nil
    oWS:oWSEMPRESA:cCP         := Nil
    oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
    oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
    oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
    oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
    oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
    oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
    oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
    oWS:oWSEMPRESA:cINDSITESP  := ""
    oWS:oWSEMPRESA:cID_MATRIZ  := ""
    oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
    oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
    If oWs:ADMEMPRESAS()
        _cIdEnt  := oWs:cADMEMPRESASRESULT
    Else
        Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"?"},3)
    EndIf

    RestArea(_aArea)
Return(_cIdEnt)


user Function TrSemWiz(cSerie,cNotaIni,cNotaFim)

    Local aArea       := GetArea()
    Local aPerg       := {}
    Local aParam      := {Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC))}
    Local aTexto      := {}
    Local aXML        := {}
    Local cRetorno    := ""
    Local cIdEnt      := ""
    Local cModalidade := ""
    Local cAmbiente   := ""
    Local cVersao     := ""
    Local cVersaoCTe  := ""
    Local cVersaoDpec := ""
    Local cMonitorSEF := ""
    Local cSugestao   := ""
    Local cURL        := PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local nX          := 0
    Local lOk         := .T.
    Local oWs
    Local oWizard

    If cSerie == Nil
        MV_PAR01 := aParam[01] := PadR(ParamLoad("SPEDNFEREM",aPerg,1,aParam[01]),Len(SF2->F2_SERIE))
        MV_PAR02 := aParam[02] := PadR(ParamLoad("SPEDNFEREM",aPerg,2,aParam[02]),Len(SF2->F2_DOC))
        MV_PAR03 := aParam[03] := PadR(ParamLoad("SPEDNFEREM",aPerg,3,aParam[03]),Len(SF2->F2_DOC))
    Else
        MV_PAR01 := aParam[01] := cSerie
        MV_PAR02 := aParam[02] := cNotaIni
        MV_PAR03 := aParam[03] := cNotaFim
    EndIf

    aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
    aadd(aPerg,{1,STR0011,aParam[02],"",".T.","",".T.",30,.T.})	//"Nota fiscal inicial"
    aadd(aPerg,{1,STR0012,aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"

    If .T. //IsReady()
        //������������������������������������������������������������������������Ŀ
        //�Obtem o codigo da entidade                                              �
        //��������������������������������������������������������������������������
        cIdEnt := GetIdEnt()
        If !Empty(cIdEnt)
            //������������������������������������������������������������������������Ŀ
            //�Obtem o ambiente de execucao do Totvs Services SPED                     �
            //��������������������������������������������������������������������������
            oWS := WsSpedCfgNFe():New()
            oWS:cUSERTOKEN := "TOTVS"
            oWS:cID_ENT    := cIdEnt
            oWS:nAmbiente  := 0
            oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
            lOk := oWS:CFGAMBIENTE()
            cAmbiente := oWS:cCfgAmbienteResult
            //������������������������������������������������������������������������Ŀ
            //�Obtem a modalidade de execucao do Totvs Services SPED                   �
            //��������������������������������������������������������������������������
            If lOk
                oWS:cUSERTOKEN := "TOTVS"
                oWS:cID_ENT    := cIdEnt
                oWS:nModalidade:= 0
                oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
                lOk := oWS:CFGModalidade()
                cModalidade    := oWS:cCfgModalidadeResult
            EndIf
            //������������������������������������������������������������������������Ŀ
            //�Obtem a versao de trabalho da NFe do Totvs Services SPED                �
            //��������������������������������������������������������������������������
            If lOk
                oWS:cUSERTOKEN := "TOTVS"
                oWS:cID_ENT    := cIdEnt
                oWS:cVersao    := "0.00"
                oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
                lOk := oWS:CFGVersao()
                cVersao        := oWS:cCfgVersaoResult
            EndIf
            If lOk
                oWS:cUSERTOKEN := "TOTVS"
                oWS:cID_ENT    := cIdEnt
                oWS:cVersao    := "0.00"
                oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
                lOk := oWS:CFGVersaoCTe()
                cVersaoCTe     := oWS:cCfgVersaoCTeResult
            EndIf
            If lOk
                oWS:cUSERTOKEN := "TOTVS"
                oWS:cID_ENT    := cIdEnt
                oWS:cVersao    := "0.00"
                oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
                lOk := oWS:CFGVersaoDpec()
                cVersaoDpec	   := oWS:cCfgVersaoDpecResult
            EndIf
            //������������������������������������������������������������������������Ŀ
            //�Verifica o status na SEFAZ                                              �
            //��������������������������������������������������������������������������
            If lOk
                oWS:= WSNFeSBRA():New()
                oWS:cUSERTOKEN := "TOTVS"
                oWS:cID_ENT    := cIdEnt
                oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
                lOk := oWS:MONITORSEFAZMODELO()
                If lOk
                    aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
                    For nX := 1 To Len(aXML)
                        Do Case
                        Case aXML[nX]:cModelo == "55"
                            cMonitorSEF += "- NFe"+CRLF
                            cMonitorSEF += STR0017+cVersao+CRLF	//"Versao do layout: "
                            If !Empty(aXML[nX]:cSugestao)
                                cSugestao += "Sugest�o (NFe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugest�o"
                            EndIf

                        Case aXML[nX]:cModelo == "57"
                            cMonitorSEF += "- CTe"+CRLF
                            cMonitorSEF += STR0017+cVersaoCTe+CRLF	//"Versao do layout: "
                            If !Empty(aXML[nX]:cSugestao)
                                cSugestao += "Sugestao(CTe)"+": "+aXML[nX]:cSugestao+CRLF //"Sugest�o"
                            EndIf
                        EndCase
                        cMonitorSEF += Space(6)+"Versao da mensagem: "+aXML[nX]:cVersaoMensagem+CRLF //"Vers�o da mensagem"
                        cMonitorSEF += Space(6)+"Codigo de Status: "+aXML[nX]:cStatusCodigo+"-"+aXML[nX]:cStatusMensagem+CRLF //"C�digo do Status"
                        cMonitorSEF += Space(6)+"UF Origem: "+aXML[nX]:cUFOrigem //"UF Origem"
                        If !Empty(aXML[nX]:cUFResposta)
                            cMonitorSEF += "("+aXML[nX]:cUFResposta+")"+CRLF //"UF Resposta"
                        Else
                            cMonitorSEF += CRLF
                        EndIf
                        If aXML[nX]:nTempoMedioSEF <> Nil
                            cMonitorSEF += Space(6)+"Tempo de Espera: "+Str(aXML[nX]:nTempoMedioSEF,6)+CRLF //"Tempo de espera"
                        EndIf
                        If !Empty(aXML[nX]:cMotivo)
                            cMonitorSEF += Space(6)+"Motivo: "+aXML[nX]:cMotivo+CRLF //"Motivo"
                        EndIf
                        If !Empty(aXML[nX]:cObservacao)
                            cMonitorSEF += Space(6)+"Observa��o: "+aXML[nX]:cObservacao+CRLF //"Observa��o"
                        EndIf
                    Next nX
                EndIf
            EndIf
            //������������������������������������������������������������������������Ŀ
            //� Montagem da Interface                                                  �
            //��������������������������������������������������������������������������
            If (lOk == .T. .or. lOk == Nil)
                aadd(aTexto,{})
                aTexto[1] := STR0013+" " //"Esta rotina tem como objetivo auxilia-lo na transmiss�o da Nota Fiscal eletr�nica para o servi�o Totvs Services SPED. "
                aTexto[1] += STR0014+CRLF+CRLF //"Neste momento o Totvs Services SPED, est� operando com a seguinte configura��o: "
                aTexto[1] += STR0015+cAmbiente+CRLF //"Ambiente: "
                aTexto[1] += STR0016+cModalidade+CRLF	//"Modalidade de emiss�o: "
                If !Empty(cSugestao)
                    aTexto[1] += CRLF
                    aTexto[1] += cSugestao
                    aTexto[1] += CRLF
                EndIf
                aTexto[1] += cMonitorSEF

                aadd(aTexto,{})
			/*
			DEFINE WIZARD oWizard ;
			TITLE STR0018;
			HEADER STR0019;
			MESSAGE STR0020;
			TEXT aTexto[1] ;
            NEXT {|| .T.} ;
			FINISH {||.T.}
			
			CREATE PANEL oWizard  ;
			HEADER STR0018 ;//"Assistente de transmiss�o da Nota Fiscal Eletr�nica"
			MESSAGE ""	;
			BACK {|| .T.} ;
            NEXT {|| ParamSave("SPEDNFEREM",aPerg,"1"),Processa({|lEnd| cRetorno := SpedNFeTrf(aArea[1],aParam[1],aParam[2],aParam[3],cIdEnt,cAmbiente,cModalidade,cVersao,@lEnd)}),aTexto[02]:= cRetorno,.T.} ;
			PANEL
			ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,oWizard:oMPanel[2],"SPEDNFEREM",.T.,.T.)
			
			CREATE PANEL oWizard  ;
			HEADER STR0018;//"Assistente de configura��o da Nota Fiscal Eletr�nica"
			MESSAGE "";
			BACK {|| .T.} ;
			FINISH {|| .T.} ;
			PANEL
			@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[3]
			ACTIVATE WIZARD oWizard CENTERED
			*/

        cRetorno := SpedNFeTrf(aArea[1],aParam[1],aParam[2],aParam[3],cIdEnt,cAmbiente,cModalidade,cVersao,@lEnd)
        aTexto[02]:= cRetorno

    EndIf
EndIf
Else

    Aviso("SPED","Execute o m�dulo de configura��o do servi�o, antes de utilizar esta op��o!!!",{'STR0114'},3) //"Execute o m�dulo de configura��o do servi�o, antes de utilizar esta op��o!!!"

EndIf

RestArea(aArea)
Return



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �SpedDanfe � Autor �Eduardo Riera          � Data �27.06.2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de chamada do WS de impressao da DANFE               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function mySpedDanfe(cIdEnt,_cSerie,_cNota)

    Local oDanfe
    Local nDevice
    Local cFilePrint := "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
    Local oSetup
    Local aDevice  := {}
    Local cSession     := GetPrinterSession()

//AADD(aDevice,"DISCO") // 1
    AADD(aDevice,"SPOOL") // 2
//AADD(aDevice,"EMAIL") // 3
//AADD(aDevice,"EXCEL") // 4
//AADD(aDevice,"HTML" ) // 5
    AADD(aDevice,"PDF"  ) // 6

    nLocal       	:= If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
    nOrientation 	:= If(GetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
    cDevice     	:= GetProfString(cSession,"PRINTTYPE","SPOOL",.T.)
    nPrintType      := aScan(aDevice,{|x| x == cDevice })

    If .T. //IsReady()

        dbSelectArea("SF2")
        RetIndex("SF2")
        dbClearFilter()

        lAdjustToLegacy := .F. // Inibe legado de resolu��o com a TMSPrinter
        oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)

        // ----------------------------------------------
        // Cria e exibe tela de Setup Customizavel
        // OBS: Utilizar include "FWPrintSetup.ch"
        // ----------------------------------------------
        //nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
        nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
        oSetup := FWPrintSetup():New(nFlags, "DANFE")
        // ----------------------------------------------
        // Define saida
        // ----------------------------------------------
        oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
        oSetup:SetPropert(PD_ORIENTATION , nOrientation)
        oSetup:SetPropert(PD_DESTINATION , nLocal)
        oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
        oSetup:SetPropert(PD_PAPERSIZE   , DMPAPER_A4)

        // ----------------------------------------------
        // Pressionado bot�o OK na tela de Setup
        // ----------------------------------------------
        If oSetup:Activate() == PD_OK // PD_OK =1
            //�������������������������������������������Ŀ
            //�Salva os Parametros no Profile             �
            //���������������������������������������������

            WriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
            WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
            WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

            If oSetup:GetProperty(PD_ORIENTATION) == 1
                //�������������������������������������������Ŀ
                //�Danfe Retrato DANFEII.PRW                  �
                //���������������������������������������������
                u_PrtNfeSef(cIdEnt,_cSerie,_cNota,oDanfe, oSetup, cFilePrint)

            Else
                //�������������������������������������������Ŀ
                //�Danfe Paisagem DANFEIII.PRW                �
                //���������������������������������������������
                u_DANFE_P1(cIdEnt,_cSerie,_cNota,oDanfe, oSetup)
            EndIf

        Else
            MsgInfo("Relat�rio cancelado pelo usu�rio.")
            Return
        Endif
    EndIf
    oDanfe := Nil
    oSetup := Nil

Return()


Static Function GetXML(cIdEnt,aIdNFe,cModalidade)

    Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
    Local oWS
    Local cRetorno   := ""
    Local cProtocolo := ""
    Local cRetDPEC   := ""
    Local cProtDPEC  := ""
    Local nX         := 0
    Local nY         := 0
    Local aRetorno   := {}
    Local aResposta  := {}
    Local aFalta     := {}
    Local aExecute   := {}
    Local nLenNFe
    Local nLenWS
    Local cDHRecbto  := ""
    Local cDtHrRec   := ""
    Local cDtHrRec1	 := ""
    Local nDtHrRec1  := 0
    Local dDtRecib	 :=	CToD("")
    Local cModTrans	 := ""
    Local cAviso	 := ""
    Local cErro		 := ""

    Private oDHRecbto

    If Empty(cModalidade)
        oWS := WsSpedCfgNFe():New()
        oWS:cUSERTOKEN := "TOTVS"
        oWS:cID_ENT    := cIdEnt
        oWS:nModalidade:= 0
        oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
        If oWS:CFGModalidade()
            cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
        Else
            cModalidade    := ""
        EndIf
    EndIf
    oWS:= WSNFeSBRA():New()
    oWS:cUSERTOKEN        := "TOTVS"
    oWS:cID_ENT           := cIdEnt
    oWS:oWSNFEID          := NFESBRA_NFES2():New()
    oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
    nLenNFe := Len(aIdNFe)
    For nX := 1 To nLenNFe
        //aadd(aRetorno,{"","",aIdNfe[nX][4]+aIdNfe[nX][5],"","",""})
        aadd(aRetorno,{"","",aIdNfe[nX][4]+aIdNfe[nX][5],"","","",CToD(""),""})
        aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nX][4]+aIdNfe[nX][5]
    Next nX
    oWS:nDIASPARAEXCLUSAO := 0
    oWS:_URL := AllTrim(cURL)+"/NFeSBRA.apw"

    If oWS:RETORNANOTASNX()
        If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0

            For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
                cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
                cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO
                cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
                ///////
                oNFeRet			:= XmlParser(cRetorno,"_",@cAviso,@cErro)
                cModTrans		:= IIf(Type("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT") <> "U",IIf (!Empty("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT"),oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT,1),1)
                //////

                If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
                    cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
                    cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
                EndIf
                //Tratamento para gravar a hora da transmissao da NFe
                If !Empty(cProtocolo)
                    oDHRecbto		:= XmlParser(cDHRecbto,"","","")
                    cDtHrRec		:= oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT
                    nDtHrRec1		:= RAT("T",cDtHrRec)

                    If nDtHrRec1 <> 0
                        cDtHrRec1 := SubStr(cDtHrRec,nDtHrRec1+1)
                        dDtRecib  := SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
                    EndIf

                    dbSelectArea("SF2")
                    dbSetOrder(1)
                    If MsSeek(xFilial("SF2")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
                        If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
                            RecLock("SF2")
                            SF2->F2_HORA := cDtHrRec1
                            MsUnlock()
                        EndIf
                    EndIf
                    dbSelectArea("SF1")
                    dbSetOrder(1)
                    If MsSeek(xFilial("SF1")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
                        If SF1->(FieldPos("F1_HORA"))<>0 .And. Empty(SF1->F1_HORA)
                            RecLock("SF1")
                            SF1->F1_HORA := cDtHrRec1
                            MsUnlock()
                        EndIf
                    EndIf
                EndIf
                nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})
                If nY > 0
                    aRetorno[nY][1] := cProtocolo
                    aRetorno[nY][2] := cRetorno
                    aRetorno[nY][4] := cRetDPEC
                    aRetorno[nY][5] := cProtDPEC
                    aRetorno[nY][6] := cDtHrRec1
                    ///
                    aRetorno[nY][7] := dDtRecib
                    aRetorno[nY][8] := cModTrans
                    //

                    aadd(aResposta,aIdNfe[nY])
                EndIf
                cRetDPEC := ""
                cProtDPEC:= ""
            Next nX
            For nX := 1 To Len(aIdNfe)
                If aScan(aResposta,{|x| x[4] == aIdNfe[nX,04] .And. x[5] == aIdNfe[nX,05] })==0
                    aadd(aFalta,aIdNfe[nX])
                EndIf
            Next nX
            If Len(aFalta)>0
                aExecute := GetXML(cIdEnt,aFalta,@cModalidade)
            Else
                aExecute := {}
            EndIf
            For nX := 1 To Len(aExecute)
                nY := aScan(aRetorno,{|x| x[3] == aExecute[nX][03]})
                If nY == 0
                    aadd(aRetorno,{aExecute[nX][01],aExecute[nX][02],aExecute[nX][03]})
                Else
                    aRetorno[nY][01] := aExecute[nX][01]
                    aRetorno[nY][02] := aExecute[nX][02]
                EndIf
            Next nX
        EndIf
    EndIf

Return(aRetorno)


Static Function IsReady(cURL,nTipo,lHelp)

    Local nX       := 0
    Local cHelp    := ""
    Local oWS
    Local lRetorno := .F.
    DEFAULT nTipo := 1
    DEFAULT lHelp := .F.
    If !Empty(cURL) .And. !PutMV("MV_SPEDURL",cURL)
        RecLock("SX6",.T.)
        SX6->X6_FIL     := xFilial( "SX6" )
        SX6->X6_VAR     := "MV_SPEDURL"
        SX6->X6_TIPO    := "C"
        SX6->X6_DESCRIC := "URL SPED NFe"
        MsUnLock()
        PutMV("MV_SPEDURL",cURL)
    EndIf
    SuperGetMv() //Limpa o cache de parametros - nao retirar
    DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
//������������������������������������������������������������������������Ŀ
//�Verifica se o servidor da Totvs esta no ar                              �
//��������������������������������������������������������������������������
    oWs := WsSpedCfgNFe():New()
    oWs:cUserToken := "TOTVS"
    oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
    If oWs:CFGCONNECT()
        lRetorno := .T.
    Else
        If lHelp
            Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"ATENCAO"},3)
        EndIf
        lRetorno := .F.
    EndIf
//������������������������������������������������������������������������Ŀ
//�Verifica se o certificado digital ja foi transferido                    �
//��������������������������������������������������������������������������
    If nTipo <> 1 .And. lRetorno
        oWs:cUserToken := "TOTVS"
        oWs:cID_ENT    := GetIdEnt()
        oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
        If oWs:CFGReady()
            lRetorno := .T.
        Else
            If nTipo == 3
                cHelp := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
                If lHelp .And. !"003" $ cHelp
                    Aviso("SPED",cHelp,{"ATENCAO"},3)
                    lRetorno := .F.
                EndIf
            Else
                lRetorno := .F.
            EndIf
        EndIf
    EndIf
//������������������������������������������������������������������������Ŀ
//�Verifica se o certificado digital ja foi transferido                    �
//��������������������������������������������������������������������������
    If nTipo == 2 .And. lRetorno
        oWs:cUserToken := "TOTVS"
        oWs:cID_ENT    := GetIdEnt()
        oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
        If oWs:CFGStatusCertificate()
            If Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0
                For nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
                    If oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nx]:DVALIDTO-30 <= Date()

                        Aviso("SPED","O certificado digital ir� vencer em: "+Dtoc(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO),{"ATENCAO"},3) //

                    EndIf
                Next nX
            EndIf
        EndIf
    EndIf

Return(lRetorno)

Static Function TRNF(cSerie,cNotaIni,cNotaFim,dDtIni,dDtfim)

    Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local aArea    := GetArea()
    Local cSerie   := cSerie
    Local cNotaIni := cNotaIni
    Local cNotaFim := cNotaFim
    Local dDtIni   := dDtIni
    Local dDtFim   := dDtFim

    Local lCTe     := .T.
    Local lRetorno := .F.
    Local cModalidade	:= ""
    Local cVersao		:= ""

    cIdEnt := GetIdEnt()

    oWS := WsSpedCfgNFe():New()
    oWS:cUSERTOKEN := "TOTVS"
    oWS:cID_ENT    := cIdEnt
    oWS:nAmbiente  := 0
    oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
    lOk := oWS:CFGAMBIENTE()
    cAmbiente := oWS:cCfgAmbienteResult
//������������������������������������������������������������������������Ŀ
//�Obtem a modalidade de execucao do Totvs Services SPED                   �
//��������������������������������������������������������������������������
    If lOk
        oWS:cUSERTOKEN := "TOTVS"
        oWS:cID_ENT    := cIdEnt
        oWS:nModalidade:= 0
        oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
        //lOk := oWS:CFGModalidade()
        lOk   := .T.
        //cModalidade    := oWS:cCfgModalidadeResult
        cModalidade    := "1"//oWS:cCfgModalidadeResult
    EndIf

//������������������������������������������������������������������������Ŀ
//�Obtem a versao de trabalho da NFe do Totvs Services SPED                �
//��������������������������������������������������������������������������
    If lOk
        oWS:cUSERTOKEN := "TOTVS"
        oWS:cID_ENT    := cIdEnt
        oWS:cVersao    := "0.00"
        oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
        lOk := oWS:CFGVersao()
        cVersao        := oWS:cCfgVersaoResult
    EndIf

    SpedNFeTrf(aArea[1],cSerie   ,cNotaIni ,cNotaFim ,cIdEnt,cAmbiente,cModalidade,cVersao,.T.  ,lCTe,.T.)
//SpedNFeTrf("SF2"   ,aParam[1],aParam[2],aParam[3],cIdEnt,cAmbiente,cModalidade,cVersao,@lEnd,.F. ,.T.)

Return


