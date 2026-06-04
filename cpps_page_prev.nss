// File: cpps_page_prev
// Purpose: Navigation controller option moving token pages down.
#include "cpps_api"

void main()
{
    object oPC = GetPCSpeaker();

    // Shift current page state tracking index downward
    SetLocalInt(oPC, "CPPS_CONV_PAGE", GetLocalInt(oPC, "CPPS_CONV_PAGE") - 1);

    // Repopulate text rows cleanly
    ExecuteScript("cpps_conv_render", oPC);
}

