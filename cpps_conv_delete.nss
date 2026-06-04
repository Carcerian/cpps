// File: cpps_conv_delete
// Purpose: Handles asset removal and processes creator gold refunds.
#include "cpps_api"

void main()
{
    object oPC     = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (!GetIsObjectValid(oTarget) || GetDistanceBetween(oPC, oTarget) > CPPS_RANGE_LIMIT)
    {
        SendMessageToPC(oPC, CPPS_Error("Error: Selection target is missing or out of bounds."));
        return;
    }

    // Reject anything not spawned by the CPPS
    if (GetLocalString(oTarget, "CPPS_UUID") == "")
    {
        SendMessageToPC(oPC, CPPS_Error("Error: Target is not a persistent system structure."));
        DeleteLocalObject(oPC, "CPPS_SELECTED_TARGET");
        return;
    }

    int nRefundGold = GetLocalInt(oTarget, "VALUE");

    if (nRefundGold > 0 && !GetIsDM(oPC) && !GetIsDMPossessed(oPC))
    {
        GiveGoldToCreature(oPC, nRefundGold);
        SendMessageToPC(oPC, CPPS_Action("Structure reclaimed. ") +
                             "Refunded: " + CPPS_Value(IntToString(nRefundGold) + " GP") + ".");
    }
    else
    {
        SendMessageToPC(oPC, CPPS_Action("Structure packed up."));
    }

    DeletePortablePlaceable(oTarget);
    DeleteLocalObject(oPC, "CPPS_SELECTED_TARGET");
}
