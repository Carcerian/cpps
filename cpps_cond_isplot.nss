// File: cpps_cond_hastrg
// Purpose: Branch routing logic evaluating target-locked asset existence.
#include "cpps_api"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    return GetPlotFlag(oTarget);
}

