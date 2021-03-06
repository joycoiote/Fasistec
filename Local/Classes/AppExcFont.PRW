/*
Copyright 2015 AppSoft - Fabrica de Software

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#Include "Totvs.ch"                        

/*/{Protheus.doc} AppExcFont
Classe fornecedora de m�todos para gerenciamento de fontes para o XML Excel
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0
@type class
/*/
CLASS AppExcFont FROM LongClassName
	DATA cFontName 	AS STRING HIDDEN
	DATA cSize	   	AS STRING HIDDEN
	DATA cColor		AS STRING HIDDEN
	DATA lBold		AS BOOLEAN HIDDEN
	DATA lItalic	AS BOOLEAN HIDDEN
	DATA lUnderLine AS BOOLEAN HIDDEN

	//Class Properties
	DATA cClassName AS STRING HIDDEN
	
	METHOD NEW() CONSTRUCTOR
	METHOD SetFontName(cFontPar)
	METHOD SetSize(xSizePar)	
	METHOD SetColor(cColorPar)
	METHOD SetBold(lBoldPar)
	METHOD SetItalic(lItalicPar)
	METHOD SetUnderLine(lUnderPar)
	METHOD FontToString() 	           
	
	//Class Properties
	METHOD Destroy()  
	METHOD ClassName()
	
ENDCLASS                           

/*/{Protheus.doc} AppExcFont:New
M�todo construtor da classe AppExcFont
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0                        
@type method
@param [cFontPar], caractere, nome da fonte que ser� utilizada
@param [cSizePar], caractere, tamanho da fonte
@param [cColorPar], caractere, cor da fonte no padr�o hexadecimal
/*/
METHOD NEW(cFontPar,cSizePar,cColorPar) CLASS AppExcFont         
	DEFAULT cFontPar  := "Calibri"
	DEFAULT cSizePar  := "11"
	DEFAULT cColorPar := "#000000" 
	
	::cClassName := "AppExcFont"
    
	::SetFontName(cFontPar)
	::SetSize(cSizePar)	
	::SetColor(cColorPar)
	::SetBold(.F.)
	::SetItalic(.F.)
	::SetUnderLine(.F.)
	
RETURN
   

/*/{Protheus.doc} AppExcFont:SetFontName
M�todo para alterar a fonte a ser utilizada 
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0                        
@type method
@param cFontPar, caractere, nome da fonte que ser� utilizada
/*/
METHOD SetFontName(cFontPar) CLASS AppExcFont
	::cFontName := cFontPar
RETURN
               
/*/{Protheus.doc} AppExcFont:SetSize
M�todo para alterar o tamanho da fonte
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0                        
@type method
@param xSizePar, caractere/inteiro, tamanho da fonte
/*/
METHOD SetSize(xSizePar) CLASS AppExcFont	
	If ValType(xSizePar) == "N" 
		::cSize := cValToChar(xSizePar)
	Else
		::cSize := xSizePar
	EndIf
RETURN
                                                      

/*/{Protheus.doc} AppExcFont:SetColor
M�todo para alterar a cor da fonte
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0                        
@type method
@param cColorPar, caractere, cor da fonte no padr�o hexadecimal
/*/
METHOD SetColor(cColorPar) CLASS AppExcFont
	::cColor := cColorPar
RETURN                   
   

/*/{Protheus.doc} AppExcFont:SetBold
M�todo para ativar/desativar a fonte em negrito
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0                        
@param lBoldPar, l�gico, indica se a fonte ser� em negrito
@type method
/*/
METHOD SetBold(lBoldPar) CLASS AppExcFont    
	::lBold := lBoldPar
RETURN                 
   

/*/{Protheus.doc} AppExcFont:SetItalic
M�todo para ativar/desativar a fonte em it�lico
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0                        
@type method
@param lItalicPar, l�gico, indica se a fonte ser� em it�lico
/*/
METHOD SetItalic(lItalicPar) CLASS AppExcFont
	::lItalic := lItalicPar
RETURN
                                               

/*/{Protheus.doc} AppExcFont:SetUnderLine
M�todo para ativar/desativar a fonte sublinhada
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0                        
@type method
@param lUnderPar, l�gico, indica se a fonte ser� sublinhada
/*/
METHOD SetUnderLine(lUnderPar) CLASS AppExcFont
	::lUnderLine := lUnderPar
RETURN                   
                       
  
/*/{Protheus.doc} AppExcFont:FontToString
Serializa��o da formata��o da fonte da c�lula para o padr�o XML Excel
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0     
@type method
@param nRow, inteiro, n�mero da linha que ser� serializada
@return caractere, String contendo a formata��o da fonte da c�lula especificada no padr�o XML
/*/
METHOD FontToString() CLASS AppExcFont
	Local cFont := ""	
	
	cFont := '<Font ss:FontName="'+::cFontName+'" ss:Size="'+::cSize+'" ss:Color="'+::cColor+'"'
	           
	If ::lBold
		cFont += ' ss:Bold="1"' 
	EndIf
	
	If ::lItalic
		cFont += ' ss:Italic="1"' 
	EndIf	    
	          
	If ::lUnderLine 
		cFont += ' ss:Underline="Single"'
	EndIf
    
    cFont += ' />'
    
RETURN cFont                        

  
/*/{Protheus.doc} AppExcFont:ClassName
M�todo respons�vel por retornar o nome da classe
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0     
@type method
@return caractere, retorna o nome da classe
/*/
METHOD ClassName() CLASS AppExcFont
RETURN ::cClassName

  
/*/{Protheus.doc} AppExcFont:Destroy
M�todo destrutor do objeto, respons�vel pela desaloca��o da mem�ria
@author Anderson Toledo - anderson@appsoft.com.br
@since 18/02/2014
@version 1.0     
@type method
/*/
METHOD Destroy() CLASS AppExcFont                       
	FreeObj(self)
RETURN 