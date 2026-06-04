// File: cpps_texpage
// Parameter Required: Name: "DIR" | Type: String | Value: "1" (Next) or "-1" (Previous)
#include "cpps_api"
void main()
{
    object oPC = GetPCSpeaker();
    int nDir = StringToInt(GetScriptParam("DIR"));
    SetLocalInt(oPC, "CPPS_TEX_PAGE", GetLocalInt(oPC, "CPPS_TEX_PAGE") + nDir);
    ExecuteScript("cpps_conv_texren", oPC);
}

