#include "protheus.ch"
#include "restful.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"
#Include 'PRTOPDEF.ch'
#include "fwmvcdef.ch"

 
WSRESTFUL listasrcall DESCRIPTION "Controle De Alcada"
	WsData cID	AS String

    WSMETHOD GET  listasrcall DESCRIPTION 'Listar Controle De Alcada'      WSSYNTAX '/listasrcall' PATH '/listasrcall'
END WSRESTFUL
 
WSMETHOD GET listasrcall WSRECEIVE cID WSREST listasrcall

Local cJsonRet := ''
Local nItems   := 0
Local cID      := ::cId

cQuery := " SELECT SC1.R_E_C_N_O_ SC1REG, ISNULL(SC7.R_E_C_N_O_,0) SC7REG, CR_STATUS,CR_TIPO,CR_NUM,CR_USER, CR_APROV, CR_GRUPO, CR_EMISSAO, CR_NIVEL, CR_TOTAL,  CR_DATALIB, CR_VALLIB "
cQuery += " FROM " + RetSqlName("SCR") + " SCR "
cQuery += " INNER JOIN " + RetSqlName("DBM") + " DBM ON DBM_FILIAL = CR_FILIAL AND DBM_NUM = CR_NUM AND DBM.D_E_L_E_T_ = '' "
cQuery += " LEFT  JOIN " + RetSqlName("SC1") + " SC1 ON CR_TIPO = 'SC' AND C1_FILIAL = DBM_FILIAL AND C1_NUM = DBM_NUM AND C1_ITEM = DBM_ITEM AND SC1.D_E_L_E_T_ = '' "
cQuery += " LEFT  JOIN " + RetSqlName("SC7") + " SC7 ON CR_TIPO = 'PC' AND C7_FILIAL = DBM_FILIAL AND C7_NUM = DBM_NUM AND C7_ITEM = DBM_ITEM AND SC7.D_E_L_E_T_ = '' "
cQuery += " WHERE CR_FILIAL = '" + xFilial("SCR") + "' AND CR_TIPO IN ('SC', 'PC') AND CR_APROV = '" + Alltrim(cId) + "' AND SCR.D_E_L_E_T_ = ''

cQrySCR := GetNextAlias()
cJsonRet := '{"alcadas": { "items": [{'

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySCR,.F.,.T.) 
DbSelectArea(cQrySCR)
(cQrySCR)->(DbGoTop())

While ( cQrySCR )->( ! Eof() )
    If nItems > 0
        cJsonRet += ","
    EndIf
    cJsonRet += '["Status": "'+( cQrySCR )->CR_STATUS+'",' 
    cJsonRet += '"Tipo": "'+( cQrySCR )->CR_TIPO+'",' 
    cJsonRet += '"DsTipo": "'+IIF(( cQrySCR )->CR_TIPO=='SC','Solicitacao Pedido','Pedido De Compra')+'",' 
    cJsonRet += '"id":  "'+Alltrim(( cQrySCR )->CR_NUM)+'",'
    cJsonRet += '"User": "'+( cQrySCR )->CR_USER+'",'
    cJsonRet += '"Aprov": "'+( cQrySCR )->CR_APROV+'",'
    cJsonRet += '"Nivel": "'+( cQrySCR )->CR_NIVEL+'",'
    cJsonRet += '"Emissao": "'+dtoc(stod(( cQrySCR )->CR_EMISSAO))+'",'
    cJsonRet += '"DataLib": "'+dtoc(stod(( cQrySCR )->CR_DATALIB))+'",'
    cJsonRet += '"Total": '+Str(( cQrySCR )->CR_TOTAL)+''
    If ( cQrySCR )->SC1REG > 0 
        DbSelectArea('SC1')
        DbGoto(( cQrySCR )->SC1REG)
        cJsonRet += ',"Tabela": "SC",'
        cJsonRet += ',"Item": "'+Alltrim(SC1->C1_ITEM)+'",'
        cJsonRet += '"Produto": "'+Alltrim(SC1->C1_PRODUTO)+'",'
        cJsonRet += '"Um": "'+SC1->C1_UM+'",'
        cJsonRet += '"Descri": "'+SC1->C1_DESCRI+'",'
        cJsonRet += '"Quant": '+Str(SC1->C1_QUANT)
    ElseIf ( cQrySCR )->SC7REG > 0  
        DbSelectArea('SC7')
        DbGoto(( cQrySCR )->SC7REG)
        cJsonRet += ',"Tabela": "PC",'
        cJsonRet += ',"Item": "'+SC7->C7_ITEM+'",'
        cJsonRet += '"Produto": "'+SC7->C7_PRODUTO+'",'
        cJsonRet += '"Um": "'+SC7->C7_UM+'",'
        cJsonRet += '"Descri": "'+SC7->C7_DESCRI+'",'
        cJsonRet += '"Quant": '+Str(SC7->C7_QUANT)
    EndIf
    cJsonRet += ']'
    DbSelectArea(cQrySCR)
    nItems ++
    (cQrySCR)->(DBSkip())
