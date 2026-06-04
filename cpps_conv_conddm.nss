// File: cpps_conv_conddm
// Purpose: Row visibility conditional script for DM area-wide lists (discards distance check).
// Parameter Mapping Required: Name: "INDEX" | Type: String | Value: [1 through 20]
#include "cpps_api"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    // Safety fallback: Ensure a player didn't accidentally traverse into a DM-only node branch
    if (!GetIsDM(oPC) && !GetIsDMPossessed(oPC)) return FALSE;

    int nOffset = StringToInt(GetScriptParam("INDEX"));
    int nPage = GetLocalInt(oPC, "CPPS_CONV_PAGE");

    int nActualIndex = (nPage * 20) + nOffset;
    object oTargetPl = GetLocalObject(oPC, "CPPS_LIST_" + IntToString(nActualIndex));

    // Show line row if object exists anywhere in the area instance roster
    if (GetIsObjectValid(oTargetPl))
    {
        return TRUE;
    }
    return FALSE;
}

