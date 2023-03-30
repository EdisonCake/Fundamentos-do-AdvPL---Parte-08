#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function CADZS5
    Programa de cadastro/exibição de registros dos blocos do Condomínio Terras de Chromatica
    @type  Function
    @author Edison Cake
    @since 30/03/2023
    /*/
User Function CADZS5()
    local cAlias    := "ZS5"
    local cTitle    := "Blocos do Terra de Chromática"
    local oBrowse   := FwMBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)

    oBrowse:DisableDetails()
    oBrowse:DisableReport()

    oBrowse:Activate()
Return 

Static Function MenuDef()
    local aBotoes := {}

    ADD OPTION aBotoes TITLE "Visualizar"   ACTION 'VIEWDEF.CADZS5' OPERATION 2 ACCESS 0
    ADD OPTION aBotoes TITLE "Incluir"      ACTION 'VIEWDEF.CADZS5' OPERATION 3 ACCESS 0
    ADD OPTION aBotoes TITLE "Alterar"      ACTION 'VIEWDEF.CADZS5' OPERATION 4 ACCESS 0
    ADD OPTION aBotoes TITLE "Excluir"      ACTION 'VIEWDEF.CADZS5' OPERATION 5 ACCESS 0

Return aBotoes

Static Function ModelDef()
    local oModel    := MpFormModel():New("CADZS5M")
    local oStruZS5  := FwFormStruct(1, "ZS5")
    
    oModel:AddFields("ZS5MASTER",,oStruZS5)

    oModel:SetPrimaryKey({"ZS5_COD"})

    oStruZS5:SetProperty('ZS5_COD', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZS5", "ZS5_COD")'))

Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel('CADZS5')
    local oStruZS5  := FwFormStruct(2, "ZS5")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)

    oView:AddField("VIEW_ZS5", oStruZS5, "ZS5MASTER")

    oView:CreateHorizontalBox("CONDOMINIO", 50)

    oView:SetOwnerView("VIEW_ZS5", "CONDOMINIO")
    oView:EnableTitleView("VIEW_ZS5", "Cadastro de Blocos do Condomínio")

Return oView