End
cJsonRet += '}}}'

Self:SetContentType("application/json")
Self:SetResponse(cJsonRet)
Return(.T.)
 

WSRESTFUL listasrc DESCRIPTION "Controle De Alcada"

	WsData cTabela	AS String
	WsData cID	AS String

    WSMETHOD GET  listasrc DESCRIPTION    'Listar Registros de Alcada'     WSSYNTAX '/listasrc' PATH '/listasrc'
END WSRESTFUL

WSMETHOD GET listasrc WSRECEIVE cTabela, cID WSREST listasrc

Local cJsonRet := ''
Local nItems   := 0
Local cID      := ::cId
Local cTabela  := ::cTabela

cQuery := " SELECT "
If cTabela = "SC"
    cQuery += "SC1.R_E_C_N_O_ SC1REG, "
ElseIf cTabela = "PC"
    cQuery += "ISNULL(SC7.R_E_C_N_O_,0) SC7REG, "
EndIf
cQuery += " CR_STATUS,CR_TIPO,CR_NUM,CR_USER, CR_APROV, CR_GRUPO, CR_EMISSAO, CR_NIVEL, CR_TOTAL,  CR_DATALIB, CR_VALLIB "
cQuery += " FROM " + RetSqlName("SCR") + " SCR "
cQuery += " INNER JOIN " + RetSqlName("DBM") + " DBM ON DBM_FILIAL = CR_FILIAL AND DBM_NUM = CR_NUM AND DBM.D_E_L_E_T_ = '' "
If cTabela = "SC"
    cQuery += " LEFT  JOIN " + RetSqlName("SC1") + " SC1 ON CR_TIPO = 'SC' AND C1_FILIAL = DBM_FILIAL AND C1_NUM = DBM_NUM AND C1_ITEM = DBM_ITEM AND SC1.D_E_L_E_T_ = '' "
ElseIf cTabela = "PC"
    cQuery += " LEFT  JOIN " + RetSqlName("SC7") + " SC7 ON CR_TIPO = 'PC' AND C7_FILIAL = DBM_FILIAL AND C7_NUM = DBM_NUM AND C7_ITEM = DBM_ITEM AND SC7.D_E_L_E_T_ = '' "
EndIf
cQuery += " WHERE CR_FILIAL = '" + xFilial("SCR") + "' AND CR_TIPO = '" + cTabela + "' AND CR_NUM = '" + cId + "' AND SCR.D_E_L_E_T_ = ''

cQrySCR := GetNextAlias()
cJsonRet := '{"alcadas": { "items": [{'

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySCR,.F.,.T.) 
DbSelectArea(cQrySCR)
(cQrySCR)->(DbGoTop())

While ( cQrySCR )->( ! Eof() )
    If nItems > 0
        cJsonRet += ","
    EndIf
    cJsonRet += '["Status": "'+( cQrySCR )->CR_STATUS+'",' 
    cJsonRet += '"Tipo": "'+( cQrySCR )->CR_TIPO+'",' 
    cJsonRet += '"DsTipo": "'+IIF(( cQrySCR )->CR_TIPO=='SC','Solicitacao Pedido','Pedido De Compra')+'",' 
    cJsonRet += '"id":  "'+Alltrim(( cQrySCR )->CR_NUM)+'",'
    cJsonRet += '"User": "'+( cQrySCR )->CR_USER+'",'
    cJsonRet += '"Aprov": "'+( cQrySCR )->CR_APROV+'",'
    cJsonRet += '"Nivel": "'+( cQrySCR )->CR_NIVEL+'",'
    cJsonRet += '"Emissao": "'+dtoc(stod(( cQrySCR )->CR_EMISSAO))+'",'
    cJsonRet += '"DataLib": "'+dtoc(stod(( cQrySCR )->CR_DATALIB))+'",'
    cJsonRet += '"Total": '+Str(( cQrySCR )->CR_TOTAL)+''
    If cTabela = "SC" .And. ( cQrySCR )->SC1REG > 0 
        DbSelectArea('SC1')
        DbGoto(( cQrySCR )->SC1REG)
        cJsonRet += ',"Item": "'+Alltrim(SC1->C1_ITEM)+'",'
        cJsonRet += '"Produto": "'+Alltrim(SC1->C1_PRODUTO)+'",'
        cJsonRet += '"Um": "'+SC1->C1_UM+'",'
        cJsonRet += '"Descri": "'+SC1->C1_DESCRI+'",'
        cJsonRet += '"Quant": '+Str(SC1->C1_QUANT)
    ElseIf cTabela = "PC" .And. ( cQrySCR )->SC7REG > 0  
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
    nItems ++
    (cQrySCR)->(DBSkip())
End
cJsonRet += '}}}'

Self:SetContentType("application/json")
Self:SetResponse(cJsonRet)
Return(.T.)
