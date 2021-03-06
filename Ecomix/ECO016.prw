#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ECO016
Visao Gerencial - Mapinha     
@since 16/09/20
@version 1.0
/*/

User Function ECO016()

    Local _aArea      := GetArea()
    Local _oBrowse    := FWMBrowse():New()
    Local _cFunBkp    := FunName()

    Private _aZ17Cab  := {'Z17_FILIAL','Z17_CODPLA','Z17_NOME','Z17_ORDEM','Z17_CONTAG','Z17_DESCGE','Z17_CTASUP','Z17_CLASSE'}

    SetFunName("ECO016")

    _oBrowse:SetAlias("Z17")
    _oBrowse:SetDescription('Visao Gerencial - Mapinha')
    // _oBrowse:SetFilterDefault("Z17->Z17_LINHA == '001'")
    _oBrowse:Activate()

    SetFunName(_cFunBkp)
    RestArea(_aArea)

Return(Nil)




Static Function MenuDef()

    Local _aMenu := {}

    //Adicionando op��es
    ADD OPTION _aMenu TITLE 'Pesquisar'  ACTION 'PesqBrw'        OPERATION 1                      ACCESS 0
    ADD OPTION _aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.ECO016' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION _aMenu TITLE 'Incluir'    ACTION 'VIEWDEF.ECO016' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION _aMenu TITLE 'Alterar'    ACTION 'VIEWDEF.ECO016' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION _aMenu TITLE 'Excluir'    ACTION 'VIEWDEF.ECO016' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return(_aMenu)



Static Function ModelDef()

    Local _oModel   := Nil
    Local _oStTmp   := FWFormModelStruct():New()
    Local _oStFilho := FWFormStruct(1, 'Z17')
    Local _bVldPos  := {|| u_VldZ17Tab()}
    Local _bVldCom  := {|| u_SaveZ17()}
    Local _aZ17Rel  := {}
    Local a

    //Adiciona a tabela na estrutura tempor�ria
    _oStTmp:AddTable('Z17', _aZ17Cab, "Cabecalho Z17")
    // _oStTmp:AddTable('Z17', {'X5_FILIAL', 'X5_CHAVE', 'X5_DESCRI'}, "Cabecalho Z17")

    For a := 1 to Len(_aZ17Cab)

        If _aZ17Cab[a] = 'Z17_FILIAL'
            _bIni := FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z17->Z17_FILIAL,FWxFilial('Z17'))" )
            _lObri:= .F.
        Else
            _bIni := FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Z17->"+_aZ17Cab[a]+",'')")
            _lObri:= .T.
        Endif

        If _aZ17Cab[a] = 'Z17_CLASSE'
            _aCombo := {'1=Sintetica','2=Analitica'}
        Else
            _aCombo := {}
        Endif

        // If _aZ17Cab[a] = 'Z17_ORDEM'
        //     _bValid := {||PADL(Alltrim(M->Z17_ORDEM),TAMSX3("Z17_ORDEM")[1],'0')}
        // Else
        //     _bValid := Nil
        // Endif

        _oStTmp:AddField(;
            FWSX3Util():GetDescription(_aZ17Cab[a]) ,;                                              // [01]  C   Titulo do campo
        FWSX3Util():GetDescription(_aZ17Cab[a]),;                                                   // [02]  C   ToolTip do campo
        _aZ17Cab[a],;                                                                               // [03]  C   Id do Field
        FWSX3Util():GetFieldType( _aZ17Cab[a] ),;                                                   // [04]  C   Tipo do campo
        TamSX3(_aZ17Cab[a])[1],;                                                                    // [05]  N   Tamanho do campo
        TamSX3(_aZ17Cab[a])[2],;                                                                    // [06]  N   Decimal do campo
        Nil,;                                                                                   // [07]  B   Code-block de valida��o do campo
        Nil,;                                                                                       // [08]  B   Code-block de valida��o When do campo
        _aCombo,;                                                                                   // [09]  A   Lista de valores permitido do campo
        _lObri,;                                                                                    // [10]  L   Indica se o campo tem preenchimento obrigat�rio
        _bIni,;                                                                                     // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
        .F.)                                                                                        // [14]  L   Indica se o campo � virtual
    Next a

    //Setando as propriedades na grid, o inicializador da Filial e Tabela, para n�o dar mensagem de coluna vazia
    _oStFilho:SetProperty('Z17_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    _oStFilho:SetProperty('Z17_CODPLA', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    _oStFilho:SetProperty('Z17_ORDEM' , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    _oStFilho:SetProperty('Z17_CONTAG', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))


    _aAux := FWStruTrigger("Z17_ORDEM"	,"Z17_ORDEM"	,"U_ECO16Gat()",.F.)
    _oStTmp:AddTrigger(_aAux[1],_aAux[2],_aAux[3],_aAux[4])


    //Criando o FormModel, adicionando o Cabe�alho e Grid
    _oModel := MPFormModel():New("ECO016M", , _bVldPos, _bVldCom)

    _oModel:AddFields("FORMCAB",/*cOwner*/,_oStTmp)
    _oModel:AddGrid('Z17DETAIL','FORMCAB',_oStFilho)

    //Adiciona o relacionamento de Filho, Pai
    aAdd(_aZ17Rel, {'Z17_FILIAL', 'Iif(!INCLUI, Z17->Z17_FILIAL, FWxFilial("Z17"))'} )
    aAdd(_aZ17Rel, {'Z17_CODPLA', 'Iif(!INCLUI, Z17->Z17_CODPLA,  "")'} )
    aAdd(_aZ17Rel, {'Z17_ORDEM' , 'Iif(!INCLUI, Z17->Z17_ORDEM,  "")'} )
    aAdd(_aZ17Rel, {'Z17_CONTAG', 'Iif(!INCLUI, Z17->Z17_CONTAG,  "")'} )

    //Criando o relacionamento
    _oModel:SetRelation('Z17DETAIL', _aZ17Rel, Z17->(IndexKey(1)))

    //Setando o campo �nico da grid para n�o ter repeti��o
    _oModel:GetModel('Z17DETAIL'):SetUniqueLine({'Z17_CODPLA','Z17_ORDEM','Z17_CONTAG','Z17_LINHA'})

    //Setando outras informa��es do Modelo de Dados
    _oModel:SetDescription("Cadastro Visao Gerencial - Mapinha")
    _oModel:SetPrimaryKey({})
    _oModel:GetModel("FORMCAB"):SetDescription("Cadastro Visao Gerencial - Mapinha")

    _oModel:GetModel( 'FORMCAB' ):SetOnlyView ( _oModel:GetOperation() != MODEL_OPERATION_INSERT)
    // oModel:GetModel( 'FORMCAB' ):SetOnlyView ( .T. )

