// File: cpps_conv_targnr
// Purpose: Automatically scans and target-locks the closest persistent placeable
//          to the tool click location. DMs bypass range and plot constraints.
#include "cpps_api"
//#include "inc_authenticate"
void main()
{
    object oPC   = GetPCSpeaker();
    int bIsAdmin = (GetIsDM(oPC) || GetIsDMPossessed(oPC)
    //|| SE_GetIsAuthenticatedDebugger(oPC) || SE_GetIsAuthenticatedDeveloper(oPC)
    //|| SE_GetIsAuthenticatedDeputy(oPC) || SE_GetIsAuthenticatedDM(oPC)
    );

    location lClickLoc = GetLocalLocation(oPC, "CPPS_TARGET_LOCATION");

    int nNth = 1;
    object oNearest = OBJECT_INVALID;

    object oPl = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE, lClickLoc, nNth);
    while (GetIsObjectValid(oPl))
    {
        // Players are range-limited; DMs can snap to any object in the area
        if (!bIsAdmin && GetDistanceBetween(oPC, oPl) > CPPS_RANGE_LIMIT)
            break;

        // Only select CPPS-managed placeables; native statics never have CPPS_UUID set
        if (GetLocalString(oPl, "CPPS_UUID") != "")
        {
            // Players cannot snap to plot-protected objects; DMs have no restriction
            if (bIsAdmin || !GetPlotFlag(oPl))
            {
                oNearest = oPl;
                break;
            }
        }

        nNth++;
        oPl = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE, lClickLoc, nNth);
    }

    if (GetIsObjectValid(oNearest))
    {
        SetLocalObject(oPC, "CPPS_SELECTED_TARGET", oNearest);
        SetLocalLocation(oPC, "CPPS_TARGET_LOCATION", GetLocation(oNearest));
        CPPS_RefreshTargetTokens(oNearest);
        SendMessageToPC(oPC, CPPS_Action("Target locked: ") +
                             CPPS_Label(GetName(oNearest)));
    }
    else
    {
        DeleteLocalObject(oPC, "CPPS_SELECTED_TARGET");
        SendMessageToPC(oPC, CPPS_Error("No valid persistent structures found within range."));
    }
}
