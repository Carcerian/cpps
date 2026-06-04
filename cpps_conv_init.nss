// File: cpps_conv_init
// Purpose: Gathers nearby persistent non-plot placeables for players.
#include "cpps_api"

void main()
{
    object oPC = GetPCSpeaker();
    DeleteLocalInt(oPC, "CPPS_CONV_PAGE");

    // Clear previous list entries so shorter rebuilds don't leave phantom rows
    int nOldTotal = GetLocalInt(oPC, "CPPS_LIST_TOTAL");
    int nClear;
    for (nClear = 1; nClear <= nOldTotal; nClear++)
        DeleteLocalObject(oPC, "CPPS_LIST_" + IntToString(nClear));

    int nMatchCount = 0;
    int nNth        = 1;
    object oPl = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, nNth);

    while (GetIsObjectValid(oPl))
    {
        if (GetDistanceBetween(oPC, oPl) > CPPS_RANGE_LIMIT) break;

        if (GetLocalString(oPl, "CPPS_UUID") != "" && !GetPlotFlag(oPl))
        {
            nMatchCount++;
            SetLocalObject(oPC, "CPPS_LIST_" + IntToString(nMatchCount), oPl);
        }

        nNth++;
        oPl = GetNearestObject(OBJECT_TYPE_PLACEABLE, oPC, nNth);
    }

    SetLocalInt(oPC, "CPPS_LIST_TOTAL", nMatchCount);
    ExecuteScript("cpps_conv_render", oPC);
}