Return _oModel




Static Function ViewDef()

    Local _oModel     := FWLoadModel("ECO016")
    Local _oStTmp     := FWFormViewStruct():New()
    Local _oStFilho   := FWFormStruct(2, 'Z17')
    Local _oView      := FWFormView():New()
    Local b,c
    Local _nOrdem     := 1

    For b := 2 to Len(_aZ17Cab)

        If _aZ17Cab[b] = 'Z17_CLASSE'
            _aCombo := {'1=Sintetica','2=Analitica'}
        Else
            _aCombo := {}
        Endif

        _nOrdem ++

        _oStTmp:AddField(;
            _aZ17Cab[b],;                           // [01]  C   Nome do Campo
        StrZero(_nOrdem,2),;                        // [02]  C   Ordem
        FWSX3Util():GetDescription(_aZ17Cab[b]),;   // [03]  C   Titulo do campo
        X3Descric(_aZ17Cab[b]),;                    // [04]  C   Descricao do campo
        Nil,;                                       // [05]  A   Array com Help
        FWSX3Util():GetFieldType( _aZ17Cab[b] ),;   // [06]  C   Tipo do campo
        X3Picture(_aZ17Cab[b]),;                    // [07]  C   Picture
        Nil,;                                       // [08]  B   Bloco de PictTre Var
        Nil,;                                       // [09]  C   Consulta F3
        .T.,;                                       // [10]  L   Indica se o campo � alteravel
        Nil,;                                       // [11]  C   Pasta do campo
        Nil,;                                       // [12]  C   Agrupamento do campo
        _aCombo,;                                   // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                                       // [14]  N   Tamanho maximo da maior op��o do combo
        Nil,;                                       // [15]  C   Inicializador de Browse
        Nil,;                                       // [16]  L   Indica se o campo � virtual
        Nil,;                                       // [17]  C   Picture Variavel
        Nil)                                        // [18]  L   Indica pulo de linha ap�s o campo
    Next b

    _oView:SetModel(_oModel)
    _oView:AddField("VIEW_CAB", _oStTmp, "FORMCAB")
    _oView:AddGrid('VIEW_Z17',_oStFilho,'Z17DETAIL')

    //Setando o dimensionamento de tamanho
    _oView:CreateHorizontalBox('CABEC',30)
    _oView:CreateHorizontalBox('GRID',70)

    //Amarrando a view com as box
    _oView:SetOwnerView('VIEW_CAB','CABEC')
    _oView:SetOwnerView('VIEW_Z17','GRID')

    _oView:AddIncrementField( 'VIEW_Z17', 'Z17_LINHA' )

    //Habilitando t�tulo
    _oView:EnableTitleView('VIEW_CAB','Cabe�alho - Visao Gerencial (Mapinha)')
    _oView:EnableTitleView('VIEW_Z17','Itens - Visao Gerencial (Mapinha)')

    //Tratativa padr�o para fechar a tela
    _oView:SetCloseOnOk({||.T.})

    //Remove os campos de Filial e Tabela da Grid
    For c := 1 to Len(_aZ17Cab)
        _oStFilho:RemoveField(_aZ17Cab[c])
    Next c

