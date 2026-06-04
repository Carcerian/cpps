// File: cpps_conv_texinit
// Purpose: Populates a local string lookup table mapping friendly names to actual texture asset files.
#include "cpps_api"

void main()
{
    object oPC = GetPCSpeaker();
    object oTarget = GetLocalObject(oPC, "CPPS_SELECTED_TARGET");

    if (!GetIsObjectValid(oTarget)) return;

    // Reset pagination index tracking variables
    DeleteLocalInt(oPC, "CPPS_TEX_PAGE");

    // Fetch the placeable's base model tag or resref to load relevant textures
    string sResRef = GetResRef(oTarget);
    int nTotal = 0;

    // --- MATERIAL LOOKUP TABLE MATRIX ---
    // Map textures based on what type of item is currently selected
    if (FindSubString(sResRef, "chair") != -1 || FindSubString(sResRef, "bench") != -1)
    {
        // Define the original default texture name found on the 3D model (.mdl)
        SetLocalString(oPC, "CPPS_TEX_TARGET_OLD", "t_wood_oak01");

        // List the available custom replacement texture options (.tga/.dds files)
        nTotal++;
        SetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString(nTotal), "Dark Mahogany");
        SetLocalString(oPC, "CPPS_TEX_FILE_" + IntToString(nTotal), "t_wood_dark02");

        nTotal++;
        SetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString(nTotal), "Weathered Pine");
        SetLocalString(oPC, "CPPS_TEX_FILE_" + IntToString(nTotal), "t_wood_grey05");

        nTotal++;
        SetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString(nTotal), "Royal Gilded Gold");
        SetLocalString(oPC, "CPPS_TEX_FILE_" + IntToString(nTotal), "t_metal_gold01");
    }
    else if (FindSubString(sResRef, "tent") != -1 || FindSubString(sResRef, "bedroll") != -1)
    {
        SetLocalString(oPC, "CPPS_TEX_TARGET_OLD", "t_fabric_canvas");

        nTotal++;
        SetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString(nTotal), "Crimson Silk");
        SetLocalString(oPC, "CPPS_TEX_FILE_" + IntToString(nTotal), "t_cloth_red02");

        nTotal++;
        SetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString(nTotal), "Forest Camouflage");
        SetLocalString(oPC, "CPPS_TEX_FILE_" + IntToString(nTotal), "t_pattern_camo01");

        nTotal++;
        SetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString(nTotal), "Royal Blue Velvet");
        SetLocalString(oPC, "CPPS_TEX_FILE_" + IntToString(nTotal), "t_cloth_blue04");
    }
    else // Default generic fallback materials loop
    {
        // Leaving blank targets ALL textures on the model for replacement
        SetLocalString(oPC, "CPPS_TEX_TARGET_OLD", "");

        nTotal++;
        SetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString(nTotal), "Solid Stone");
        SetLocalString(oPC, "CPPS_TEX_FILE_" + IntToString(nTotal), "t_stone_gray01");

        nTotal++;
        SetLocalString(oPC, "CPPS_TEX_NAME_" + IntToString(nTotal), "Rusty Iron Mesh");
        SetLocalString(oPC, "CPPS_TEX_FILE_" + IntToString(nTotal), "t_metal_rust01");
    }

    SetLocalInt(oPC, "CPPS_TEX_TOTAL", nTotal);

    // Call the dynamic token formatter engine
    ExecuteScript("cpps_conv_texren", oPC);
}

