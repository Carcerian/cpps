// File: cpps_conv_click
// Purpose: Maps token roster clicks to target session locks.
#include "cpps_api"

void main()
{
    object oPC = GetPCSpeaker();

    // Explicitly typecast the dialog row parameter string to integer
    int nOffset = StringToInt(GetScriptParam("INDEX"));
    int nPage = GetLocalInt(oPC, "CPPS_CONV_PAGE");

    int nActualIndex = (nPage * 20) + nOffset;
    object oTargetPl = GetLocalObject(oPC, "CPPS_LIST_" + IntToString(nActualIndex));

    // Cache the selected object identity onto the player's session variables
    SetLocalObject(oPC, "CPPS_SELECTED_TARGET", oTargetPl);
    CPPS_RefreshTargetTokens(oTargetPl);
}