Return(_oView)


/*
User Function ECO016M()

    // Local _aParam   := PARAMIXB
    // Local _xRet     := .T.
    // Local _cIdPonto := ""

    // If _aParam <> NIL
    //     _oObj     := _aParam[1]
    //     _cIdPonto := _aParam[2]
    //     _cIdModel := _aParam[3]

    //     If _cIdPonto == "MODELVLDACTIVE"
    //         _nOper := _oObj:nOperation

    //         // cMsg := "Chamada na ativa��o do modelo de dados."

    //         // xRet := MsgYesNo(cMsg + "Continua?")
    //     EndIf
    // EndIf

    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := ''
    Local cIdPonto := ''

    Local cIdModel := ''
    Local lIsGrid := .F.
    Local nLinha := 0
    Local nQtdLinhas := 0
    Local cMsg := ''
    If aParam <> NIL
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := ( Len( aParam ) > 3 )
        If lIsGrid
            nQtdLinhas := oObj:GetQtdLine()
            nLinha := oObj:nLine
        EndIf
        If cIdPonto == 'MODELPOS'
            cMsg := 'Chamada na valida��o total do modelo (MODELPOS).' + CRLF
            cMsg += 'ID ' + cIdModel + CRLF
            If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
                Help( ,, 'Help',, 'O MODELPOS retornou .F.', 1, 0 )
            EndIf
        ElseIf cIdPonto == 'FORMPOS'
            cMsg := 'Chamada na valida��o total do formul�rio (FORMPOS).' + CRLF
            cMsg += 'ID ' + cIdModel + CRLF
            If cClasse == 'FWFORMGRID'
                cMsg += '� um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ;
                    ' linha(s).' + CRLF
                cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) + CRLF
            ElseIf cClasse == 'FWFORMFIELD'
                cMsg += '� um FORMFIELD' + CRLF
            EndIf
            If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
                Help( ,, 'Help',, 'O FORMPOS retornou .F.', 1, 0 )

            EndIf
        ElseIf cIdPonto == 'FORMLINEPRE'
            If aParam[5] == 'DELETE'
                cMsg := 'Chamada na pr� valida��o da linha do formul�rio (FORMLINEPRE).' + CRLF
                cMsg += 'Onde esta se tentando deletar uma linha' + CRLF
                cMsg += '� um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) +;
                    ' linha(s).' + CRLF
                cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) + CRLF
                cMsg += 'ID ' + cIdModel + CRLF
                If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
                    Help( ,, 'Help',, 'O FORMLINEPRE retornou .F.', 1, 0 )
                EndIf
            EndIf
        ElseIf cIdPonto == 'FORMLINEPOS'
            cMsg := 'Chamada na valida��o da linha do formul�rio (FORMLINEPOS).' + CRLF
            cMsg += 'ID ' + cIdModel + CRLF
            cMsg += '� um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ;
                ' linha(s).' + CRLF
            cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) + CRLF
            If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
                Help( ,, 'Help',, 'O FORMLINEPOS retornou .F.', 1, 0 )
            EndIf
        ElseIf cIdPonto == 'MODELCOMMITTTS'
            ApMsgInfo('Chamada apos a grava��o total do modelo e dentro da transa��o (MODELCOMMITTTS).' + CRLF + 'ID ' + cIdModel )
        ElseIf cIdPonto == 'MODELCOMMITNTTS'
            ApMsgInfo('Chamada apos a grava��o total do modelo e fora da transa��o (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel)
//ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
        ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
            ApMsgInfo('Chamada apos a grava��o da tabela do formul�rio (FORMCOMMITTTSPOS).' + CRLF + 'ID ' + cIdModel)
        ElseIf cIdPonto == 'MODELCANCEL'
            cMsg := 'Chamada no Bot�o Cancelar (MODELCANCEL).' + CRLF + 'Deseja Realmente Sair ?'
            If !( xRet := ApMsgYesNo( cMsg ) )
                Help( ,, 'Help',, 'O MODELCANCEL retornou .F.', 1, 0 )
            EndIf
        ElseIf cIdPonto == 'MODELVLDACTIVE'
            cMsg := 'Chamada na valida��o da ativa��o do Model.' + CRLF + 'Continua ?'
            If !( xRet := ApMsgYesNo( cMsg ) )
                Help( ,, 'Help',, 'O MODELVLDACTIVE retornou .F.', 1, 0 )
            EndIf
        ElseIf cIdPonto == 'BUTTONBAR'
            ApMsgInfo('Adicionando Bot�o na Barra de Bot�es (BUTTONBAR).' + CRLF + 'ID ' + cIdModel )
            xRet := { {'Salvar', 'SALVAR', { || Alert( 'Salvou' ) }, 'Este bot�o Salva' } }
        EndIf
    EndIf
Return(xRet)
*/



