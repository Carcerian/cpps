#include "cpps_api"

void main()
{
    object oArea = OBJECT_SELF;
    if (!GetLocalInt(oArea, "ALREADY_POPULATED"))
    {
        SetLocalInt(oArea, "ALREADY_POPULATED", TRUE);
        SetLocalInt(oArea, "CPPS_ENABLED", TRUE);
        LoadPlaceablesFromDB(oArea);
    }
}

