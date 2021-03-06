#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PA0139    �Autor  �Fabiano da Silva    � Data �  17/08/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilho para gerar numero autom�tico no Contas a Pagar     ���
���          � Quando o Tipo for ND ou CI                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/               

User Function PA0139()

_cAliOri := Alias()
_nOrdORI := IndexOrd()
_nRecORI := Recno()

_cTipo    := ""
_cNum     := ""
dbSelectArea("SE2")

_cAliSE2 := Alias()
_nOrdSE2 := IndexOrd()
_nRecSE2 := Recno()
/*
dbOrderNickname("INDSE21")
If dbSeek(xFilial("SE2")+"CI ")

	dbselectArea("SE2")
	dbOrderNickname("INDSE21")
	dbSeek(xFilial("SE2")+"CN ")

	dbSkip(-1)
	
 	_cNum := SE2->E2_NUM
     
Endif

_cNum := SOMA1(_cNum)
*/

_cNUm := ""
If M->E2_TIPO = "CI"
	_cNum := GETSXENUM("SE2","E2_NUM",16)
Endif


dbSelectArea(_cAliSE2)
dbSetOrder(_nOrdSE2)
dbGoto(_nRecSE2)

dbSelectArea(_cAliORI)
dbSetOrder(_nOrdORI)
dbGoto(_nRecORI)

Return(_cNum)