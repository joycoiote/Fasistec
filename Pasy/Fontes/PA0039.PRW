#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PA0039    � Autor � Alexandro da Silva � Data �  02/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Tabela de Produtos Komatsu                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function Pa0039()

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZ5"

dbSelectArea("SZ5")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Amarracao de Demandas",cVldAlt,cVldExc)

Return