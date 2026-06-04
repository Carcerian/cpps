// File: cpps_mod_act
// Binding: Module Properties -> Events -> OnPlayerTarget property slot.
#include "cpps_api"

void main()
{
    object oPC = GetLastPlayerToSelectTarget();
    if (!GetIsObjectValid(oPC)) return;

    object oTargetObj  = GetTargetingModeSelectedObject();
    vector vTargetPos  = GetTargetingModeSelectedPosition();

    location lTargetLoc = Location(GetArea(oPC), vTargetPos, GetFacing(oPC));
    SetLocalLocation(oPC, "CPPS_TARGET_LOCATION", lTargetLoc);

    int bIsAdmin = (GetIsDM(oPC) || GetIsDMPossessed(oPC));

    if (GetIsObjectValid(oTargetObj) && GetObjectType(oTargetObj) == OBJECT_TYPE_PLACEABLE)
    {
        if (GetObjectUUID(oTargetObj) != "")
        {
            // PLAYER BLOCK: Block locking onto plot targets unless user is an authenticated DM
            if (!GetPlotFlag(oTargetObj) || bIsAdmin)
            {
                SetLocalObject(oPC, "CPPS_SELECTED_TARGET", oTargetObj);
                CPPS_RefreshTargetTokens(oTargetObj);
                if (bIsAdmin && GetPlotFlag(oTargetObj))
                    SendMessageToPC(oPC, "Admin Target Override Lock [PLOT ASSET]: " + GetName(oTargetObj));
                else
                    SendMessageToPC(oPC, "Target locked via Radial Cursor: " + GetName(oTargetObj));
            }
            else
            {
                SendMessageToPC(oPC, "Target Error: That structure is protected and cannot be manipulated.");
                DeleteLocalObject(oPC, "CPPS_SELECTED_TARGET");
            }
        }
        else
        {
            DeleteLocalObject(oPC, "CPPS_SELECTED_TARGET");
        }
    }
    else
    {
        DeleteLocalObject(oPC, "CPPS_SELECTED_TARGET");
    }

    // Refresh precision tokens and initialize conversation window overlay
    ExecuteScript("cpps_conv_step", oPC);
    AssignCommand(oPC, ActionStartConversation(oPC, "cpps_conv", TRUE, FALSE));
}

