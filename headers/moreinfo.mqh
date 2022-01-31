//+-----------------------------------------------------------------------------+
//| Custom indicator initialization function for more info display        |
//+-----------------------------------------------------------------------------+
void onInitMoreInfo()
{

  ObjectsDeleteAll(0, "stecatorInfo*", 0, OBJ_LABEL);
  string spread = "stecatorInfospread";
  ObjectCreateMQL4(spread, OBJ_LABEL, 0, 0, 0);
  ObjectSetMQL4(spread, OBJPROP_CORNER, 3);
  ObjectSetMQL4(spread, OBJPROP_COLOR, clrWhite);
  ObjectSetInteger(0, spread, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, spread, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, spread, OBJPROP_SELECTED, false);
  ObjectSetMQL4(spread, OBJPROP_XDISTANCE, 150);
  ObjectSetMQL4(spread, OBJPROP_YDISTANCE, 85);
  ObjectSetTextMQL4(spread, "Spread : ");
  ObjectSetInteger(0, spread, OBJPROP_FONTSIZE, 10);
  ObjectSetMQL4(spread, OBJPROP_COLOR, clrWhite);

  string spreadValue = "stecatorInfospreadValue";
  ObjectCreateMQL4(spreadValue, OBJ_LABEL, 0, 0, 0);
  ObjectSetMQL4(spreadValue, OBJPROP_CORNER, 3);
  ObjectSetMQL4(spreadValue, OBJPROP_COLOR, clrWhite);
  ObjectSetInteger(0, spreadValue, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, spreadValue, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, spreadValue, OBJPROP_SELECTED, false);
  ObjectSetMQL4(spreadValue, OBJPROP_XDISTANCE, 50);
  ObjectSetMQL4(spreadValue, OBJPROP_YDISTANCE, 85);

  string reistance = "stecatorInforesistance";
  ObjectCreateMQL4(reistance, OBJ_LABEL, 0, 0, 0);
  ObjectSetMQL4(reistance, OBJPROP_CORNER, 3);
  ObjectSetMQL4(reistance, OBJPROP_XDISTANCE, 150);
  ObjectSetMQL4(reistance, OBJPROP_YDISTANCE, 45);
  ObjectSetInteger(0, reistance, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, reistance, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, reistance, OBJPROP_SELECTED, false);
  ObjectSetTextMQL4(reistance, "Resistances : ");
  ObjectSetInteger(0, reistance, OBJPROP_FONTSIZE, 10);
  ObjectSetMQL4(reistance, OBJPROP_COLOR, clrWhite);

  string resistancevalue = "stecatorInforesistancevalue";
  ObjectCreateMQL4(resistancevalue, OBJ_LABEL, 0, 0, 0);
  ObjectSetMQL4(resistancevalue, OBJPROP_CORNER, 3);
  ObjectSetMQL4(resistancevalue, OBJPROP_COLOR, clrWhite);
  ObjectSetInteger(0, resistancevalue, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, resistancevalue, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, resistancevalue, OBJPROP_SELECTED, false);
  ObjectSetMQL4(resistancevalue, OBJPROP_XDISTANCE, 50);
  ObjectSetMQL4(resistancevalue, OBJPROP_YDISTANCE, 45);

  string support = "stecatorInfosupport";
  ObjectCreateMQL4(support, OBJ_LABEL, 0, 0, 0);
  ObjectSetMQL4(support, OBJPROP_CORNER, 3);
  ObjectSetInteger(0, support, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, support, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, support, OBJPROP_SELECTED, false);
  ObjectSetTextMQL4(support, "Supports : ");
  ObjectSetInteger(0, support, OBJPROP_FONTSIZE, 10);
  ObjectSetMQL4(support, OBJPROP_COLOR, clrWhite);
  ObjectSetMQL4(support, OBJPROP_XDISTANCE, 150);
  ObjectSetMQL4(support, OBJPROP_YDISTANCE, 65);

  string supportvalue = "stecatorInfosupportvalue";
  ObjectCreateMQL4(supportvalue, OBJ_LABEL, 0, 0, 0);
  ObjectSetMQL4(supportvalue, OBJPROP_CORNER, 3);
  ObjectSetMQL4(supportvalue, OBJPROP_COLOR, clrWhite);
  ObjectSetInteger(0, supportvalue, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, supportvalue, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, supportvalue, OBJPROP_SELECTED, false);
  ObjectSetMQL4(supportvalue, OBJPROP_XDISTANCE, 50);
  ObjectSetMQL4(supportvalue, OBJPROP_YDISTANCE, 65);

  string timeLeft = "stecatorInfotl";
  ObjectCreateMQL4(timeLeft, OBJ_LABEL, 0, 0, 0);
  ObjectSetMQL4(timeLeft, OBJPROP_CORNER, 3);
  ObjectSetInteger(0, timeLeft, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, timeLeft, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, timeLeft, OBJPROP_SELECTED, false);
  ObjectSetTextMQL4(timeLeft, "Time Left : ");
  ObjectSetInteger(0, timeLeft, OBJPROP_FONTSIZE, 10);
  ObjectSetMQL4(timeLeft, OBJPROP_XDISTANCE, 150);
  ObjectSetMQL4(timeLeft, OBJPROP_YDISTANCE, 5);
  ObjectSetMQL4(timeLeft, OBJPROP_COLOR, clrWhite);

  string timeLeftValue = "stecatorInfoTlValue";
  ObjectCreateMQL4(timeLeftValue, OBJ_LABEL, 0, 0, 0);
  ObjectSetMQL4(timeLeftValue, OBJPROP_CORNER, 3);
  ObjectSetInteger(0, timeLeftValue, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, timeLeftValue, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, timeLeftValue, OBJPROP_SELECTED, false);
  ObjectSetMQL4(timeLeftValue, OBJPROP_XDISTANCE, 70);
  ObjectSetMQL4(timeLeftValue, OBJPROP_YDISTANCE, 5);
  ObjectSetInteger(0, timeLeftValue, OBJPROP_FONTSIZE, 10);
  ObjectSetMQL4(timeLeftValue, OBJPROP_COLOR, clrYellow);

  string Do = "stecatorInfoDo";
  ObjectCreateMQL4(Do, OBJ_LABEL, 0, 0, 0);
  ObjectSetMQL4(Do, OBJPROP_CORNER, 3);
  ObjectSetTextMQL4(Do, "Daily Open : ", 1);
  ObjectSetMQL4(Do, OBJPROP_XDISTANCE, 150);
  ObjectSetMQL4(Do, OBJPROP_YDISTANCE, 25);
  ObjectSetInteger(0, Do, OBJPROP_FONTSIZE, 10);
  ObjectSetMQL4(Do, OBJPROP_COLOR, clrWhite);
  ObjectSetInteger(0, Do, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, Do, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, Do, OBJPROP_SELECTED, false);

  string DailyOpenValue = "stecatorInfoDoValue";
  ObjectCreateMQL4(DailyOpenValue, OBJ_LABEL, 0, 0, 0);
  ObjectSetMQL4(DailyOpenValue, OBJPROP_CORNER, 3);
  ObjectSetMQL4(DailyOpenValue, OBJPROP_XDISTANCE, 70);
  ObjectSetMQL4(DailyOpenValue, OBJPROP_YDISTANCE, 25);
  ObjectSetInteger(0, DailyOpenValue, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, DailyOpenValue, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, DailyOpenValue, OBJPROP_SELECTED, false);
}



