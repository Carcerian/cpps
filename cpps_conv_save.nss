// File: cpps_conv_save
// Purpose: Flushes scale changes to the campaign database on conversation close.
//          Reconstructed operations save immediately; this only writes when
//          CPPS_DIRTY has been set by a scale operation.
#include "cpps_api"

void main()
{
    object oPC     = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (GetIsObjectValid(oTarget) && GetLocalInt(oPC, "CPPS_DIRTY"))
    {
        SavePlaceableToDB(oTarget);

        if (CPPS_DEBUG)
            SendMessageToPC(oPC, CPPS_Info("Scale committed to database."));
    }

    DeleteLocalInt(oPC, "CPPS_DIRTY");
}
