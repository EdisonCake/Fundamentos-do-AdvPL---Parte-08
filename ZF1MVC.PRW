#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function ZF1MVC
    Função MVC para o Modelo
    @type  Function
    @author user
    @since 30/03/2023
    /*/
User Function ZF1MVC()
    local cAlias    := 'ZF1'
    local cTitle    := 'To-Do! List'
    local oBrowse   := FwmBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)
    
    oBrowse:DisableDetails()
    oBrowse:DisableReport()

    oBrowse:Activate()
Return 

Static Function MenuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar"       ACTION 'VIEWDEF.ZF1MVC' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Nova Tarefa"      ACTION 'VIEWDEF.ZF1MVC' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"          ACTION 'VIEWDEF.ZF1MVC' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Deletar Tarefa"   ACTION 'VIEWDEF.ZF1MVC' OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
    local oModel    := MPFormModel():New("MENU")
    local oStruZF1  := FWFormStruct(1, "ZF1")
    local oStruZF2  := FWFormStruct(1, "ZF2")

    oStruZF1:SetProperty('ZF1_COD', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZF1", "ZF1_COD")'))

    oModel:AddFields("ZF1MASTER",,oStruZF1)
    oModel:SetDescription("LISTA DE TAREFAS")
    oModel:AddGrid("ZF2DETAIL", "ZF1MASTER", oStruZF2)

    oModel:GetModel("ZF2DETAIL"):SetDescription("Subtarefas a Fazer")

    oModel:SetRelation("ZF2DETAIL", {{"ZF2_FILIAL", "FwxFilial('ZF2')"}, {"ZF2_COD", "ZF1_COD"}}, ZF2->(IndexKey(1)))

    oModel:SetPrimaryKey({"ZF1_COD"})
Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel('ZF1MVC')
    local oStruZF1  := FwFormStruct(2, "ZF1")
    local oStruZF2  := FwFormStruct(2, "ZF2")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZF1",  oStruZF1,  "ZF1MASTER")

    oView:AddGrid("VIEW_ZF2", oStruZF2, "ZF2DETAIL")

    oView:CreateHorizontalBox("TAREFA", 50)
    oView:CreateHorizontalBox("SUBTAREFA", 50)

    oView:SetOwnerView("VIEW_ZF1",  "TAREFA")
    oView:SetOwnerView("VIEW_ZF2",  "SUBTAREFA")

    oView:EnableTitleView("VIEW_ZF1",  "Lista de Tarefas")
    oView:EnableTitleView("VIEW_ZF2",  "Subtarefas")

    oView:AddIncrementField("VIEW_ZF2", "ZF2_COD")
Return oView

