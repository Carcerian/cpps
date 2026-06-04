// File: cpps_conv_texset
// Purpose: Applies a texture directly to the selected target from conversation node parameters.
//          Use this for fixed hardcoded material options on individual conversation nodes,
//          as an alternative to the paginated dynamic list driven by cpps_conv_texini/texclk.
//
// Parameter Map Required:
//   TEX  (string) - The replacement texture filename to apply (e.g. "t_wood_dark02")
//   OLD  (string) - The original texture name to replace. If omitted, uses the value
//                   currently stored on the target (TEX_OLD), or replaces all textures
//                   if neither is set (blank sOldTexture in SetTextureOverride).
//   NAME (string) - Optional friendly label shown in the confirmation message.
#include "cpps_api"

void main()
{
    object oPC    = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (!GetIsObjectValid(oTarget) || GetDistanceBetween(oPC, oTarget) > CPPS_RANGE_LIMIT)
    {
        SendMessageToPC(oPC, CPPS_Error("Error: ") + "Target missing or out of range.");
        return;
    }

    string sNewTex = GetScriptParam("TEX");
    if (sNewTex == "") return;

    // OLD param takes priority; fall back to whatever is already stored on the object.
    string sOldTex = GetScriptParam("OLD");
    if (sOldTex == "") sOldTex = GetLocalString(oTarget, "TEX_OLD");

    string sName = GetScriptParam("NAME");
    if (sName == "") sName = sNewTex;

    RetexturePortablePlaceable(oTarget, sNewTex, sOldTex);
    SavePlaceableToDB(oTarget);

    SendMessageToPC(oPC, CPPS_Action("Material applied: ") + CPPS_Label(sName));
}

