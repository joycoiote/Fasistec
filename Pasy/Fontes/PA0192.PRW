#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PA0192    � Autor � Fabiano da Silva      � Data � 16.10.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tela de cadastramento Responsavel p/ Romaneio Expedicao     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  

User Function Pa0192()

Local cVldAlt := ".T."
Local cVldExc := ".T."

AxCadastro("SZK","Cadastro de Regras de Contabiliza��o",cVldExc,cVldAlt)

//AxCadastro("SZK","Responsavel Romaneio Expedicao","U_PA192A()")

Return


User Function PA192A()

_aAliOri2:= GetArea()
_aAliSZJ := SZJ->(GetArea())
_lRet    := .T.

dbSelectArea("SZJ")
dbSetOrder(5)
If dbSeek(xFilial("SZJ")+SZK->ZK_CODIGO)
   MSGBOX("Cadastro ja Possui Movimento e nao Pode ser Excluido!!!","Informacao","INFO")
   _lRet := .F.
Endif

RestArea(_aAliSZJ)
RestArea(_aAliOri2)

Return(_lRet)   

