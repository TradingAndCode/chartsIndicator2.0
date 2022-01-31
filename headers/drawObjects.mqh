

void drawHLine(string name, double price, color clr)
{
    if (ObjectFindMQL4(name) < 0 && ObjectTypeMQL4(name) != OBJ_HLINE)
    {
        ObjectCreateMQL4(name, OBJ_HLINE, 0, TimeCurrent(), price);
    }
    else
    {
        ObjectMoveMQL4(name, 0, 0, price);
    }
    ObjectSetMQL4(name, OBJPROP_RAY, false);
    ObjectSetMQL4(name, OBJPROP_COLOR, clr);
    ObjectSetMQL4(name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetMQL4(name, OBJPROP_WIDTH, 2);
}

void drawSegmentHLine(string objname, double price, int startIndex, int endIndex)
{
    if (ObjectFindMQL4(objname) < 0 && ObjectTypeMQL4(objname) != OBJ_TREND)
    {
        ObjectCreateMQL4(objname, OBJ_TREND, 0, iTime(NULL, PERIOD_CURRENT, startIndex), price, iTime(NULL, PERIOD_CURRENT, endIndex), price);
    }
    else
    {
        ObjectDeleteMQL4(objname);
        ObjectDeleteMQL4(objname);
    }
    ObjectSetMQL4(objname, OBJPROP_RAY, false);
    ObjectSetMQL4(objname, OBJPROP_COLOR, clrYellow);
    ObjectSetMQL4(objname, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetMQL4(objname, OBJPROP_WIDTH, 2);
}

void drawVLine(string name, int index)
{
    if (ObjectFindMQL4(name) < 0 && ObjectTypeMQL4(name) != OBJ_VLINE)
    {
        ObjectCreateMQL4(name, OBJ_VLINE, 0, iTime(NULL, PERIOD_CURRENT, index), 0);
    }
    else
    {
        ObjectMoveMQL4(name, 0, iTime(NULL, PERIOD_CURRENT, index), 0);
    }
    ObjectSetMQL4(name, OBJPROP_RAY, false);
    ObjectSetMQL4(name, OBJPROP_COLOR, clrRed);
    ObjectSetMQL4(name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetMQL4(name, OBJPROP_WIDTH, 2);
}