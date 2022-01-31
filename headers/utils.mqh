//+------------------------------------------------------------------+
//|                                                         utils.mqh |
//|                                                   Steven Nkeneng |
//|                                        https://stevennkeneng.com |
//+------------------------------------------------------------------+
#property copyright "Steven Nkeneng"
#property link "https://stevennkeneng.com"

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

void myAlert(string type, string message, string symbol = "", int timeframe = 0)
{

  if (timeframe == 0)
  {
    timeframe == Period();
  }
  if (symbol == "")
  {
    symbol = Symbol();
  }

  if (type == "print")
    Print(message);
  else if (type == "error")
  {
    Print(indicatorName + " @ " + symbol + "," + TimeFrameToString(timeframe) + " | " + message);
  }
  else if (type == "order")
  {
  }
  else if (type == "modify")
  {
  }
  else if (type == "indicator")
  {
    if (Audible_Alerts)
    {
      if (message == "Buy" || message == "Buy Strategie 4" || message == "Buy Strategie 3")
      {
        Alert(indicatorName + " @ " + symbol + "," + TimeFrameToString(timeframe) + " | " + message + " : " + Ask);
      }
      else if (message == "Sell" || message == "Sell Strategie 4" || message == "Sell Strategie 3")
      {
        Alert(indicatorName + " @ " + symbol + "," + TimeFrameToString(timeframe) + " | " + message + " : " + Bid);
      }

      else
      {
        return;
      }
    }

    if (Push_Notifications)
    {
      if (message == "Buy" || message == "Buy Strategie 4" || message == "Buy Strategie 3")
      {
        SendNotification(indicatorName + " @ " + symbol + "," + TimeFrameToString(timeframe) + " | " + message + " : " + Ask);
      }
      else if (message == "Sell" || message == "Sell Strategie 4" || message == "Sell Strategie 3")
      {
        SendNotification(indicatorName + " @ " + symbol + "," + TimeFrameToString(timeframe) + " | " + message + " : " + Bid);
      }
      else
      {
        return;
      }
    }
  }
}

void GetPipInfo()
{
  //---- Automatically adjust one decimal place left for Gold
  if (Symbol() == "XAUUSD" || Symbol() == "GOLD")
  {
    PipSize = 0.1;
  }
  else
  { // not GOLD
    switch (Digits())
    {
    case 6:
    case 5:

      PipSize = 0.0001;
      break;
    case 4:

      PipSize = 0.0001;
      break;
    case 3:

      PipSize = 0.01;
      break;
    case 2:

      PipSize = 0.01;
      break;
    case 1:

      PipSize = 0.1;
    }
  }
}

string sign(double value)
{
  if (value > 0)
  {
    return ("+");
  }
  else if (value < 0)
  {
    return ("-");
  }
  else
  {
    return "";
  }
}

double bid()
{
  return SymbolInfoDouble(Symbol(), SYMBOL_BID);
}

double ask()
{
  return SymbolInfoDouble(Symbol(), SYMBOL_ASK);
}

string TimeFrameToString(int tf) // code by TRO
{
  string tfs;

  switch (tf)
  {
  case PERIOD_M1:
    tfs = "M1";
    break;
  case PERIOD_M5:
    tfs = "M5";
    break;
  case PERIOD_M15:
    tfs = "M15";
    break;
  case PERIOD_M30:
    tfs = "M30";
    break;
  case PERIOD_H1:
    tfs = "H1";
    break;
  case PERIOD_H4:
    tfs = "H4";
    break;
  case PERIOD_D1:
    tfs = "D1";
    break;
  case PERIOD_W1:
    tfs = "W1";
    break;
  case PERIOD_MN1:
    tfs = "MN";
  }

  return (tfs);
}

//+-----------------------------------------------------------------------------------------------+
//| Method for converting every string formatted timeframe to normal timeframe                    |
//+-----------------------------------------------------------------------------------------------+
int stringToTimeFrame(string tf)
{
  for (int i = ArraySize(sTfTable) - 1; i >= 0; i--)
    if (tf == sTfTable[i])
      return (iTfTable[i]);
  return (0);
}

template <typename T>
int array_contains(const T &arr[], T what)
{
  int i = ArraySize(arr);
  while (--i >= 0)
    if (arr[i] == what)
      break;
  return i;
}
