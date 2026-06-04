// File: cpps_conv_initdm
// Purpose: Gathers all persistent placeables in the area for a DM.
#include "cpps_api"

void main()
{
    object oPC = GetPCSpeaker();

    if (!GetIsDM(oPC) && !GetIsDMPossessed(oPC))
    {
        SendMessageToPC(oPC, CPPS_Error("Security Error: DM privilege required."));
        return;
    }

    object oArea = GetArea(oPC);
    DeleteLocalInt(oPC, "CPPS_CONV_PAGE");

    // Clear previous list entries so shorter rebuilds don't leave phantom rows
    int nOldTotal = GetLocalInt(oPC, "CPPS_LIST_TOTAL");
    int nClear;
    for (nClear = 1; nClear <= nOldTotal; nClear++)
        DeleteLocalObject(oPC, "CPPS_LIST_" + IntToString(nClear));

    int nMatchCount = 0;
    object oPl = GetFirstObjectInArea(oArea, OBJECT_TYPE_PLACEABLE);

    while (GetIsObjectValid(oPl))
    {
        if (GetLocalString(oPl, "CPPS_UUID") != "")
        {
            nMatchCount++;
            SetLocalObject(oPC, "CPPS_LIST_" + IntToString(nMatchCount), oPl);
        }
        oPl = GetNextObjectInArea(oArea, OBJECT_TYPE_PLACEABLE);
    }

    SetLocalInt(oPC, "CPPS_LIST_TOTAL", nMatchCount);
    ExecuteScript("cpps_conv_render", oPC);
}
