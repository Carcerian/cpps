// File: cpps_conv_wipe
// Purpose: Triggers bulk deletion routines across an entire area zone.
#include "cpps_api"

void main()
{
    object oPC = GetPCSpeaker();

    if (!GetIsDM(oPC) && !GetIsDMPossessed(oPC))
    {
        SendMessageToPC(oPC, CPPS_Error("Security Error: Unauthorized call rejected."));
        return;
    }

    object oArea = GetArea(oPC);
    BulkDestroyAreaPlaceables(oArea);
    SendMessageToPC(oPC, CPPS_Error("Zone purge complete. ") +
                         "All persistent structures cleared.");
}
