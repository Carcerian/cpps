// File: cpps_cond_isdm
// Purpose: Restricts menu options to authenticated Dungeon Masters.
#include "cpps_api"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    // Check for active DM client or possessed creature configurations
    if (GetIsDM(oPC) || GetIsDMPossessed(oPC))
    {
        return TRUE;
    }
    return FALSE;
}

