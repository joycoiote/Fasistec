#include "rwmake.ch" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �PA0128  � Autor �   Fabiano da Silva      � Data � 27.03.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Produtividade                                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � SIGAEST                                                    ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/


User Function PA0128()

SetPrvt("ARADIO,NRADIO")

aRadio := {"Relatorio ","Grafico Individual","Grafico por Prensa (Valor)"}
nRadio := 1

@ 0,0   TO 110,270 DIALOG oDlg1 TITLE "Produtividade"
@ 03,03 TO 50,100 TITLE ""
@ 20,10 RADIO aRadio VAR nRadio                             

@ 10,105 BMPBUTTON TYPE 6 ACTION VerProg()
@ 30,105 BMPBUTTON TYPE 2 ACTION Close(oDlg1)

ACTIVATE DIALOG oDlg1 CENTER

Return


Static Function VerProg()

If nRadio == 1 
	Close(oDlg1)
	U_PA0119()
ElseIf nRadio == 2
	Close(oDlg1)
	U_PA0124()
ElseIf nRadio == 3
	Close(oDlg1)
	U_PA0153()
Endif

Return
