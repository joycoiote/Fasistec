#INCLUDE "PROTHEUS.CH"

/*
Programa	:	MT010INC
Autor		:	Fabiano da Silva
Data		: 	30/01/13
Descri��o	:	Ponto de entrada executado ap�s a inclus�o do Produto.
utilizado para gerar os Dados Adicionais (SB5)
*/

User Function MT010INC()

	Local aCab := {}
	Private lMsErroAuto := .F.

	_aAliORI  := GetArea()
	_aAliSB5  := SB5->(GetArea())
	_aAliSB1  := SB1->(GetArea())

	CG1->(dbsetOrder(1))
	If CG1->(dbSeek(xFilial("CG1")+LEFT(SB1->B1_POSIPI,8)))

		_cCod 		:= SB1->B1_COD
		_cNome		:= SB1->B1_DESC
		_cInsPat	:= "1"
		_cCodAti	:= CG1->CG1_CODIGO

		aCab:= { 	{"B5_COD"   	,_cCod  	,Nil},;		// Codigo identificador do produto
		{"B5_CEME"  	,_cNome 	,Nil},;		// Nome cientifico do produto
		{"B5_INSPAT"   	,_cInsPat 	,Nil},;		// INSS patronal
		{"B5_CODATIV"  	,_cCodAti 	,Nil}}		// C�digo de atividade

		MSExecAuto({|x,y| Mata180(x,y)},aCab,3) //Inclusao

		conout("Acabou de executar a rotina automatica do Cadastro de Complemento do Produto")//-- Retorno de erro na execucao da rotina

		If lMsErroAuto
			conout("erro")
			cErro:=MostraErro()
		Else
			conout("Ok")
		Endif

	Endif

	RestArea(_aAliSB1)
	RestArea(_aAliSB5)
	RestArea(_aAliOri)

	Return()
