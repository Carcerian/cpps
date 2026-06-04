// File: cpps_conv_plot
// Purpose: Allows DMs to set or remove the plot status of a targeted placeable.
// Parameter: SET = "1" (enable) or "0" (disable)

#include "cpps_api"
//#include "inc_authenticate"

void main()
{
    object oPC     = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (!GetIsObjectValid(oTarget)) return;

    int bSetPlot = StringToInt(GetScriptParam("SET"));
    SetPlotFlag(oTarget, bSetPlot);
    SavePlaceableToDB(oTarget);

    if (bSetPlot)
        SendMessageToPC(oPC, CPPS_Label(GetName(oTarget)) +
                             CPPS_Info(" is now plot-protected. ") +
                             "Players cannot target or delete it.");
    else
        SendMessageToPC(oPC, CPPS_Label(GetName(oTarget)) +
                             CPPS_Info(" plot protection removed."));
}
