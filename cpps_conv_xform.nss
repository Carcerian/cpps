// File: cpps_conv_xform
// Purpose: Multi-axis spatial translation routing pipeline matching SQLite specifications.
#include "cpps_api"

void main()
{
    object oPC = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (!GetIsObjectValid(oTarget) || GetDistanceBetween(oPC, oTarget) > CPPS_RANGE_LIMIT)
    {
        SendMessageToPC(oPC, CPPS_Error("Error: ") + "Target missing or out of range.");
        return;
    }

    string sType = GetScriptParam("TYPE");
    int bAdminBypass = (GetIsDM(oPC) || GetIsDMPossessed(oPC));

    // --- Cardinal Compass Facing Snaps Subroutine ---
    if (sType == "FACING")
    {
        string sDir = GetScriptParam("DIRECTION");
        // NWN1: facing 0 = North, 90 = East, 180 = South, 270 = West
        float fNewFacing;
        if      (sDir == "WEST")  fNewFacing =   0.0;
        else if (sDir == "SOUTH") fNewFacing =  90.0;
        else if (sDir == "EAST")  fNewFacing = 180.0;
        else if (sDir == "NORTH") fNewFacing = 270.0;
        else return;

        // Pass the target facing as an absolute value via FACING_ABS so we
        // never rely on GetFacingFromLocation, which may return 0 for placeables.
        ReconstructPortablePlaceable(oTarget, "FACING_ABS", fNewFacing, bAdminBypass);
        SendMessageToPC(oPC, CPPS_Action("Facing: ") +
                             CPPS_Value(sDir));
        return;
    }

    // --- Dynamic Distance and Rotation Increments Evaluator ---
    float fDir = StringToFloat(GetScriptParam("DIRECTION"));
    if (fDir != 1.0 && fDir != -1.0) fDir = 1.0;

    float fAmt;
    string sRawAmt = GetScriptParam("AMOUNT");

    if (sRawAmt == "DYNAMIC")
    {
        if (sType == "MOVE_X" || sType == "MOVE_Y" || sType == "MOVE_Z")
            fAmt = GetPCStepDistance(oPC);
        else
            fAmt = GetPCStepRotation(oPC);
    }
    else fAmt = StringToFloat(sRawAmt);

    float fDelta = fDir * fAmt;
    // Movement (X/Y) and Axis Rotations route through copy reconstruction
    if (sType == "MOVE_X" || sType == "MOVE_Y" || sType == "MOVE_Z" || sType == "ROTATE_Z" || sType == "TURN" || sType == "FACING_ABS")
    {
        // ReconstructPortablePlaceable always returns OBJECT_INVALID;
        // InternalSpawnReconstructedCopy sets CPPS_SELECTED_TARGET directly via oPC.
        ReconstructPortablePlaceable(oTarget, sType, fDelta, bAdminBypass);
    }
    else if (sType == "SCALE")
    {
        float fCur = GetLocalFloat(oTarget, "SCALE");
        if (fCur == 0.0) fCur = 1.0;
        ScalePortablePlaceable(oTarget, fCur + fDelta);
        SendMessageToPC(oPC, CPPS_Info("Scale: ") +
                             CPPS_Value(FloatToString(GetLocalFloat(oTarget, "SCALE"), 2, 1)));
        CPPS_RefreshTargetTokens(oTarget);
    }

}