Static Function VldChange(_oModel)

    Local _lRet       := .F.
    // Local _oModelDad  := FWModelActive()
    Local _nOpc       := _oModel:GetOperation()

    If _nOpc == MODEL_OPERATION_INSERT
        _lRet := .T.
    Endif
// Iif(INCLUI, .T., .F.)

Return(_lRet)





User Function VldZ17Tab()

    Local _aArea      := GetArea()
    Local _lRet       := .T.
    Local _oModelDad  := FWModelActive()
    Local _Z17FILIAL  := _oModelDad:GetValue('FORMCAB', 'Z17_FILIAL')
    Local _Z17CODPLA  := _oModelDad:GetValue('FORMCAB', 'Z17_CODPLA')
    Local _Z17ORDEM   := _oModelDad:GetValue('FORMCAB', 'Z17_ORDEM')
    Local _Z17CONTAG  := _oModelDad:GetValue('FORMCAB', 'Z17_CONTAG')
    Local _nOpc       := _oModelDad:GetOperation()

    //Se for Inclus�o
    If _nOpc == MODEL_OPERATION_INSERT

        DbSelectArea('Z17')
        Z17->(DbSetOrder(1)) //X5_FILIAL + X5_TABELA + X5_CHAVE

        //Se conseguir posicionar, tabela j� existe
        If Z17->(MsSeek(_Z17FILIAL + _Z17CODPLA + _Z17ORDEM + _Z17CONTAG))
            Aviso('Aten��o', 'Esse c�digo de Vis�o j� existe!', {'OK'}, 02)
            _lRet := .F.
        EndIf
    EndIf

    RestArea(_aArea)

Return(_lRet)