//+----------------------------------------------------------+
//| Method for converting timeframes to string               |
//+----------------------------------------------------------+
ENUM_TIMEFRAMES IntToTimeframe(int tf) //code by TRO
{
  switch (tf)
  {
  case 1:
    return PERIOD_M1;
    break;
  case 5:
    return PERIOD_M5;
    break;
  case 15:
    return PERIOD_M15;
    break;
  case 30:
    return PERIOD_M30;
    break;
  case 60:
    return PERIOD_H1;
    break;
  case 240:
    return PERIOD_H4;
    break;
  case 1440:
    return PERIOD_D1;
    break;
  case 10080:
    return PERIOD_W1;
    break;
  case 43200:
    return PERIOD_MN1;
  }
  return NULL;
}



void startMoreInfo()
{
  string Spread = DoubleToString(SymbolInfoInteger(Symbol(), SYMBOL_SPREAD_FLOAT) / 10, 1);
  double DayClose = iOpen(NULL, PERIOD_D1, 0);

  if (DayClose != 0)
  {
    double Strength = (Bid - DayClose) / PipSize;
    ObjectSetTextMQL4("stecatorInfospreadValue", string(Spread), 1);
    ObjectSetInteger(0, "stecatorInfospreadValue", OBJPROP_FONTSIZE, 10);
    ObjectSetMQL4("stecatorInfospreadValue", OBJPROP_COLOR, clrYellow);
    string TimeLeft = "";

    TimeLeft = TimeToString(iTime(NULL, PERIOD_CURRENT, 0) + Period() * 60 - TimeCurrent(), TIME_MINUTES | TIME_SECONDS);

    ObjectSetTextMQL4("stecatorInfoTlValue", string(TimeLeft), 1);
    ObjectSetInteger(0, "stecatorInfoTlValue", OBJPROP_FONTSIZE, 10);
    ObjectSetMQL4("stecatorInfoTlValue", OBJPROP_COLOR, clrYellow);
    ObjectSetTextMQL4("stecatorInfoDoValue", sign(Strength) + DoubleToString(MathAbs(Strength), 2), 1);

    ObjectSetInteger(0, "stecatorInfoDoValue", OBJPROP_FONTSIZE, 10);
    ObjectSetTextMQL4("stecatorInforesistancevalue", string(resistances), 1);
    ObjectSetInteger(0, "stecatorInforesistancevalue", OBJPROP_FONTSIZE, 10);
    ObjectSetMQL4("stecatorInforesistancevalue", OBJPROP_COLOR, clrRed);
    ObjectSetTextMQL4("stecatorInfosupportvalue", string(supports), 1);
    ObjectSetInteger(0, "stecatorInfosupportvalue", OBJPROP_FONTSIZE, 10);
    ObjectSetMQL4("stecatorInfosupportvalue", OBJPROP_COLOR, clrGreen);
    if (Strength < 0)
    {
      ObjectSetMQL4("stecatorInfoDoValue", OBJPROP_COLOR, color2);
    }
    else
    {
      ObjectSetMQL4("stecatorInfoDoValue", OBJPROP_COLOR, color1);
    }
  }
}



