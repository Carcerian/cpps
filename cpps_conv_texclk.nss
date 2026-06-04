// File: cpps_conv_texclk
// Purpose: Executes engine override material updates and refreshes the display tokens.
#include "cpps_api"

void main()
{
    object oPC = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (!GetIsObjectValid(oTarget) || GetDistanceBetween(oPC, oTarget) > CPPS_RANGE_LIMIT) return;

    int nOffset = StringToInt(GetScriptParam("INDEX"));
    int nPage = GetLocalInt(oPC, "CPPS_TEX_PAGE");
    int nActualIndex = (nPage * 20) + nOffset;

    string sOldTex = GetLocalString(oPC, "CPPS_TEX_TARGET_OLD");
    string sNewTex = GetLocalString(oPC, "CPPS_TEX_FILE_" + IntToString(nActualIndex));
    string sName   = GetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString(nActualIndex));

    // Execute engine override material update
    RetexturePortablePlaceable(oTarget, sNewTex, sOldTex);
    SendMessageToPC(oPC, "Material variant updated: " + sName);

    // Force call the renderer to immediately refresh the [Active Variant] text tag on screen
    ExecuteScript("cpps_conv_texren", oPC);
}

