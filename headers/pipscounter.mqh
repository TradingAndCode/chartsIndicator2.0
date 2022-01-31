
void calcProfitAll(double &out)
{

  double profit = 0;
  double p = 0;
  if (PositionsTotal() != numberOfPositions)
  {
    createPipsValue();
  }
  if (PositionsTotal() > 0)
  {
    for (int i = 0; i < PositionsTotal(); i++)
    {

      p = 0;

      if (PositionGetTicket(i) >= 0)
      {
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
          p = (SymbolInfoDouble(PositionGetSymbol(i), SYMBOL_BID) - PositionGetDouble(POSITION_PRICE_OPEN)) / SymbolInfoDouble(PositionGetSymbol(i), SYMBOL_POINT);
        }

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
          p = (PositionGetDouble(POSITION_PRICE_OPEN) - SymbolInfoDouble(PositionGetSymbol(i), SYMBOL_ASK)) / SymbolInfoDouble(PositionGetSymbol(i), SYMBOL_POINT);
        }

        profit += p;

        ObjectSetTextMQL4("bsri_pips" + PositionGetSymbol(i) + i, PositionGetSymbol(i) + " : " + sign(p) + DoubleToString(MathAbs(p) / 10, 1));

        ObjectSetMQL4("bsri_pips" + PositionGetSymbol(i) + i, OBJPROP_YDISTANCE, 25 + i * 30);

        if (p < 0)
        {
          ObjectSetMQL4("bsri_pips" + PositionGetSymbol(i) + i, OBJPROP_COLOR, color2);
        }
        else
        {
          ObjectSetMQL4("bsri_pips" + PositionGetSymbol(i) + i, OBJPROP_COLOR, color1);
        }
      }
    }

    ObjectSetTextMQL4("bsri_pipstotal", sign(profit) + DoubleToString(MathAbs(profit) / 10, 1), 15);
    if (profit < 0)
    {
      ObjectSetMQL4("bsri_pipstotal", OBJPROP_COLOR, color2);
    }
    else
    {
      ObjectSetMQL4("bsri_pipstotal", OBJPROP_COLOR, color1);
    }
  }
}

void calcProfit(double &out)
{

  double profit = 0;
  double p = 0;

  for (int i = 0; i < PositionsTotal(); i++)
  {
    if (PositionGetTicket(i) >= 0)
    {

      if (PositionGetSymbol(i) == Symbol())
      {
        p = 0;

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
          p = (Bid - PositionGetDouble(POSITION_PRICE_OPEN)) / Point();
        }

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
          p = (PositionGetDouble(POSITION_PRICE_OPEN) - Ask) / Point();
        }
        profit += p;
      }
    }
  }

  ObjectSetTextMQL4("bsri_pipstotal", sign(profit) + DoubleToString(MathAbs(profit) / 10, 1), 15);
  if (profit < 0)
  {
    ObjectSetMQL4("bsri_pipstotal", OBJPROP_COLOR, color2);
  }
  else
  {
    ObjectSetMQL4("bsri_pipstotal", OBJPROP_COLOR, color1);
  }
}


int startPipsCounter()
{

  double profit;
  double sl;
  if (showAll)
  {
    calcProfitAll(profit);
  }
  else
  {
    calcProfit(profit);
  }

  return (0);
}

void createPipsValue()
{
  numberOfPositions = PositionsTotal();
  ObjectsDeleteAll(0, "bsri_pips", 0, OBJ_LABEL);
  string label1 = "bsri_pipstotallabel";
  ObjectCreateMQL4(label1, OBJ_LABEL, 0, 0, 0);
  ObjectSetInteger(0, label1, OBJPROP_FONTSIZE, 15);
  ObjectSetMQL4(label1, OBJPROP_CORNER, 1);
  ObjectSetTextMQL4(label1, "STECATOR PIPS : ", 15);
  ObjectSetMQL4(label1, OBJPROP_COLOR, clrWhite);
  ObjectSetInteger(0, label1, OBJPROP_HIDDEN, false);
  ObjectSetInteger(0, label1, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, label1, OBJPROP_SELECTED, false);
  ObjectSetMQL4(label1, OBJPROP_YDISTANCE, 100);
  ObjectSetMQL4(label1, OBJPROP_XDISTANCE, 20);

  string label2 = "bsri_pipstotal";
  ObjectCreateMQL4(label2, OBJ_LABEL, 0, 0, 0);
  ObjectSetInteger(0, label2, OBJPROP_FONTSIZE, 15);
  ObjectSetMQL4(label2, OBJPROP_CORNER, corner);
  ObjectSetMQL4(label2, OBJPROP_COLOR, clrGreen);
  ObjectSetTextMQL4(label2, (string)0, 15);
  ObjectSetMQL4(label2, OBJPROP_YDISTANCE, 100);
  ObjectSetMQL4(label2, OBJPROP_XDISTANCE, 200);
  ObjectSetInteger(0, label2, OBJPROP_HIDDEN, true);
  ObjectSetInteger(0, label2, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, label2, OBJPROP_SELECTED, false);

  if (showAll)
  {
    ObjectSetMQL4(label1, OBJPROP_YDISTANCE, PositionsTotal() * 30 + 50);
    ObjectSetMQL4(label2, OBJPROP_YDISTANCE, PositionsTotal() * 30 + 50);
    for (int i = 0; i < PositionsTotal(); i++)
    {
      if (PositionGetTicket(i) >= 0)
      {
        string label = "bsri_pips" + PositionGetSymbol(i) + i;
        ObjectCreateMQL4(label, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, label, OBJPROP_FONTSIZE, 14);
        ObjectSetMQL4(label, OBJPROP_CORNER, corner);
        ObjectSetMQL4(label, OBJPROP_COLOR, color1);
        ObjectSetMQL4(label, OBJPROP_XDISTANCE, 20);
        ObjectSetMQL4(label, OBJPROP_YDISTANCE, 20 + i * 10);
        ObjectSetInteger(0, label, OBJPROP_HIDDEN, false);
        ObjectSetInteger(0, label, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, label, OBJPROP_SELECTED, false);
      }
    }
  }
}