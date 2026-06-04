// File: cpps_conv_rotate
// Purpose: Rotates the targeted placeable by a given number of degrees via reconstruction.
// Parameter: DEGREES — signed float string, e.g. "45.0" or "-90.0"
#include "cpps_api"

void main()
{
    object oPC     = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (!GetIsObjectValid(oTarget) || GetDistanceBetween(oPC, oTarget) > CPPS_RANGE_LIMIT) return;

    float fAmount    = StringToFloat(GetScriptParam("DEGREES"));
    int bAdminBypass = (GetIsDM(oPC) || GetIsDMPossessed(oPC));

    ReconstructPortablePlaceable(oTarget, "ROTATE_Z", fAmount, bAdminBypass);
}
