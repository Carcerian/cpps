// File: cpps_conv_reset
#include "cpps_api"

void main()
{
    object oPC     = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (!GetIsObjectValid(oTarget) || GetDistanceBetween(oPC, oTarget) > CPPS_RANGE_LIMIT) return;

    int bAdminBypass = (GetIsDM(oPC) || GetIsDMPossessed(oPC));

    // Scale reset applies immediately via visual transform; mark dirty for DB flush on close.
    ScalePortablePlaceable(oTarget, 1.0);
    SetLocalInt(oPC, "CPPS_DIRTY", TRUE);

    // Facing reset requires full reconstruction since NWN1 placeables
    // can only be reoriented by destroy-and-respawn at the target facing.
    ReconstructPortablePlaceable(oTarget, "FACING_ABS", 0.0, bAdminBypass);

    // Token refresh happens inside InternalSpawnReconstructedCopy after the 0.02s delay.
    SendMessageToPC(oPC, CPPS_Action("Transformations reset to default."));
}
