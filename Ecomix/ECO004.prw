#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ECO004
//proposta Comercial
@author Fabiano
@since 02/07/20
@version 1.0

@type function
/*/
User Function ECO004()

	Private _oBrowse 	:= FwMBrowse():New()

	//Alias do Browse
	_oBrowse:SetAlias('ZE0')

	// Defini��o da legenda
	// _oBrowse:AddLegend( "ZL_DIF > 0" , "Green", "Molde em Produ��o" )
	// _oBrowse:AddLegend( "ZL_DIF <= 0", "Red"  , "Molde Bloqueado" )

	//Descri��o da Parte Superior Esquerda do Browse
	_oBrowse:SetDescripton("Proposta Comercial")

	//Ativa o Browse
	_oBrowse:Activate()

Return(NIL)



Static Function MenuDef()

	Local _aMenu :=	{}

	ADD OPTION _aMenu TITLE 'Pesquisar'  ACTION 'PesqBrw'       			OPERATION 1 ACCESS 0
	ADD OPTION _aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.ECO004'			OPERATION 2 ACCESS 0
	ADD OPTION _aMenu TITLE 'Incluir'    ACTION 'VIEWDEF.ECO004'			OPERATION 3 ACCESS 0
	ADD OPTION _aMenu TITLE 'Alterar'    ACTION 'VIEWDEF.ECO004'			OPERATION 4 ACCESS 0
	ADD OPTION _aMenu TITLE 'Excluir'    ACTION 'VIEWDEF.ECO004'			OPERATION 5 ACCESS 0
	ADD OPTION _aMenu TITLE 'Imprimir'   ACTION 'U_ECO003(ZE0->ZE0_PROPOS)'	OPERATION 2 ACCESS 0

Return(_aMenu)



Static Function ModelDef()

	// Cria as estruturas a serem usadas no Modelo de Dados
	Local _oStruZE0 := FWFormStruct( 1, 'ZE0' )
	Local _oStruZE1 := FWFormStruct( 1, 'ZE1' )
	Local _oModel

	// Cria o objeto do Modelo de Dados
	_oModel := MPFormModel():New('ECO04PE',/*Pre-Validacao*/,/*Pos-Validacao*/ ,/*Commit*/,/*Cancel*/)

	// Adiciona a descri��o do Modelo de Dados
	_oModel:SetDescription( 'Proposta Comercial' )

	_oModel:AddFields( 'ZE0MASTER', /*cOwner*/, _oStruZE0 )

	_oModel:SetPrimaryKey({})

	// Adiciona ao modelo uma componente de grid
	_oModel:AddGrid( 'ZE1GRID', 'ZE0MASTER', _oStruZE1 )

	// Faz relacionamento entre os componentes do model
	_oModel:SetRelation( 'ZE1GRID', { { 'ZE1_FILIAL', 'xFilial( "ZE1" )' }, { 'ZE1_PROPOS','ZE0_PROPOS' } }, ZE1->( IndexKey( 1 ) ) )

	// Adiciona a descri��o dos Componentes do Modelo de Dados
	_oModel:GetModel( 'ZE0MASTER' ):SetDescription( 'Proposta Comercial' )
	_oModel:GetModel( 'ZE1GRID' ):SetDescription( 'Itens Proposta Comercial' )
	// Retorna o Modelo de dados

	// _oModel:GetModel( 'ZE1GRID' ):SetNoInsertLine(.T.)
	// _oModel:GetModel( 'ZE1GRID' ):SetOptional( .T. )

Return _oModel



Static Function ViewDef()

	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local _oModel 	:= FWLoadModel( 'ECO004' )
	Local _oModelZE0:= _oModel:GetModel( 'ZE0MASTER' )

	// Cria as estruturas a serem usadas na View
	Local _oStruZE0 := FWFormStruct( 2, 'ZE0' )
	Local _oStruZE1 := FWFormStruct( 2, 'ZE1' )
	Local _nOpc		:= _oModel:GetOperation()

	// Interface de visualiza��o constru�da
	Local _oView

	_oView := FWFormView():New()

	// Define qual Modelo de dados ser� utilizado
	_oView:SetModel( _oModel )

	// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)AdvPl utilizando MVC � 27
	_oView:AddField( 'VIEW_ZE0', _oStruZE0, 'ZE0MASTER' )

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	_oView:AddGrid( 'VIEW_ZE1', _oStruZE1, 'ZE1GRID' )

	// Cria um "box" horizontal para receber cada elemento da view
	_oView:CreateHorizontalBox( 'P01', 40 )
	_oView:CreateHorizontalBox( 'P02', 60 )


	_oView:SetOwnerView( 'VIEW_ZE0', 'P01' )
	_oView:SetOwnerView( 'VIEW_ZE1', 'P02' )

	_oView:EnableTitleView( 'VIEW_ZE0' )
	_oView:EnableTitleView( 'VIEW_ZE1', "Itens Proposta Comercial" )

	_oStruZE1:RemoveField( 'ZE1_PROPOS' )

	_oModel:Activate()

	_oModel:DeActivate()

Return(_oView)