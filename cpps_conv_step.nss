// File: cpps_conv_step
// Purpose: Configures active session precision sizes and updates text tokens dynamically.
// Parameters:
//   MODE   - "DIST" or "ROT"
//   VALUE  - "INCREASE", "DECREASE", or a literal float string to set absolutely
//   AMOUNT - step delta used when VALUE is INCREASE or DECREASE (e.g. "0.5" or "5.0")
#include "cpps_api"

void main()
{
    object oPC    = GetPCSpeaker();
    string sMode  = GetScriptParam("MODE");
    string sValue = GetScriptParam("VALUE");
    float  fAmt   = StringToFloat(GetScriptParam("AMOUNT"));

    if (sMode == "DIST")
    {
        float fCurrent = GetPCStepDistance(oPC);
        float fNew;

        if      (sValue == "INCREASE") fNew = fCurrent + fAmt;
        else if (sValue == "DECREASE") fNew = fCurrent - fAmt;
        else                           fNew = StringToFloat(sValue);

        if (fNew < 0.05) fNew = 0.05;
        if (fNew > 10.0) fNew = 10.0;

        SetLocalFloat(oPC, "CPPS_STEP_DISTANCE", fNew);
        SendMessageToPC(oPC, CPPS_Info("Move step: ") +
                             CPPS_Value(FloatToString(fNew, 1, 2) + "m"));
    }
    else if (sMode == "ROT")
    {
        float fCurrent = GetPCStepRotation(oPC);
        float fNew;

        if      (sValue == "INCREASE") fNew = fCurrent + fAmt;
        else if (sValue == "DECREASE") fNew = fCurrent - fAmt;
        else                           fNew = StringToFloat(sValue);

        if (fNew <   1.0) fNew =   1.0;
        if (fNew > 180.0) fNew = 180.0;

        SetLocalFloat(oPC, "CPPS_STEP_ROTATION", fNew);
        SendMessageToPC(oPC, CPPS_Info("Angle step: ") +
                             CPPS_Value(FloatToString(fNew, 1, 0) + " deg"));
    }

    SetCustomToken(CPPS_TOKEN_STEP_DIST, FloatToString(GetPCStepDistance(oPC), 1, 2) + "m");
    SetCustomToken(CPPS_TOKEN_STEP_ROT,  FloatToString(GetPCStepRotation(oPC),  1, 0) + " deg");
}
