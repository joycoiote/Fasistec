#INCLUDE "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NS0069    � Autor � Fabiano da Silva  � Data �  06/10/11    ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro Codigo Fornecedor no C�digo Produto               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function PXH010()

Local cVldAlt := ".T."
Local cVldExc := ".T."

Private cString := "SZ6"

dbSelectArea("SZ6")
dbSetOrder(1)

AxCadastro(cString,"Tipo Conta Contabil",cVldExc,cVldAlt)

Return (Nil)