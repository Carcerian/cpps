// File: cpps_conv_render
// Purpose: Populates the 20-row paginated token list with placeable names and page controls.
//          Also refreshes CUSTOM8025 (target name), CUSTOM8026 (GP refund value), and
//          CUSTOM8027 (scale) via CPPS_RefreshTargetTokens whenever a target is locked.
#include "cpps_api"

void main()
{
    object oPC    = OBJECT_SELF;
    int nPage     = GetLocalInt(oPC, "CPPS_CONV_PAGE");
    int nTotal    = GetLocalInt(oPC, "CPPS_LIST_TOTAL");
    int nStartIdx = (nPage * 20) + 1;
    int nEndIdx   = nStartIdx + 19;
    int nTokenID  = CPPS_TOKEN_START;
    int i;

    for (i = nStartIdx; i <= nEndIdx; i++)
    {
        object oPl = GetLocalObject(oPC, "CPPS_LIST_" + IntToString(i));
        if (GetIsObjectValid(oPl))
            SetCustomToken(nTokenID, CPPS_Value(IntToString(i) + ". ") +
                                     CPPS_Label(GetName(oPl)));
        else
            SetCustomToken(nTokenID, "");
        nTokenID++;
    }

    SetCustomToken(CPPS_TOKEN_PREV, nPage > 0    ? CPPS_Info("[Previous Page]") : "");
    SetCustomToken(CPPS_TOKEN_NEXT, nTotal > nEndIdx ? CPPS_Info("[Next Page]") : "");

    CPPS_RefreshTargetTokens(GetLocalObject(oPC, "CPPS_SELECTED_TARGET"));
}
