#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function AttQtdZS4
    Fun��o de atualiza��o de quantidade de alunos vinculados � instrutores.
    @type  Function
    @author Edison Cake
    @since 28/03/2023
    /*/
User Function AttQtdZS4()
    local cCodIns            := PARAMIXB[1]
    local nOper              := PARAMIXB[2]
    local nQtdAtualAlunos    := 0

    dbselectarea("ZS3")
    ZS3->(dbsetorder(1))
    ZS3->(DbGoTop())
    
    // Se a opera��o for de inser��o, ser� acrescido o n�mero atual de alunos do instrutor.
    if nOper == MODEL_OPERATION_INSERT

        if ZS3->(dbseek(xFilial("ZS3")+cCodIns))

            nQtdAtualAlunos := ZS3->ZS3_QTDALU
            If ZS3->(RecLock("ZS3", .F.))

                nQtdAtualAlunos++
                ZS3->ZS3_QTDALU := nQtdAtualAlunos

                ZS3->(MsUnlock())
            Endif
        endif
        
    
    // Se a opera��o for de deletar o aluno, ser� decrementado o n�mero atual de alunos do instrutor.
    elseif nOper == MODEL_OPERATION_DELETE

        if ZS3->(dbseek(xFilial("ZS3")+cCodIns))

            nQtdAtualAlunos := ZS3->ZS3_QTDALU

            if nQtdAtualAlunos > 0

                If ZS3->(RecLock("ZS3", .F.))

                    nQtdAtualAlunos--
                    ZS3->ZS3_QTDALU := nQtdAtualAlunos

                    ZS3->(MsUnlock())

                Endif
                
            endif

        endif

    endif

Return 

/*/{Protheus.doc} User Function UpdtZS4
    Fun��o de atualiza��o de quantidade de alunos vinculados � instrutores, por�m, com o crit�rio de altera��o de instrutor por aluno.
    @type  Function
    @author Edison Cake
    @since 28/03/2023
    /*/
User Function UpdtZS4()
    local oObj               := PARAMIXB
    local cCodInsAtual       := oObj:GetValue("ZS4MASTER", "ZS4_CODINS")
    local cCodAnterior       := cIdInstrutor
    local nOper              := oObj:GetOperation()
    local nQtdAtualAlunos    := 0

    DbSelectArea("ZS3")
    ZS3->(DbSetOrder(1))
    ZS3->(DbGoTop())

    // Se a opera��o for de atualizar um aluno as quantidades totais de alunos ser�o atualizadas em ambos os estutores (atual, e anterior)
    if nOper == MODEL_OPERATION_UPDATE 
    
        ZS3->(dbseek(xFilial("ZS3")+cCodAnterior))
        nQtdAtualAlunos := ZS3->ZS3_QTDALU
        nQtdAtualAlunos--

        RecLock("ZS3", .F.)
            ZS3->ZS3_QTDALU := nQtdAtualAlunos
        ZS3->(MsUnlock())

        ZS3->(DbSeek(xFilial("ZS3")+cCodInsAtual))
        nQtdAtualAlunos := ZS3->ZS3_QTDALU
        nQtdAtualAlunos++

        RecLock("ZS3", .F.)
            ZS3->ZS3_QTDALU := nQtdAtualAlunos
        ZS3->(MsUnlock())
    endif

Return�
