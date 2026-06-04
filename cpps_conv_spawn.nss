// File: cpps_conv_spawn
// Purpose: Processes construction requirements and instantiates placeables.
#include "cpps_api"

void main()
{
    object oPC           = GetPCSpeaker();
    string sTargetResRef = GetScriptParam("RESREF");
    int nCost            = StringToInt(GetScriptParam("COST"));

    if (sTargetResRef == "") return;

    int bIsAdmin = (GetIsDM(oPC) || GetIsDMPossessed(oPC));

    if (!bIsAdmin)
    {
        if (GetGold(oPC) < nCost)
        {
            SendMessageToPC(oPC, CPPS_Error("Construction failed: ") +
                                 "You need " + CPPS_Value(IntToString(nCost) + " GP") + ".");
            return;
        }
        TakeGoldFromCreature(nCost, oPC, TRUE);
    }
    else
    {
        nCost = 0;
    }

    location lSpawnLoc = GetLocalLocation(oPC, "CPPS_TARGET_LOCATION");
    object oPl = CreatePortablePlaceable(sTargetResRef, lSpawnLoc);

    if (GetIsObjectValid(oPl))
    {
        SetLocalInt(oPl, "VALUE", nCost);
        SetLocalFloat(oPl, "ROT_YAW", GetFacing(oPC)); // Stamp initial facing so first save records correct orientation
        if (CPPS_DEBUG)
        {
            if (bIsAdmin)
                SendMessageToPC(oPC, CPPS_Info("Admin: Structure spawned for free."));
            else
                SendMessageToPC(oPC, CPPS_Action("Structure placed. ") +
                                     "Cost: " + CPPS_Value(IntToString(nCost) + " GP") + ".");
        }
        SavePlaceableToDB(oPl);
    }
    else
    {
        if (!bIsAdmin)
            GiveGoldToCreature(oPC, nCost);
        SendMessageToPC(oPC, CPPS_Error("Construction aborted: ") +
                             "Targeted position is obstructed.");
    }
}
