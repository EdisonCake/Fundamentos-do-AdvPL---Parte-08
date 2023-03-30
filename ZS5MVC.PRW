#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function ZS5MVC
    Programa de cadastro/exibição de registros do Condomínio Terras de Chromatica
    @type  Function
    @author Edison Cake
    @since 30/03/2023
    /*/
User Function ZS5MVC()
    local cAlias    := "ZS5"
    local cTitle    := "Terras de Chromática"
    local oBrowse   := FwMBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)

    oBrowse:DisableDetails()
    oBrowse:DisableReport()

    oBrowse:Activate()
Return 

Static Function MenuDef()
    local aBotoes := {}

    ADD OPTION aBotoes TITLE "Alterar"      ACTION 'VIEWDEF.ZS5MVC' OPERATION 4 ACCESS 0
    ADD OPTION aBotoes TITLE "Incluir"      ACTION 'VIEWDEF.CADZS5' OPERATION 3 ACCESS 0

Return aBotoes

Static Function ModelDef()
    local oModel    := MpFormModel():New("ZS5MVCM")
    local oStruZS5  := FwFormStruct(1, "ZS5")
    local oStruZS6  := FwFormStruct(1, "ZS6")
    local oStruZS7  := FwFormStruct(1, "ZS7")

    oStruZS5:SetProperty('ZS5_BLOCO', MODEL_FIELD_WHEN, {||.F.})
    oStruZS5:SetProperty('ZS5_DSCBLC', MODEL_FIELD_WHEN, {||.F.})
    
    oModel:AddFields("ZS5MASTER",,oStruZS5)
    oModel:AddGrid("ZS6DETAIL", "ZS5MASTER", oStruZS6)
    oModel:AddGrid("ZS7DETAIL", "ZS6DETAIL", oStruZS7)

    oModel:SetRelation('ZS6DETAIL', {{'ZS6_FILIAL', 'FwxFilial("ZS6")'}, {'ZS6_BLOCO', 'ZS5_BLOCO'}}, ZS6->(IndexKey(1)))
    oModel:SetRelation('ZS7DETAIL', {{'ZS7_FILIAL', 'FwxFilial("ZS7")'}, {'ZS7_APTO', 'ZS6_APTO'}}, ZS7->(IndexKey(1)))

    oModel:SetPrimaryKey({"ZS5_COD"})

    oStruZS5:SetProperty('ZS5_COD', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZS5", "ZS5_COD")'))
    
    oModel:GetModel("ZS6DETAIL"):SetUniqueLine({"ZS6_APTO"})

Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel('ZS5MVC')
    local oStruZS5  := FwFormStruct(2, "ZS5")
    local oStruZS6  := FwFormStruct(2, "ZS6")
    local oStruZS7  := FwFormStruct(2, "ZS7")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)

    oView:AddField("VIEW_ZS5", oStruZS5, "ZS5MASTER")
    oView:AddGrid("VIEW_ZS6", oStruZS6, "ZS6DETAIL")
    oView:AddGrid("VIEW_ZS7", oStruZS7, "ZS7DETAIL")

    oView:CreateHorizontalBox("CONDOMINIO", 30)
    oView:CreateHorizontalBox("APARTAMENTO", 30)
    oView:CreateHorizontalBox("MORADOR", 40)

    oView:SetOwnerView("VIEW_ZS5", "CONDOMINIO")
    oView:EnableTitleView("VIEW_ZS5", "Cadastro de Blocos do Condomínio")

    oView:SetOwnerView("VIEW_ZS6", "APARTAMENTO")
    oView:EnableTitleView("VIEW_ZS6", "Cadastro de Apartamentos do Condomínio")

    oView:SetOwnerView("VIEW_ZS7", "MORADOR")
    oView:EnableTitleView("VIEW_ZS7", "Cadastro de Moradores do Apartamento")

    oView:AddIncrementField("VIEW_ZS6", "ZS6_COD")
    oView:AddIncrementField("VIEW_ZS7", "ZS7_CODMOR")

Return oView
