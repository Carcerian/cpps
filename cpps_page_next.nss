// File: cpps_page_next
// Purpose: Navigation controller option moving token pages up.
#include "cpps_api"

void main()
{
    object oPC = GetPCSpeaker();

    // Shift current page state tracking index upward
    SetLocalInt(oPC, "CPPS_CONV_PAGE", GetLocalInt(oPC, "CPPS_CONV_PAGE") + 1);

    // Repopulate text rows cleanly
    ExecuteScript("cpps_conv_render", oPC);
}

