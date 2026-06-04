// File: cpps_conv_texcond
#include "cpps_api"
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nOffset = StringToInt(GetScriptParam("INDEX"));
    int nPage = GetLocalInt(oPC, "CPPS_TEX_PAGE");

    string sCheck = GetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString((nPage * 20) + nOffset));
    return (sCheck != "");
}

