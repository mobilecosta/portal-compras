#include "protheus.ch"
#include "restful.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"
#Include 'PRTOPDEF.ch'
#include "fwmvcdef.ch"

 
WSRESTFUL listasrc DESCRIPTION "Listar Registro Controle De Alcada" FORMAT APPLICATION_JSON
 
    WSMETHOD GET   listasrc DESCRIPTION 'Controle De Alcada'      WSSYNTAX '/listasrc' PATH '/listasrc' PRODUCES APPLICATION_JSON
END WSRESTFUL
 
 
****************************************************** 
WSMETHOD GET listasrc WSRECEIVE  WSREST listasrc

Local cJson         := Self:GetContent()
Local cJsonRet      := ''

Self:SetContentType("application/json")
oJson   := JsonObject():New()
cError  := oJson:FromJson(cJson)
IF !Empty(cError)
    SetRestFault(400, 'Erro no envio dos dados: '+cError)
    Return( .F. )
EndIf

cQuery := " SELECT SC1.R_E_C_N_O_ SC1REG, ISNULL(SC7.R_E_C_N_O_,0) SC7REG, CR_STATUS,CR_TIPO,CR_NUM,CR_USER, CR_APROV, CR_GRUPO, CR_EMISSAO, CR_NIVEL, CR_TOTAL,  CR_DATALIB, CR_VALLIB "
cQuery += " FROM " + RetSqlName("SCR") + " SCR "
cQuery += " INNER JOIN " + RetSqlName("DBM") + " DBM ON DBM_FILIAL = CR_FILIAL AND DBM_NUM = CR_NUM AND DBM.D_E_L_E_T_ = '' "
cQuery += " LEFT  JOIN " + RetSqlName("SC1") + " SC1 ON CR_TIPO = 'SC' AND C1_FILIAL = DBM_FILIAL AND C1_NUM = DBM_NUM AND C1_ITEM = DBM_ITEM AND SC1.D_E_L_E_T_ = '' "
cQuery += " LEFT  JOIN " + RetSqlName("SC7") + " SC7 ON CR_TIPO = 'PC' AND C7_FILIAL = DBM_FILIAL AND C7_NUM = DBM_NUM AND C7_ITEM = DBM_ITEM AND SC1.D_E_L_E_T_ = '' "
cQuery += " WHERE CR_NUM = '000290'
cQuery += " AND CR_APROV = '" + Alltrim(oJson:GetJsonObject('CR_APROV')) + "' "
cQuery += " AND SCR.D_E_L_E_T_ = ''

cQrySCR := GetNextAlias()
cJsonRet := '{'

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySCR,.F.,.T.) 
DbSelectArea(cQrySCR)
(cQrySCR)->(DbGoTop())

While ( cQrySCR )->( ! Eof() )
    cJsonRet += IIF(cJsonRet=='{','[',',[') 
    cJsonRet += '"Status": "'+( cQrySCR )->CR_STATUS+'",' 
    cJsonRet += '"Tipo": "'+( cQrySCR )->CR_TIPO+'",' 
    cJsonRet += '"DsTipo": "'+IIF(( cQrySCR )->CR_TIPO=='SC','Solicitacao Pedido','Pedido De Compra')+'",' 
    cJsonRet += '"Num":  "'+Alltrim(( cQrySCR )->CR_NUM)+'",'
    cJsonRet += '"User": "'+( cQrySCR )->CR_USER+'",'
    cJsonRet += '"Aprov": "'+( cQrySCR )->CR_APROV+'",'
    cJsonRet += '"Nivel": "'+( cQrySCR )->CR_NIVEL+'",'
    cJsonRet += '"Emissao": "'+dtoc(stod(( cQrySCR )->CR_EMISSAO))+'",'
    cJsonRet += '"DataLib": "'+dtoc(stod(( cQrySCR )->CR_DATALIB))+'",'
    cJsonRet += '"Total": '+Str(( cQrySCR )->CR_TOTAL)+''
    If ( cQrySCR )->SC1REG > 0 
        DbSelectArea('SC1')
        DbGoto(( cQrySCR )->SC1REG)
        cJsonRet += ',"Item": "'+Alltrim(SC1->C1_ITEM)+'",'
        cJsonRet += '"Produto": "'+Alltrim(SC1->C1_PRODUTO)+'",'
        cJsonRet += '"Um": "'+SC1->C1_UM+'",'
        cJsonRet += '"Descri": "'+SC1->C1_DESCRI+'",'
        cJsonRet += '"Quant": '+Str(SC1->C1_QUANT)
    ElseIf ( cQrySCR )->SC7REG > 0  
        DbSelectArea('SC7')
        DbGoto(( cQrySCR )->SC7REG)
        cJsonRet += ',"Item": "'+SC7->C7_ITEM+'",'
        cJsonRet += '"Produto": "'+SC7->C7_PRODUTO+'",'
        cJsonRet += '"Um": "'+SC7->C7_UM+'",'
        cJsonRet += '"Descri": "'+SC7->C7_DESCRI+'",'
        cJsonRet += '"Quant": '+Str(SC7->C7_QUANT)
    EndIf
    cJsonRet += ']'
    DbSelectArea(cQrySCR)
    (cQrySCR)->(DBSkip())
End
cJsonRet += '}'
 
Self:SetResponse(cJsonRet)
Return(.T.)
 
