#INCLUDE "TOTVS.CH"

/*
Fun��o			:	PXH080
Autor			:	Fabiano da Silva
Data 			: 	17.06.2015 
Descri��o		: 	Cadastro de Solicitante
*/

User Function PXH080()

	local cVldAlt := ".T." // Operacao: ALTERACAO
	local cVldExc := ".T." // Operacao: EXCLUSAO

	//If cEmpAnt = "16"	
		chkFile("SZJ")

		ZAG->(dbSetOrder(1))
		axCadastro("SZJ", "Cadastro de Solicitantes", cVldExc, cVldAlt)
	//Else
	// 	MsgInfo("Esta Rotina s� pode ser acessada pela empresa 16!")
	//Endif
	
return
