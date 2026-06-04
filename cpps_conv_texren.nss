// File: cpps_conv_texren
// Purpose: Maps texture choices to text tokens and marks the active variant.
#include "cpps_api"

void main()
{
    object oPC     = OBJECT_SELF;
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");
    if (!GetIsObjectValid(oTarget)) return;

    int nPage       = GetLocalInt(oPC, "CPPS_TEX_PAGE");
    int nTotal      = GetLocalInt(oPC, "CPPS_TEX_TOTAL");
    int nStartIdx   = (nPage * 20) + 1;
    int nEndIdx     = nStartIdx + 19;
    int nTokenID    = CPPS_TEX_TOKEN_START;
    string sActiveTex = GetLocalString(oTarget, "TEX_NEW");
    int i;

    for (i = nStartIdx; i <= nEndIdx; i++)
    {
        string sName = GetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString(i));
        string sFile = GetLocalString(oPC, "CPPS_TEX_FILE_" + IntToString(i));

        if (sName != "")
        {
            if (sFile == sActiveTex || (sActiveTex == "" && i == 1))
                SetCustomToken(nTokenID, CPPS_Action(sName) +
                                         CPPS_Info(" [Active]"));
            else
                SetCustomToken(nTokenID, CPPS_Label(sName));
        }
        else
        {
            SetCustomToken(nTokenID, "");
        }
        nTokenID++;
    }

    SetCustomToken(CPPS_TEX_TOKEN_PREV, nPage > 0      ? CPPS_Info("[Previous Materials]") : "");
    SetCustomToken(CPPS_TEX_TOKEN_NEXT, nTotal > nEndIdx ? CPPS_Info("[Next Materials]") : "");
}