User Function SaveZ17()

    Local d,e
    Local _aArea      := GetArea()
    Local _lRet       := .T.
    Local _nAtual     := 0
    Local _oModelDad  := FWModelActive()
    Local _oModelGrid := _oModelDad:GetModel( 'Z17DETAIL' )
    Local _nOpc       := _oModelDad:GetOperation()
    Local _aHeadAux   := _oModelGrid:aHeader
    Local _Z17CODPLA  := _oModelDad:GetValue( 'FORMCAB' , 'Z17_CODPLA' )
    Local _Z17CONTAG  := _oModelDad:GetValue( 'FORMCAB' , 'Z17_CONTAG' )
    Local _Z17FILIAL  := _oModelDad:GetValue( 'FORMCAB' , 'Z17_FILIAL' )
    Local _Z17ORDEM   := _oModelDad:GetValue( 'FORMCAB' , 'Z17_ORDEM' )

    DbSelectArea('Z17')
    Z17->(DbSetOrder(1))

    //Se for Inclus�o
    If _nOpc == MODEL_OPERATION_INSERT

        //Percorre as linhas da grid
        For _nAtual := 1 To _oModelGrid:Length()

            _oModelGrid:GoLine(_nAtual)

            If !_oModelGrid:IsDeleted()

                Z17->(RecLock('Z17', .T.))
                For d := 1 to Len(_aZ17Cab)
                    &('Z17->'+_aZ17Cab[d]) := _oModelDad:GetValue('FORMCAB', _aZ17Cab[d])
                Next d

                For e := 1 to Len(_aHeadAux)

                    If aScan(_aZ17Cab, Alltrim(_aHeadAux[e][2])) = 0
                        &('Z17->'+Alltrim(_aHeadAux[e][2])) := _oModelGrid:GetValue(Alltrim(_aHeadAux[e][2]))
                    Endif
                Next e

                Z17->(MsUnlock())
            EndIf
        Next

        //Se for Altera��o
    ElseIf _nOpc == MODEL_OPERATION_UPDATE

        For _nAtual := 1 To _oModelGrid:Length()

            _oModelGrid:GoLine(_nAtual)

            _cLinha := _oModelGrid:GetValue('Z17_LINHA')

            If _oModelGrid:IsDeleted()
                //Se conseguir posicionar, exclui o registro
                If Z17->(MsSeek(_Z17FILIAL + _Z17CODPLA + _Z17ORDEM + _Z17CONTAG + _cLinha))
                    Z17->(RecLock('Z17', .F.))
                    Z17->(DbDelete())
                    Z17->(MsUnlock())
                EndIf

            Else
                //Se conseguir posicionar no registro, ser� altera��o
                If Z17->(MsSeek(_Z17FILIAL + _Z17CODPLA + _Z17ORDEM + _Z17CONTAG + _cLinha))
                    Z17->(RecLock('Z17', .F.))
                Else
                    Z17->(RecLock('Z17', .T.))
                EndIf

                For d := 1 to Len(_aZ17Cab)
                    &('Z17->'+_aZ17Cab[d]) := _oModelDad:GetValue('FORMCAB', _aZ17Cab[d])
                Next d

                For e := 1 to Len(_aHeadAux)
                    If aScan(_aZ17Cab, Alltrim(_aHeadAux[e][2])) = 0
                        &('Z17->'+Alltrim(_aHeadAux[e][2])) := _oModelGrid:GetValue(Alltrim(_aHeadAux[e][2]))
                    Endif
                Next e

                Z17->(MsUnlock())
            EndIf
        Next

        //Se for Exclus�o
    ElseIf _nOpc == MODEL_OPERATION_DELETE

        //Percorre a grid
        For _nAtual := 1 To _oModelGrid:Length()

            _oModelGrid:GoLine(_nAtual)

            _cLinha := _oModelGrid:GetValue('Z17_LINHA')

            //Se conseguir posicionar, exclui o registro
            If Z17->(MsSeek(_Z17FILIAL + _Z17CODPLA + _Z17ORDEM + _Z17CONTAG + _cLinha))
                Z17->(RecLock('Z17', .F.))
                Z17->(DbDelete())
                Z17->(MsUnlock())
            EndIf
        Next
    EndIf

    //Se n�o for inclus�o, volta o INCLUI para .T. (bug ao utilizar a Exclus�o, antes da Inclus�o)
    If _nOpc != MODEL_OPERATION_INSERT
        INCLUI := .T.
    EndIf

    RestArea(_aArea)

Return _lRet




User Function ECO16Gat()

    Local _Area 	:= GetArea()
    Local _oModel	:= FWModelActive()
    Local _oView	:= FWViewActive()
    Local _cRet		:= ''

    _cRet := PADL(Alltrim(_oModel:GetValue('FORMCAB',"Z17_ORDEM")),TAMSX3("Z17_ORDEM")[1],'0')

    _oModel:SetValue('FORMCAB','Z17_ORDEM',_cRet )

    _oView:Refresh()

    Restarea(_Area)

Return(_cRet)
