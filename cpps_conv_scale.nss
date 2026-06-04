// File: cpps_conv_scale
// Binding: Attach to "Actions Taken" on your scale variation sub-nodes.
// Parameter Map Required: Name: "VALUE" | Type: String | Value: "0.1" (or "-0.1")
#include "cpps_api"

void main()
{
    object oPC     = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (!GetIsObjectValid(oTarget) || GetDistanceBetween(oPC, oTarget) > CPPS_RANGE_LIMIT)
    {
        SendMessageToPC(oPC, CPPS_Error("Error: Modification target missing or out of distance bounds."));
        return;
    }

    float fCurrentScale = GetLocalFloat(oTarget, "SCALE");
    if (fCurrentScale == 0.0) fCurrentScale = 1.0;

    float fNewScale = fCurrentScale + StringToFloat(GetScriptParam("VALUE"));
    ScalePortablePlaceable(oTarget, fNewScale);

    SetLocalInt(oPC, "CPPS_DIRTY", TRUE);

    SendMessageToPC(oPC, CPPS_Info("Scale: ") +
                         CPPS_Value(FloatToString(GetLocalFloat(oTarget, "SCALE"), 2, 1)));
    CPPS_RefreshTargetTokens(oTarget);
}
