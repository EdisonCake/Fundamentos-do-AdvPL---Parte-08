#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function ZS1MVC
    Criação do Browse em MVC da tabela de Cadastro de Categoria de CNH
    @type  Function
    @author Edison Cake
    @since 27/03/2023
    @version 1.0
    /*/
User Function ZS1MVC()
    local cAlias    := 'ZS1'
    local cTitle    := 'Categorias de CNH'
    local oBrowse   := FwmBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)
    
    oBrowse:DisableDetails()
    oBrowse:DisableReport()

    oBrowse:Activate()
Return 

Static Function MenuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir"  ACTION 'VIEWDEF.ZS1MVC' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"  ACTION 'VIEWDEF.ZS1MVC' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"  ACTION 'VIEWDEF.ZS1MVC' OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
    local bPre := {|oCampo, cAction, cIdCampo, xValue| Sigla(oCampo, cAction, cIdCampo, xValue)}
    
    local oModel    := MPFormModel():New("ZS1MVC_M")
    local oStruZS1  := FWFormStruct(1, "ZS1")

    oStruZS1:SetProperty('ZS1_CODCAT', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZS1", "ZS1_CODCAT")')) 

    // Gatilho de preenchimento de nome do veículo selecionado.
    local aGat1 := FwStruTrigger('ZS1_CODVEI', 'ZS1_NOMVEI', 'ZS2->ZS2_NOMVEI', .T., 'ZS2', 1, 'xFilial("ZS2")+ALLTRIM(M->ZS1_CODVEI)')
    oStruZS1:AddTrigger(aGat1[1], aGat1[2], aGat1[3], aGat1[4])

    oModel:AddFields("ZS1MASTER",,oStruZS1,bPre)
    oModel:SetDescription("Cadastro de Categorias de CNH")

    oModel:SetPrimaryKey({"ZS1_CODCAT"})
Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel('ZS1MVC')
    local oStruZS1  := FwFormStruct(2, "ZS1")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZS1",  oStruZS1,  "ZS1MASTER")
    oView:CreateHorizontalBox("CNH", 50)

    oView:SetOwnerView("VIEW_ZS1",  "CNH")
    oView:EnableTitleView("VIEW_ZS1",  "Cadastro de CNH")

Return oView

// Função de validação de sigla. Se a mesma possuir apenas dois caracteres, não será aceita.
Static Function Sigla(oCampo, cAction, cIdCampo, xValue)
    local lRet := .T.
    
    if cAction == "SETVALUE" .AND. cIdCampo
        If len(ZS1_SIGLA) == 2
            lRet := .F.
            Help(NIL, NIL, "Entrada inválida!", NIL, "Sigla com número de caracteres inválido", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique as informações de entrada e tente novamente."})
        endif

Return lRet
