#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CR0015    �                               � Data � 16.10.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tela de cadastramento Responsavel p/ Romaneio Expedicao     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CR0015()

Local cVldAlt := ".T."
Local cVldExc := ".T."

AxCadastro("SZK","Responsavel Romaneio Expedicao",cVldExc,cVldAlt)

//AxCadastro("SZK","Responsavel Romaneio Expedicao","U_CR015A()")

Return


User Function CR015A()

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

