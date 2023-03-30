#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function ZS4MVC
    Criação do Browse em MVC da tabela de Cadastro de Alunos da Auto Escola
    @type  Function
    @author Edison Cake
    @since 27/03/2023
    @version 1.0
    /*/
User Function ZS4MVC()
    local cAlias    := 'ZS4'
    local cTitle    := 'Alunos da Auto-Escola'
    local cCampo    := 'ZS4_MARC'
    local oMark     := FwMarkBrowse():New()

    private cIdInstrutor := ""

    oMark:SetAlias(cAlias)
    oMark:SetDescription(cTitle)

    oMark:SetFieldMark(cCampo)
    oMark:AddButton("Excluir Marcados", "u_DelZS4", 5, 1)
    oMark:AddButton("Encerrar Aulas",   "u_FimZS4",,   1)
    
    oMark:DisableDetails()
    oMark:DisableReport()

    oMark:Activate()
Return 

Static Function MenuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE "Incluir"  ACTION 'VIEWDEF.ZS4MVC' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"  ACTION 'VIEWDEF.ZS4MVC' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"  ACTION 'VIEWDEF.ZS4MVC' OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
    // Pós-validação de modelo, que valida a exclusão de um aluno individual.
    local bModelPos := {|oModel| ValExc(oModel)}

    local oModel    := MPFormModel():New("ZS4MVC_M",, bModelPos)
    local oStruZS4  := FWFormStruct(1, "ZS4")

    // Gatilho de preenchimento de nome do instrutor escolhido para a aula.
    local aGatilho  := FwStruTrigger("ZS4_CODINS", "ZS4_NOMINS", "ZS3->ZS3_NOME", .T., "ZS3", 1, "xFilial('ZS3')+ALLTRIM(M->ZS4_CODINS)")
    oStruZS4:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

    // Bloco que "seta" as propriedades de inicializador padrão do código do aluno.
    oStruZS4:SetProperty('ZS4_CODALU',  MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZS4", "ZS4_CODALU")'))

    // Bloco de validação para código do instrutor.
    oStruZS4:SetProperty('ZS4_CODINS',  MODEL_FIELD_VALID, { |oModel| ValInstru(oModel)})

    // Bloco de validação para o CPF do aluno cadastrado.
    oStruZS4:SetProperty('ZS4_CPF',     MODEL_FIELD_VALID, { |oModel| ValidaCPF(oModel)})

    // Código de validação do campo aula.
    oStruZS4:SetProperty('ZS4_AULA', MODEL_FIELD_VALID, { |oModel| ValAula(oModel)})

    oModel:AddFields("ZS4MASTER",,oStruZS4)
    oModel:SetDescription("Cadastro de Alunos da Auto-Escola")
    oModel:SetPrimaryKey({"ZS4_CODALU"})
Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel('ZS4MVC')
    local oStruZS4  := FwFormStruct(2, "ZS4")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZS4",  oStruZS4,  "ZS4MASTER")

    oView:CreateHorizontalBox("ALUNO", 50)
    oView:SetOwnerView("VIEW_ZS4", "ALUNO")
    oView:EnableTitleView("VIEW_ZS4",  "Cadastro de Alunos")

    oView:setAfterViewActivate({|oView| fillUnit(oView)})
Return oView

/*/{Protheus.doc} User Function DelZS4
    Função que valida a exclusão dos alunos marcados, exceto por aqueles que constam com aula ativa.
    @type  Function
    @author Edison Cake
    @since 28/03/2023
    @version 1.0
    /*/
User Function DelZS4()
    local nCount := 0

  If MsgYesNo("Confirma a exclusão?", "Tem certeza?")
    DbSelectArea("ZS4")

    ZS4->(DbGoTop())

    While !ZS4->(EOF())
        If oMark:IsMark()
            nCount++
        Endif
        ZS4->(DbSkip())
    End Do

    ZS4->(DbGoTop())
    While !ZS4->(EoF())
        if oMark:IsMark() .and. ((ZS4->ZS4_AULA) <> "001")
              if ExistBlock("AttQtdZS4")
                  ExecBlock("AttQtdZS4", .F., .F., {ZS4->ZS4_CODINS, 5})
              endif
              RecLock("ZS4", .F.)
              ZS4->(DbDelete())
              ZS4->(MsUnlock())
        endif
      ZS4->(DbSkip())
    End Do

      oMark:Refresh(.T.)
  endif
Return

/*/{Protheus.doc} User Function EmAula
    Lista/Combo de opções para escolher se o aluno está ou não em aula.
    @type  Function
    @author Edison Cake
    @since 28/03/2023
    @version 1.0
    /*/
User Function EmAula()
    local cAula := ""

    cAula += "001=SIM;"
    cAula += "002=NÃO;"

Return cAula

// Função de validação de Campo, no qual impede deixar o campo de instrutor vazio.
Static Function ValAula(oModel)
    local cAula := oModel:GetValue("ZS4_AULA")
    local cInstrutor := ""
    local lRet := .T.

    if !Empty(cAula)

        cInstrutor := oModel:GetValue("ZS4_CODINS")
        if Empty(cInstrutor)

            lRet := .F.
            Help(NIL, NIL, "Atenção!!", NIL, "Há campos que necessitam de preenchimento prévio!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique as informações de entrada e tente novamente."})

            oModel:LoadValue("ZS4_AULA", Space(TamSX3("ZS4_AULA")[1]))
        endif
    endif

Return lRet

/*/{Protheus.doc} Static Function ValExcl
    Função que impede a exclusão individual de um aluno que está marcado como "em aula".
    @type  Function
    @author Edison Cake
    @since 28/03/2023
    @version 1.0
    /*/
Static Function ValExc(oModel)
    local lRet  := .T.
    local nOper := oModel:GetOperation()

    if nOper == MODEL_OPERATION_DELETE .AND. ZS4_AULA == "001"
        lRet := .F.

        Help(NIL, NIL, "Atenção!!", NIL, "Aluno em aula, não pode ser excluído o registro.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Marque o campo <b>AULA</b> como 'Não' e tente novamente."})

    endif

Return lRet

/*/{Protheus.doc} Static Function ValInstru
    Função que valida se o número/código digitado no campo de instrutor é valido, e se o mesmo existe nos registros.
    @type  Function
    @author Edison Cake
    @since 28/03/2023
    @version 1.0
    /*/
Static Function ValInstru(oModel)
    local lRet := .T.
    local cCod := oModel:GetValue("ZS4_CODINS")

    if !ExistCPO("ZS3", cCod)
        lRet := .F.

    elseif ZS3->(DbSeek(xFilial("ZS3")+cCod))

        if ZS3->ZS3_QTDALU >= 5

            lRet := .F.

            Help(NIL, NIL, "Atenção!!", NIL, "Instrutor(a) já possui o máximo de alunos.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Aguarde o fim das aulas ou selecione outro(a) intrutor(a)."})

        endif

    endif

Return lRet

/*/{Protheus.doc} User Function FimSZ4
    Função que define o status das aulas dos alunos marcados em "não".
    @type  Function
    @author Edison Cake
    @since 28/03/2023
    @version 1.0
    /*/
User Function FimZS4()
    if msgyesno("Deseja encerrar as aulas dos marcados?", "Atenção!")
        DbSelectArea("ZS4")

        ZS4->(DbGoTop())

        While !ZS4->(EOF())
            if oMark:IsMark() .and. ((ZS4->ZS4_AULA) == "001")
                RecLock("ZS4", .F.)
                    ZS4->(ZS4_AULA) := "002"
                ZS4->(MSUNLOCK())
            endif

            ZS4->(DbSkip())
        End Do

        oMark:Refresh(.T.)
    endif
Return

/*/{Protheus.doc} Static Function fillUnit
    Função que obtém o código do instrutor atual que está sendo cadastrado com um aluno, ou alterado.
    @type  Function
    @author Diego De Angelo
    @since 28/03/2023
    @version 1.0
    /*/
Static Function fillUnit(oView)
    cIdInstrutor := ZS4->ZS4_CODINS
Return

/*/{Protheus.doc} Static Function ValidaCPF
    Função para validar o CPF do aluno cadastrado.
    @type  Function
    @author Edison Cake
    @since 28/03/2023
    @version 1.0
    /*/
Static Function ValidaCPF(oModel)
    local cCPF := alltrim(oModel:GetValue("ZS4_CPF"))
    local aCPF := {}
    local nSoma1 := 0
    local lRet := .T.

    local nResto1 := 0
    local nSoma2 := 0
    local nResto2 := 0
    local nCount := 0

    for nCount := 1 to 11
        aAdd(aCPF, val(substr(cCPF, nCount, 1)))
    Next

    if (aCPF[1] == aCPF[2]) .and. (aCPF[2] == aCPF[3]) .and. (aCPF[3] == aCPF[4]) .and. (aCPF[4] == aCPF[5]) .and. (aCPF[5] == aCPF[6]) .and. (aCPF[6] == aCPF[7]) .and. (aCPF[7] == aCPF[8]) .and. (aCPF[8] == aCPF[9]) .and. (aCPF[9] == aCPF[10]) .and. (aCPF[10] == aCPF[11])

        Help(NIL, NIL, "Atenção!!", NIL, "CPF inválido.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique as informações e tente novamente."})

        lRet := .F.

        oModel:LoadValue("ZS4_CPF", Space(TamSX3("ZS4_CPF")[1]))

    else
    
        nSoma1 := (aCPF[1] * 10) + (aCPF[2] * 9) + (aCPF[3] * 8) + (aCPF[4] * 7) + (aCPF[5] * 6) + (aCPF[6] * 5) + (aCPF[7] * 4) + (aCPF[8] * 3) + (aCPF[9] * 2) 

        nResto1 := (nSoma1 * 10) % 11
            
            if nResto1 = 10
                nResto1 := 0
            end if
        
        nSoma2 := (aCPF[1] * 11) + (aCPF[2] * 10) + (aCPF[3] * 9) + (aCPF[4] * 8) + (aCPF[5] * 7) + (aCPF[6] * 6) + (aCPF[7] * 5) + (aCPF[8] * 4) + (aCPF[9] * 3) + (aCPF[10] * 2)
        
        nResto2 := (nSoma2 * 10) % 11

            if nResto2 = 10
                nResto2 := 0
            endif

            if !((nResto1 = aCPF[10]) .and. (nResto2 = aCPF[11]))

                Help(NIL, NIL, "Atenção!!", NIL, "CPF inválido.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique as informações e tente novamente."})

                lRet := .F.

                oModel:LoadValue("ZS4_CPF", Space(TamSX3("ZS4_CPF")[1]))
            endif
    end if

Return lRet
