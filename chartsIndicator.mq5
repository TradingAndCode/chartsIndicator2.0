//+------------------------------------------------------------------+
//|                                       Indicator: chartsIndicator |
//|                                       Created By Steven Nkeneng  |
//|                                     https://www.stevennkeneng.com|
//+------------------------------------------------------------------+
#property copyright "Steven Nkeneng (Trading & Code) - 2021-2022"
#property link "https://tradingandcode.com"
#property version "2.00"
#property description "Indicator sending trade signal based on ... with filter"
#property description " "
#property description "WARNING : You use this software at your own risk."
#property description "The creator of these plugins cannot be held responsible for damage or loss."
#property description " "
#property description "Find More on tradingandcode.com"
#property icon "\\Images\\logo-steven.ico"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots 9

#property indicator_type1 DRAW_ARROW
#property indicator_width1 3
#property indicator_color1 0xFFFFFF
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 3
#property indicator_color2 0xFFFFFF
#property indicator_label2 "Sell"

#property indicator_label3 "" // revenge buy
#property indicator_label4 "" // revenge sell


#property indicator_label5 "candle index"

#include "headers/defines.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//|               indicator buffers                                  |
//|                                                                  |
//+------------------------------------------------------------------+
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Index[];

//+------------------------------------------------------------------+
//|                                                                  |
//|              custom types                                        |
//|                                                                  |
//+------------------------------------------------------------------+
enum TradeType
{
  Buy = 1,
  Sell = 2
};

enum SignalMode
{
  Aggressiv = 1,
  Secured = 2
};

//+------------------------------------------------------------------+
//|                                                                  |
//|                          inputs                                  |
//|                                                                  |
//+------------------------------------------------------------------+
input bool Audible_Alerts = true;
input bool Push_Notifications = true;
input TradeType tradeType = Buy;
input bool showAll = true;
input SignalMode signalMode = Secured;
input bool ma_Filter = true;
input bool macd_Filter = true;


//+------------------------------------------------------------------+
//|                                                                  |
//|                          variables                               |
//|                                                                  |
//+------------------------------------------------------------------+
int lastFlatIndex = 0;
double lastFlatPrice = 0;
bool flatTenkanFound = false;
bool nextCandleGreaterThanFlat = false;
double nextCandleGreaterThanFlatPrice = 0;
bool tenkanSmallerThanFlat = false;
bool tenkanCandleComingToFlat = false;
double tenkanCandleComingToFlatPrice = 0;
bool triangleFound = false;
bool revengeSignal = true;

datetime time_alert; // used when sending alert
double myPoint;      // initialized in OnInit

double High[];
double Open[];
double Close[];
double Low[];
double Time[];


//+------------------------------------------------------------------+
//|                                                                  |
//|                          handles                                 |
//|                                                                  |
//+------------------------------------------------------------------+
int ATR_handle;
double ATR[];

int Ichimoku_handle;
double Ichimoku_tenkan[];

int MACD_handle;
double MACD_Main[];

int MA_handle;
double MA[];

int MATrend_handle;
double MATrend[];

//+------------------------------------------------------------------+
//|                                                                  |
//|             authorized logins                                    |
//|                                                                  |
//+------------------------------------------------------------------+
long LoginsArray[] = {
    3170564,
    3542835,  // hermann
    20323508, // darlin
    20203654, // darlin
    20208253, // fahad
};

//------------------------------------------------------------------------------------------------------------
//--------------------------------------------- pips counter  ----------------------------------------
//--- Vars and arrays

color color1 = LimeGreen;
color color2 = clrRed;
int corner = 1;
extern bool testing = false;

bool Initialized = false; // Has the INIT function finished?
double PipSize = 0;

string Saved_Variable_Old_Period = "";

double currentMZH = NULL, currentMZL = NULL;

double pips = 0;

int prevCalculated = 0;

int numberOfPositions = 0;

int supports = 0;
int resistances = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//|                         headers                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#include "headers/initmql4.mqh"

#include "headers/utils.mqh"

#include "headers/signalMonitoring.mqh"

#include "headers/signal.mqh"

#include "headers/flatDetector.mqh"

#include "headers/pipscounter.mqh"

#include "headers/levels.mqh"

#include "headers/moreinfo.mqh"

#include "headers/drawObjects.mqh"

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

#include "headers/Initchecks_stecator.mqh"

  int initResult = OnSignalInit();

  if (initResult == INIT_FAILED)
  {
    return initResult;
  }

  int initRsResult = InitRS();

  if (initRsResult == INIT_FAILED)
  {
    return initRsResult;
  }

  onInitMoreInfo();

  createPipsValue();

  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  prevCalculated = prev_calculated - 1;
  OnCalcSignal(rates_total, prev_calculated);
  OnCalcRS(rates_total, prev_calculated);
  calculateRSNumber();
  startPipsCounter();
  startMoreInfo();
  return (rates_total);
}
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
  DeleteRS();
  ObjectsDeleteAll(0, "bsri_pips", 0, OBJ_LABEL);
  ObjectsDeleteAll(0, "stecatorInfo", 0, OBJ_LABEL);
  ObjectsDeleteAll(0, indicatorName, 0, OBJ_LABEL);
  ObjectsDeleteAll(0, indicatorName, 0, OBJ_TREND);
  ObjectsDeleteAll(0, indicatorName, 0, OBJPROP_RAY);
  ObjectsDeleteAll(0, indicatorName, 0, OBJ_HLINE);
  ObjectsDeleteAll(0, indicatorName, 0, OBJ_VLINE);
  Comment("");
}