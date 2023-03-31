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

    oBrowse:AddLegend('ZF1_COMPLE == .T.', 'GREEN',   'Tarefa concluída',     '1')
    oBrowse:AddLegend('ZF1_COMPLE == .F.', 'RED',     'Tarefa não concluída', '1')

    oBrowse:AddLegend('ZF1_TIPO == "001"', 'PINK',    'Tarefa do tipo "Pessoal"',     '2')
    oBrowse:AddLegend('ZF1_TIPO == "002"', 'ORANGE',  'Tarefa do tipo "Trabalho"',    '2')
    oBrowse:AddLegend('ZF1_TIPO == "003"', 'BLUE',    'Tarefa do tipo "Estudos"',     '2')

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

    local bPre      := {|oGrid| PreLine(oGrid)}
    local bConclui  := {|oGrid| Conclui(oGrid)}

    oStruZF1:SetProperty('ZF1_COD', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZF1", "ZF1_COD")'))

    oModel:AddFields("ZF1MASTER",,oStruZF1)
    oModel:SetDescription("LISTA DE TAREFAS")
    oModel:AddGrid("ZF2DETAIL", "ZF1MASTER", oStruZF2, bPre,/* bLinePos */, /* bGridPre */,  bConclui)

    oModel:GetModel("ZF2DETAIL"):SetDescription("Subtarefas a Fazer")

    oModel:SetRelation("ZF2DETAIL", {{"ZF2_FILIAL", "FwxFilial('ZF2')"}, {"ZF2_TAREFA", "ZF1_COD"}}, ZF2->(IndexKey(1)))

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

Static Function PreLine(oGrid)
    local lRet      := .T.
    local cTarefa   := FwFldGet("ZF1_COD")
    
    oGrid:LoadValue("ZF2_TAREFA", cTarefa)

Return lRet

/*/{Protheus.doc} User Function Tipo
    Combo box para o tipo de tarefa
    @type  Function
    @author Edison Cake
    @since 31/03/2023
    /*/
User Function Tipo()
    local cTipo := ""

    cTipo += "001=PESSOAL;"
    cTipo += "002=TRABALHO;"
    cTipo += "003=ESTUDOS;"

Return cTipo

Static Function Conclui(oGrid)
    local cTarefa   := FwFldGet("ZF1_COD")
    local nLinhas   := oGrid:Length()
    local nCount    := 0
    local nMark     := 0
    local lMark

    For nCount := 1 to oGrid:Length()
        oGrid:GoLine(nCount)
        lMark := oGrid:GetValue("ZF2_MARK")

        if !oGrid:IsDeleted() .and. lMark
            nMark++
        endif
    Next

    If nMark == nLinhas
        If DbSeek(xFilial("ZF1")+cTarefa)
            ZF1->(RECLOCK("ZF1", .F.))
                ZF1->ZF1_COMPLE := .T.
            ZF1->(MSUNLOCK())
        Endif
    Else
        If DbSeek(xFilial("ZF1")+cTarefa)
            ZF1->(RECLOCK("ZF1", .F.))
                ZF1->ZF1_COMPLE := .F.
            ZF1->(MSUNLOCK())
        Endif

    Endif

Return

