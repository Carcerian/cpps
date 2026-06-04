// File: cpps_conv_cond
// Purpose: Proximity validation row filter check loop for the token directory layout.
#include "cpps_api"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    // Explicitly typecast the dialog row parameter string to integer
    int nOffset = StringToInt(GetScriptParam("INDEX"));
    int nPage = GetLocalInt(oPC, "CPPS_CONV_PAGE");

    int nActualIndex = (nPage * 20) + nOffset;
    object oTargetPl = GetLocalObject(oPC, "CPPS_LIST_" + IntToString(nActualIndex));

    // Evaluate if targeted structure asset remains within proximity limit boundaries
    if (GetIsObjectValid(oTargetPl))
    {
        float fDist = GetDistanceBetween(oPC, oTargetPl);
        if (fDist <= CPPS_RANGE_LIMIT)
        {
            return TRUE;
        }
    }
    return FALSE;
}

