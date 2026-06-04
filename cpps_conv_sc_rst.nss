// File: cpps_conv_sc_rst
// Binding: Attach to "Actions Taken" on a node saying "Reset scale to factory default".
#include "cpps_api"

void main()
{
    object oPC     = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (!GetIsObjectValid(oTarget) || GetDistanceBetween(oPC, oTarget) > CPPS_RANGE_LIMIT) return;

    ScalePortablePlaceable(oTarget, 1.0);
    SetLocalInt(oPC, "CPPS_DIRTY", TRUE);
    SendMessageToPC(oPC, CPPS_Action("Scale reset to ") +
                         CPPS_Value("1.0") + ".");
    CPPS_RefreshTargetTokens(oTarget);
}
