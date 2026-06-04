// File: cpps_client_ent
// Binding: Module OnClientEnter
#include "cpps_api"

void main()
{
    object oPC = GetEnteringObject();
    if (!GetIsObjectValid(oPC)) return;

    if (GetIsDM(oPC) || GetIsDMPossessed(oPC))
    {
        object oDmSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oPC);
        if (GetIsObjectValid(oDmSkin))
        {
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(CPPS_DM_FEAT_IP_1),  oDmSkin);
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(CPPS_DM_FEAT_IP_10), oDmSkin);
            SendMessageToPC(oPC, CPPS_Info("CPPS: ") + CPPS_Action("Target mode active. Builder tools ready."));
        }
        return;
    }

    if (GetIsPC(oPC) && !GetHasFeat(CPPS_FEAT_1, oPC))
    {
        object oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oPC);
        if (!GetIsObjectValid(oSkin))
        {
            oSkin = CreateItemOnObject(CPPS_SKIN_RESREF, oPC);
            AssignCommand(oPC, ActionEquipItem(oSkin, INVENTORY_SLOT_CARMOUR));
        }
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(CPPS_FEAT_IP_1),  oSkin);
        SendMessageToPC(oPC, CPPS_Info("CPPS: ") + CPPS_Action("Target mode active."));
    }
    if (GetIsPC(oPC) && !GetHasFeat(CPPS_FEAT_10, oPC))
    {
        object oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oPC);
        if (!GetIsObjectValid(oSkin))
        {
            oSkin = CreateItemOnObject(CPPS_SKIN_RESREF, oPC);
            AssignCommand(oPC, ActionEquipItem(oSkin, INVENTORY_SLOT_CARMOUR));
        }
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBonusFeat(CPPS_FEAT_IP_10), oSkin);
        SendMessageToPC(oPC, CPPS_Info("CPPS: ") +
                             CPPS_Action("Builder tools ready."));
    }
}
