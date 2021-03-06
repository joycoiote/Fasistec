#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � GATFIN   � Autor � Marcus Vinicius       � Data � 22/06/16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gatilho para valida��o do campo E2_VENCTO                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � FINANCEIRO                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function GFIN001()

_aAliOri := GetArea()	// Salva o ambiente ativo
cRet	:= .T.          

IF !INCLUI	// Se ALTERA ou EXCLUI
	IF U_PXH042("E2_VENCTO",6)    // Verifica se tem acesso para editar o campo E2_VENCTO
		IF (M->E2_VENCTO < DATE() .And. !M->E2_TIPO $ "PAM*NCF*NDF")	// Valida a data impedindo que d� continuidade cado a data inseria seja menor que a data atual
			ALERT("DATA NAO PODE SER MENOR QUE ATUAL")					// Exibe alerta
			cRet := .F.													// Retorna Falso
		ENDIF
	ELSE
		cRet := .F.
	ENDIF
ENDIF

RestArea(_aAliOri)		// Restaura um ambiente salvo anteriormente pela fun��o GETAREA().

Return(cRet)    

//---------------------------------------------------------------------------------------------------------------------------
//		Marcus Vinicius - 22/06/2016 - Solicitado por Larissa Duarte Chamado: 24697
//---------------------------------------------------------------------------------------------------------------------------