//+-------------------------------------------------------------------------------------------------+
//| Custom indicator calculate function for calculating the number of supports and resistances      |
//+-------------------------------------------------------------------------------------------------+
void calculateRSNumber()
{
  supports = 0;
  resistances = 0;
  for (int i = 0; i < zone_count; i++)
  {
    if (zone_type[i] == 1)
    {
      // support zone
      if (zone_strength[i] == ZONE_TURNCOAT)
        continue;
      else if (zone_strength[i] == ZONE_WEAK)
        supports++;
      else if (zone_strength[i] == ZONE_VERIFIED)
        supports++;
      else if (zone_strength[i] == ZONE_UNTESTED)
        supports++;
      else if (zone_strength[i] == ZONE_POSSIBLE)
        supports++;
      else
        continue;
    }
    else if (zone_type[i] == 2)
    {
      // support zone
      if (zone_strength[i] == ZONE_TURNCOAT)
        continue;
      else if (zone_strength[i] == ZONE_WEAK)
        resistances++;
      else if (zone_strength[i] == ZONE_VERIFIED)
        resistances++;
      else if (zone_strength[i] == ZONE_UNTESTED)
        resistances++;
      else if (zone_strength[i] == ZONE_POSSIBLE)
        resistances++;
      else
        continue;
    }
  }
}