#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function ZS3MVC
    Criação do Browse em MVC da tabela de Cadastros de Instrutores da Auto Escola
    @type  Function
    @author Edison Cake
    @since 27/03/2023
    @version 1.0
    /*/
User Function ZS3MVC()
    local cAlias    := 'ZS3'
    local cTitle    := 'Instrutores da Auto-Escola'
    local oMark   := FwMarkBrowse():New()

    private cIdInstrutor

    oMark:SetAlias(cAlias)
    oMark:SetDescription(cTitle)

    oMark:SetFieldMark('ZS3_MARC')
    oMark:AddButton("Excluir Marcados", "u_DelZS3", 5, 1)
    
    oMark:DisableDetails()
    oMark:DisableReport()

    oMark:Activate()
Return 

Static Function MenuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir"  ACTION 'VIEWDEF.ZS3MVC' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"  ACTION 'VIEWDEF.ZS3MVC' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"  ACTION 'VIEWDEF.ZS3MVC' OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
    local oModel    := MPFormModel():New("ZS3MVC_M",, {|oModel| ValidPos(oModel)} )
    local oStruZS3  := FWFormStruct(1, "ZS3")

    oModel:AddFields("ZS3MASTER",,oStruZS3)

    oModel:SetDescription("Cadastro de Instrutores da Auto-Escola")

    oModel:SetPrimaryKey({"ZS3_COD"})
Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel('ZS3MVC')
    local oStruZS3  := FwFormStruct(2, "ZS3")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZS3",  oStruZS3,  "ZS3MASTER")

    oView:CreateHorizontalBox("INSTRUTOR", 50)
    oView:SetOwnerView("VIEW_ZS3", "INSTRUTOR")
    oView:EnableTitleView("VIEW_ZS3",  "Cadastro de Instrutores")
Return oView

/*/{Protheus.doc} User Function DelZS3
    Função que exclui todos os instrutores marcados, exceto os que possuem um ou mais alunos registrados.
    @type  Function
    @author Edison Cake
    @since 27/03/2023
    @version 1.0
    /*/
User Function DelZS3()
  If MsgYesNo("Confirma a exclusão?", "Tem certeza?")
    DbSelectArea("ZS3")

      ZS3->(DbGoTop())

      While !ZS3->(EoF())
          if oMark:IsMark() .and. ((ZS3->ZS3_QTDALU) == 0)
              RecLock("ZS3", .F.)
                ZS3->(DbDelete())
              ZS3->(MsUnlock())
          endif

          ZS3->(DbSkip())
      End Do

      oMark:Refresh(.T.)
  endif
Return

/*/{Protheus.doc} User Function Escola
    Lista/Combo que exibe as opções a selecionar
    @type  Function
    @author Edison Cake
    @since 27/03/2023
    @version 1.0
    /*/
User Function Escola()
    local cEscola := ""

    cEscola += "001=Ensino Fundamental;"
    cEscola += "002=Ensino Médio;"
    cEscola += "003=Ensino Superior;"

Return cEscola

// Validação de cadastro de instrutor e deleção.
Static Function ValidPos(oModel)
    local nOper     := oModel:GetOperation()
    local lRet      := .T.
    local dNasc     := oModel:GetValue("ZS3MASTER", "ZS3_DTNASC")
    local dHabi     := oModel:GetValue("ZS3MASTER", "ZS3_DTHAB")
    local cEscola   := oModel:GetValue("ZS3MASTER", "ZS3_ESCOLA")

    if (nOper == MODEL_OPERATION_INSERT) .AND. ((((year(Date()) - year(dNasc)) < 21)) .OR. ((year(Date()) - year(dHabi) < 2)) .OR. (cEscola == "001"))
        lRet := .F.
        Help(NIL, NIL, 'Não é possível cadastrar o/a instrutor(a).', NIL, 'Informações não aceitas pelo RH da Auto-Escola', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Contrate um(a) novo(a) instrutor(a).'})

    elseif (nOper == MODEL_OPERATION_DELETE) .and. (ZS3_QTDALU > 0)
        lRet := .F.

        Help(NIL, NIL, 'Atenção.', NIL, 'Instrutor não pode ser excluído.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Remova os vínculos com aluno e tente novamente.'})
    endif

Return lRet


