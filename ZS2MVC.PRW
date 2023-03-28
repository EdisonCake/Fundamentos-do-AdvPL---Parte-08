#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function ZS2MVC
    Criação do Browse em MVC da tabela de Cadastro de Veículos utilizados na Auto-Escola.
    @type  Function
    @author Edison Cake
    @since 27/03/2023
    @version 1.0
    /*/
User Function ZS2MVC()
    local cAlias    := 'ZS2'
    local cTitle    := 'Veículos da Auto-Escola'
    local oBrowse   := FwmBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)
    
    oBrowse:DisableDetails()
    oBrowse:DisableReport()

    oBrowse:Activate()
Return 

Static Function MenuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir"  ACTION 'VIEWDEF.ZS2MVC' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"  ACTION 'VIEWDEF.ZS2MVC' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"  ACTION 'VIEWDEF.ZS2MVC' OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
    local oModel    := MPFormModel():New("ZS2MVC_M")
    local oStruZS2  := FWFormStruct(1, "ZS2")

    oModel:AddFields("ZS2MASTER",,oStruZS2)
    oModel:SetDescription("Cadastro de Veículos da Auto-Escola")

    oModel:SetPrimaryKey({"ZS2_CODVEI"})
Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel('ZS2MVC')
    local oStruZS2  := FwFormStruct(2, "ZS2")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZS2",  oStruZS2,  "ZS2MASTER")

    oView:CreateHorizontalBox("VEICULO", 50)
    oView:SetOwnerView("VIEW_ZS2", "VEICULO")
    oView:EnableTitleView("VIEW_ZS2",  "Cadastro de Veículos")
Return oView

/*/{Protheus.doc} User Function Cambio
    Lista de opções de câmbio para vínculo aos veículos cadastrados na ZS2MVC.
    @type  Function
    @author Edison Cake
    @since 27/03/2023
    /*/
User Function Cambio()
    local aArea := GetArea()
    local cCambio := ""

    cCambio += "001=MANUAL;"
    cCambio += "002=AUTOMÁTICO;"

    RestArea(aArea)
Return cCambio
