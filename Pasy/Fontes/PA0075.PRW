#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PA0075    � Autor � Alexandro da Silva    � Data � 14.11.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tela de cadastramento De Roteiro de Processo                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  

User Function Pa0075()

_aAliOri := GetArea()

Private cVldAlt := .T.
Private cVldVis := .T.
Private cVldExc := .T. 


AxCadastro("SZA","Cadastro de Turno","U_VERMOVSZA()")

RestArea(_aAliOri)

Return

User Function VerMovSZA()

_aAliOri2:= GetArea()
_aAliSZ6 := SZ6->(GetArea())
_lRet    := .T.

dbSelectArea("SZ6")
dbSetOrder(3)
If dbSeek(xFilial("SZ6")+SZA->ZA_CODIGO)
   MSGBOX("Cadastro ja Possui Movimento e nao Pode ser Excluido!!!","Informacao","INFO")
   _lRet := .F.
Endif

RestArea(_aAliSZ6)
RestArea(_aAliOri2)

Return(_lRet)   

