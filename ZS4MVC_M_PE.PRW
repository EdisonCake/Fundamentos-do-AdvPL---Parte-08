#INCLUDE 'TOTVS.CH'

User Function ZS4MVC_M()
    local aParam   := PARAMIXB
    local lRet     := .T.
    local oObj     := NIL
    local cIdPonto := ""
    local cIdModel := ""

    local cCodIns  := ""
    local nOper    := ""

    if aParam != NIL
        oObj     := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]

        if cIdPonto == "MODELCOMMITNTTS"
            
            cCodIns := oObj:GetValue("ZS4MASTER", "ZS4_CODINS")
            nOper   := oObj:GetOperation()

            if ExistBlock("AttQtdZS4")
                ExecBlock("AttQtdZS4", .F., .F., {cCodIns, nOper})
            endif

        elseif cIdPonto == "MODELCOMMITTTS"

            if ExistBlock("UpdtZS4")
                ExecBlock("UpdtZS4", .F., .F., oObj)
            endif

        endif
    endif    


Return lRet
