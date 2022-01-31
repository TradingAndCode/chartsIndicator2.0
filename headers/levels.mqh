
//------------------------------------------------------------------------------------------------------------
//--------------------------------------------- RS  ----------------------------------------
//--- Vars and arrays

int BackLimit = 1000;
int TimeFrame = 0;
string TimeString = "0=Current, 15=M15, 30=M30, 60=H1, 240=H4, 1440=Day, 10080=Week, 43200=Month";

bool zone_show_untested = true;
bool zone_show_verified = true;
bool zone_show_truncoat = false;
bool zone_show_weak = true;
bool zone_show_possible = true;
bool zone_showbroken = false;

bool zone_show_alerts = false;
bool zone_alert_popups = false;
bool zone_alert_sounds = false;
bool send_email = false;
bool use_push = false;
int zone_alert_waitseconds = 300;

bool filter_zone_alert = false;
bool filter_MA = true;
int TF_MA = 60;
int MA_FAST_PERIOD = 13;
int MA_FAST_METHOD = 1;
int MA_SLOW_PERIOD = 48;
int MA_SLOW_METHOD = 1;

bool zone_merge = true;
bool zone_extend = false;

int zone_limit = 1000;
bool zone_show_info = false;
bool zone_show_size = false;
int zone_label_shift = 3;
color color_label = clrYellow;      //Label color
string font_label = "Courier New"; //Label Font
int size_label = 9;                //Label size

string ZONES_COLOR = "==========COLOR ZONES==========";

color color_support_possible = C'33,44,33';
color color_support_untested = C'33,44,33';
color color_support_verified = C'33,44,33';
color color_support_weak = C'33,44,33';
color color_support_turncoat = OliveDrab;
color color_resist_possible = C'57,30,32';
color color_resist_untested = C'57,30,32';
color color_resist_verified = C'57,30,32';
color color_resist_weak = C'57,30,32';
color color_resist_turncoat = DarkOrange;
color color_broken_weak = DarkGray;
color color_broken_verified = Gray;
color color_broken_other = DimGray;

string ZONE_FRACTALS = "==========ZONE FRACTALS==========";
double zone_fuzzfactor = 0.75;
bool fractals_show = false;
double fractal_fast_factor = 3.0;
double fractal_slow_factor = 6.0;

string ZONES_GLOBAL_VAR = "==========ZONES GLOBAL VARIABLES==========";
bool SetGlobals = false;

string ZONES_TESTING_MODE = "==========ZONES TESTING==========";
bool Testing = false;        //TRUE == scrolling back the chart shows PAST zone "look"
bool ShowTestingBtn = false; //Show button to switch Testing mode On/Off
int TestingBtnX = 10;        //Position of this button
int TestingBtnY = 120;

int ID = MathRand() * TimeFrame;

string BtnSRTesting = "BtnSRTesting";

double FastDnPts[], FastUpPts[];
double SlowDnPts[], SlowUpPts[];

double zone_hi[], zone_lo[];
int zone_start[], zone_hits[], zone_type[], zone_strength[], zone_end[], zone_count = 0;
bool zone_turn[];

#define ZONE_SUPPORT 1
#define ZONE_RESIST 2
#define ZONE_BROKEN 3

#define ZONE_POSSIBLE 0
#define ZONE_TURNCOAT 1
#define ZONE_UNTESTED 2
#define ZONE_VERIFIED 3
#define ZONE_WEAK 4

#define UP_POINT 1
#define DN_POINT -1

int time_offset = 0;

int LastBar = 0;          //Last visible bar on the chart - in Testing mode


int InitRS()
{

  Initialized = false;

  GetPipInfo();

  ATR_handle = iATR(NULL, PERIOD_CURRENT, 10);
  if (ATR_handle < 0)
  {
    Print("The creation of iATR has failed: ATR_handle=", INVALID_HANDLE);
    Print("Runtime error = ", GetLastError());
    return (INIT_FAILED);
  }

  SetIndexBuffer(5, SlowDnPts);
  SetIndexBuffer(6, SlowUpPts);
  SetIndexBuffer(7, FastDnPts);
  SetIndexBuffer(8, FastUpPts);

  PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);
  PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_NONE);
  PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_NONE);
  PlotIndexSetInteger(8, PLOT_DRAW_TYPE, DRAW_NONE);

  if (TimeFrame != 1 && TimeFrame != 5 && TimeFrame != 15 &&
      TimeFrame != 60 && TimeFrame != 240 && TimeFrame != 1440 &&
      TimeFrame != 10080 && TimeFrame != 43200)
    TimeFrame = 0;

  if (TimeFrame < Period())
    TimeFrame = Period();

  zone_limit = MathMax(zone_limit, 100);
  ArrayResize(zone_hi, zone_limit);
  ArrayResize(zone_lo, zone_limit);
  ArrayResize(zone_start, zone_limit);
  ArrayResize(zone_hits, zone_limit);
  ArrayResize(zone_type, zone_limit);
  ArrayResize(zone_strength, zone_limit);
  ArrayResize(zone_end, zone_limit);
  ArrayResize(zone_turn, zone_limit);

  Initialized = true;
  return INIT_SUCCEEDED;
}

bool NewBar()
{
  int Shift = 0;
  if (Testing)
    Shift = LastBar;
  else
    Shift = 0;
  static datetime LastTime = 0;

  if (iTime(NULL, PERIOD_CURRENT, Shift) != LastTime)
  {
    LastTime = iTime(NULL, PERIOD_CURRENT, Shift) + time_offset;
    return (true);
  }
  else
    return (false);
}

void OnCalcRS(int rates_total, int prev_calculated)
{
  if (BarsCalculated(ATR_handle) <= 0)
  {
    Print("Bars calculated <= 0");
    return;
  }

  if (CopyBuffer(ATR_handle, 0, 0, rates_total, ATR) <= 0)
  {
    Print("copy buffer for atr unsuccesful");
    return;
  }

  ArraySetAsSeries(ATR, true);

  bool newbar = NewBar();
  OnNewBar();
  CheckAlerts();
}

void DeleteRS()
{
  DeleteGlobalVars();
  ObjectsDeleteAll(0, "SSSR#", 0, OBJ_RECTANGLE);
}

void OnNewBar()
{
  int old_zone_count = zone_count;

  FastFractals();
  SlowFractals();
  DeleteRS();
  FindZones();
  DrawZones();
  if (zone_count < old_zone_count)
    DeleteOldGlobalVars(old_zone_count);
  
  drawLabels();
}


void drawLabels(){
  if (zone_show_info == true)
        {
            for (int i = 0; i < zone_count; i++)
            {
                string lbl;
                if (zone_strength[i] == ZONE_WEAK)
                    lbl = "Weak";
                else if (zone_strength[i] == ZONE_VERIFIED)
                    lbl = "Verified";
                else if (zone_strength[i] == ZONE_UNTESTED)
                    lbl = "Untested";
                else if (zone_strength[i] == ZONE_TURNCOAT)
                    lbl = "Turncoat";
                else
                    lbl = "Possible";

                if (zone_type[i] == ZONE_SUPPORT)
                    lbl = lbl + " Support";
                else
                    lbl = lbl + " Resistance";

                if (zone_show_size == true)
                {
                    int tam = 0;
                    tam = (zone_hi[i] - zone_lo[i]) * (MathPow(10, Digits()));
                    lbl = lbl + "(" + tam + "p)";
                }

                if (zone_hits[i] > 0 && zone_strength[i] > ZONE_UNTESTED)
                {
                    if (zone_hits[i] == 1)
                        lbl = lbl + ", Test Count=" + zone_hits[i];
                    else
                        lbl = lbl + ", Test Count=" + zone_hits[i];
                }

                int adjust_hpos;
                int wbpc = ChartGetInteger(0,CHART_VISIBLE_BARS,0);
                int k;

                k = Period() * 60 + (20 + StringLen(lbl));

                if (wbpc < 80)
                    adjust_hpos = iTime(NULL, TFMigrate(TimeFrame), LastBar + 0) + k * 4;
                else if (wbpc < 125)
                    adjust_hpos = iTime(NULL, TFMigrate(TimeFrame), LastBar + 0) + k * 8;
                else if (wbpc < 250)
                    adjust_hpos = iTime(NULL, TFMigrate(TimeFrame), LastBar + 0) + k * 15;
                else if (wbpc < 480)
                    adjust_hpos = iTime(NULL, TFMigrate(TimeFrame), LastBar + 0) + k * 29;
                else if (wbpc < 950)
                    adjust_hpos = iTime(NULL, TFMigrate(TimeFrame), LastBar + 0) + k * 58;
                else
                    adjust_hpos = iTime(NULL, TFMigrate(TimeFrame), LastBar + 0) + k * 115;
                int shift = 0;
                if (LastBar > 0)
                     shift = -77 * Period() * 60; //maybe we should use   -zone_label_shift * k
                else
                    shift = k * zone_label_shift;

                double vpos = zone_hi[i] - (zone_hi[i] - zone_lo[i]) / 2;

                if (zone_strength[i] == ZONE_UNTESTED && zone_show_untested == false)
                {
                    continue;
                }

                if (zone_strength[i] == ZONE_VERIFIED && zone_show_verified == false)
                {
                    continue;
                }

                if (zone_strength[i] == ZONE_WEAK && zone_show_weak == false)
                {
                    continue;
                }

                if (zone_strength[i] == ZONE_TURNCOAT && zone_show_truncoat == false)
                {
                    continue;
                }

                if (zone_strength[i] == ZONE_POSSIBLE && zone_show_possible == false)
                {
                    continue;
                }

                string s = "SSSR#" + i + "LBL";
                ObjectCreateMQL4(s, OBJ_LABEL, 0, 0, 0);
                ObjectSetMQL4(s, OBJPROP_TIME1, adjust_hpos + shift);
                ObjectSetMQL4(s, OBJPROP_PRICE1, vpos);
                ObjectSetTextMQL4(s, StringRightPad(lbl, 36, " "),size_label, font_label, color_label);
            }
        }
}

string StringRightPad(string str, int n = 1, string str2 = " ")
{
    return (str + StringRepeat(str2, n - StringLen(str)));
}

string StringRepeat(string str, int n = 1)
{
    string outstr = "";
    for (int i = 0; i < n; i++)
        outstr = outstr + str;
    return (outstr);
}


void FastFractals()
{
  int counted = prevCalculated;
  int shift, limit;
  int P = TimeFrame * fractal_fast_factor;

  if (counted < 0)
    return;
  /** /
   if (counted > 0) 
      limit = MathMin(BackLimit, MathMax(P, Bars(_Symbol,_Period) - counted));
   else
      limit = MathMin(BackLimit, Bars(_Symbol,_Period)-1);
   /**/
  limit = MathMin(LastBar + BackLimit, Bars(_Symbol, _Period) - 1);
  //limit = MathMin(Bars-1, limit);

  FastUpPts[0] = 0.0;
  FastUpPts[1] = 0.0;
  FastDnPts[0] = 0.0;
  FastDnPts[1] = 0.0;

  for (shift = limit; shift > LastBar + 1; shift--)
  {
    if (Fractal(UP_POINT, P, shift) == true)
      FastUpPts[shift] = iHigh(NULL, PERIOD_CURRENT, shift);
    else
      FastUpPts[shift] = 0.0;

    if (Fractal(DN_POINT, P, shift) == true)
      FastDnPts[shift] = iLow(NULL, PERIOD_CURRENT, shift);
    else
      FastDnPts[shift] = 0.0;
  }
}

bool Fractal(int M, int P, int shift)
{

  if (TimeFrame > P)
    P = TimeFrame;

  P = P / TimeFrame * 2 + MathCeil(P / TimeFrame / 2);

  if (shift < P)
    return (false);

  if (shift > Bars(Symbol(), PERIOD_CURRENT) - P)
    return (false);

  for (int i = 1; i <= P; i++)
  {
    if (M == UP_POINT)
    {
      if (iHigh(NULL, PERIOD_CURRENT, shift + i) > iHigh(NULL, PERIOD_CURRENT, shift))
        return (false);
      if (iHigh(NULL, PERIOD_CURRENT, shift - i) >= iHigh(NULL, PERIOD_CURRENT, shift))
        return (false);
    }
    if (M == DN_POINT)
    {
      if (iLow(NULL, PERIOD_CURRENT, shift + i) < iLow(NULL, PERIOD_CURRENT, shift))
        return (false);
      if (iLow(NULL, PERIOD_CURRENT, shift - i) <= iLow(NULL, PERIOD_CURRENT, shift))
        return (false);
    }
  }
  return (true);
}

void SlowFractals()
{
  int counted = prevCalculated;
  int shift, limit;
  int P = TimeFrame * fractal_slow_factor;

  if (counted < 0)
    return;
  /** /
   if (counted > 0) 
      limit = MathMin(BackLimit, MathMax(P, Bars(_Symbol,_Period) - counted));
   else
      limit = MathMin(BackLimit, Bars(_Symbol,_Period)-1);
   /**/
  limit = MathMin(LastBar + BackLimit, Bars(_Symbol, _Period) - 1);
  // limit = MathMin(Bars-1, limit);

  SlowUpPts[0] = 0.0;
  SlowUpPts[1] = 0.0;
  SlowDnPts[0] = 0.0;
  SlowDnPts[1] = 0.0;

  for (shift = limit; shift > LastBar + 1; shift--)
  {
    if (Fractal(UP_POINT, P, shift) == true)
      SlowUpPts[shift] = iHigh(NULL, PERIOD_CURRENT, shift);
    else
      SlowUpPts[shift] = 0.0;

    if (Fractal(DN_POINT, P, shift) == true)
      SlowDnPts[shift] = iLow(NULL, PERIOD_CURRENT, shift);
    else
      SlowDnPts[shift] = 0.0;
  }
}


void FindZones()
{
  int i, j, shift, bustcount = 0, testcount = 0, brokebar;
  double hival, loval;
  bool turned = false, hasturned = false;

  double temp_hi[1000], temp_lo[1000];
  int temp_start[1000], temp_hits[1000], temp_strength[1000], temp_count = 0;
  bool temp_turn[1000], temp_merge[1000];
  double bust_hi[1000], bust_lo[1000];
  int bust_start[1000], bust_hits[1000], bust_strength[1000], bust_end[1000], bust_count = 0;
  bool bust_turn[1000], bust_merge[1000];
  int merge1[1000], merge2[1000], merge_count = 0;
  int berge1[1000], berge2[1000], berge_count = 0;

  // iterate through zones from oldest to youngest (ignore recent 5 bars),
  // finding those that have survived through to the present...

  for (shift = MathMin(Bars(_Symbol, PERIOD_CURRENT) - 1, LastBar + BackLimit); shift > LastBar + 5; shift--)
  {

    //double atr = ATR[shift];
    double atr = iATRMQL4(NULL, TimeFrame, 10, shift);
    double fu = atr / 2 * zone_fuzzfactor;

    bool isPossible;
    bool touchOk = false;
    bool isBust = false;
    double Close = iClose(NULL, PERIOD_CURRENT, shift);
    double High = iHigh(NULL, PERIOD_CURRENT, shift);
    double Low = iLow(NULL, PERIOD_CURRENT, shift);
    double hi_i;
    double lo_i;


    if (FastUpPts[shift] > 0.001)
    {
      // a zigzag High point
      isPossible = true;
      if (SlowUpPts[shift] > 0.001)
        isPossible = false;

      hival = High;
      if (zone_extend == true)
        hival += fu;

      loval = MathMax(MathMin(Close, High - fu), High - fu * 2);
      turned = false;
      hasturned = false;
      isBust = false;

      bustcount = 0;
      testcount = 0;
      brokebar = 0;

      for (i = shift - 1; i >= LastBar + 0; i--)
      {
        hi_i = iHigh(NULL, PERIOD_CURRENT, i);
        lo_i = iLow(NULL, PERIOD_CURRENT, i);

        if ((turned == false && FastUpPts[i] >= loval && FastUpPts[i] <= hival) ||
            (turned == true && FastDnPts[i] <= hival && FastDnPts[i] >= loval))
        {
          // Potential touch, just make sure its been 10+candles since the prev one
          touchOk = true;
          for (j = i + 1; j < i + 11; j++)
          {
            if ((turned == false && FastUpPts[j] >= loval && FastUpPts[j] <= hival) ||
                (turned == true && FastDnPts[j] <= hival && FastDnPts[j] >= loval))
            {
              touchOk = false;
              break;
            }
          }

          if (touchOk == true)
          {
            // we have a touch.  If its been busted once, remove bustcount
            // as we know this level is still valid & has just switched sides
            bustcount = 0;
            testcount++;
          }
        }

        if ((turned == false && hi_i > hival) ||
            (turned == true && lo_i < loval))
        {
          // this level has been busted at least once
          bustcount++;
          brokebar = MathMax(brokebar, i);

          if (bustcount > 1 || isPossible == true)
          {
            // busted twice or more
            isBust = true;
            break;
          }

          if (turned == true)
            turned = false;
          else if (turned == false)
            turned = true;

          hasturned = true;

          // forget previous hits
          testcount = 0;
        }
      }

      if (isBust == false)
      {
        // level is still valid, add to our list
        temp_hi[temp_count] = hival;
        temp_lo[temp_count] = loval;
        temp_turn[temp_count] = hasturned;
        temp_hits[temp_count] = testcount;
        temp_start[temp_count] = shift;
        temp_merge[temp_count] = false;

        if (testcount > 3)
          temp_strength[temp_count] = ZONE_WEAK;
        else if (testcount > 0)
          temp_strength[temp_count] = ZONE_VERIFIED;
        else if (hasturned == true)
          temp_strength[temp_count] = ZONE_TURNCOAT;
        else if (isPossible == false)
          temp_strength[temp_count] = ZONE_UNTESTED;
        else
          temp_strength[temp_count] = ZONE_POSSIBLE;

        temp_count++;
      }
      else if (zone_showbroken)
      {
        // level is broken, but we're showing it anyway
        bust_hi[bust_count] = hival;
        bust_lo[bust_count] = loval;
        bust_turn[bust_count] = hasturned;
        bust_hits[bust_count] = testcount;
        bust_start[bust_count] = shift;
        bust_end[bust_count] = brokebar;
        bust_merge[bust_count] = false;

        if (testcount > 3)
          bust_strength[bust_count] = ZONE_WEAK;
        else if (testcount > 0)
          bust_strength[bust_count] = ZONE_VERIFIED;
        else if (hasturned == true)
          bust_strength[bust_count] = ZONE_TURNCOAT;
        else if (isPossible == false)
          bust_strength[bust_count] = ZONE_UNTESTED;
        else
          bust_strength[bust_count] = ZONE_POSSIBLE;

        bust_count++;
      }
    }
    else if (FastDnPts[shift] > 0.001)
    {
      // a zigzag Low point
      isPossible = true;
      if (SlowDnPts[shift] > 0.001)
        isPossible = false;

      loval = Low;
      if (zone_extend == true)
        loval -= fu;

      hival = MathMin(MathMax(Close, Low + fu), Low + fu * 2);
      turned = false;
      hasturned = false;

      bustcount = 0;
      testcount = 0;
      brokebar = 0;
      isBust = false;

      for (i = shift - 1; i >= LastBar + 0; i--)
      {
        hi_i = iHigh(NULL, PERIOD_CURRENT, i);
        lo_i = iLow(NULL, PERIOD_CURRENT, i);

        if ((turned == true && FastUpPts[i] >= loval && FastUpPts[i] <= hival) ||
            (turned == false && FastDnPts[i] <= hival && FastDnPts[i] >= loval))
        {
          // Potential touch, just make sure its been 10+candles since the prev one
          touchOk = true;
          for (j = i + 1; j < i + 11; j++)
          {
            if ((turned == true && FastUpPts[j] >= loval && FastUpPts[j] <= hival) ||
                (turned == false && FastDnPts[j] <= hival && FastDnPts[j] >= loval))
            {
              touchOk = false;
              break;
            }
          }

          if (touchOk == true)
          {
            // we have a touch.  If its been busted once, remove bustcount
            // as we know this level is still valid & has just switched sides
            bustcount = 0;
            testcount++;
          }
        }

        if ((turned == true && hi_i > hival) ||
            (turned == false && lo_i < loval))
        {
          // this level has been busted at least once
          bustcount++;
          brokebar = MathMax(brokebar, i);

          if (bustcount > 1 || isPossible == true)
          {
            // busted twice or more
            isBust = true;
            break;
          }

          if (turned == true)
            turned = false;
          else if (turned == false)
            turned = true;

          hasturned = true;

          // forget previous hits
          testcount = 0;
        }
      }

      if (isBust == false)
      {
        // level is still valid, add to our list
        temp_hi[temp_count] = hival;
        temp_lo[temp_count] = loval;
        temp_turn[temp_count] = hasturned;
        temp_hits[temp_count] = testcount;
        temp_start[temp_count] = shift;
        temp_merge[temp_count] = false;

        if (testcount > 3)
          temp_strength[temp_count] = ZONE_WEAK;
        else if (testcount > 0)
          temp_strength[temp_count] = ZONE_VERIFIED;
        else if (hasturned == true)
          temp_strength[temp_count] = ZONE_TURNCOAT;
        else if (isPossible == false)
          temp_strength[temp_count] = ZONE_UNTESTED;
        else
          temp_strength[temp_count] = ZONE_POSSIBLE;

        temp_count++;
      }
      else if (zone_showbroken)
      {
        // level is broken, but we're showing it anyway
        bust_hi[bust_count] = hival;
        bust_lo[bust_count] = loval;
        bust_turn[bust_count] = hasturned;
        bust_hits[bust_count] = testcount;
        bust_start[bust_count] = shift;
        bust_end[bust_count] = brokebar;
        bust_merge[bust_count] = false;

        if (testcount > 3)
          bust_strength[bust_count] = ZONE_WEAK;
        else if (testcount > 0)
          bust_strength[bust_count] = ZONE_VERIFIED;
        else if (hasturned == true)
          bust_strength[bust_count] = ZONE_TURNCOAT;
        else if (isPossible == false)
          bust_strength[bust_count] = ZONE_UNTESTED;
        else
          bust_strength[bust_count] = ZONE_POSSIBLE;

        bust_count++;
      }
    }
  }

  // look for overlapping zones...
  if (zone_merge)
  {
    merge_count = 1;
    int iterations = 0, target, source;
    while (merge_count > 0 && iterations < 3)
    {
      merge_count = 0;
      iterations++;

      for (i = 0; i < temp_count; i++)
        temp_merge[i] = false;

      for (i = 0; i < temp_count - 1; i++)
      {
        //if (temp_hits[i] == -1 || temp_merge[j] == true) @TODO array out of range but not knowing why
        if (temp_hits[i] == -1 || temp_merge[i] == true)
          continue;

        for (j = i + 1; j < temp_count; j++)
        {
          if (temp_hits[j] == -1 || temp_merge[j] == true)
            continue;

          if ((temp_hi[i] >= temp_lo[j] && temp_hi[i] <= temp_hi[j]) ||
              (temp_lo[i] <= temp_hi[j] && temp_lo[i] >= temp_lo[j]) ||
              (temp_hi[j] >= temp_lo[i] && temp_hi[j] <= temp_hi[i]) ||
              (temp_lo[j] <= temp_hi[i] && temp_lo[j] >= temp_lo[i]))
          {
            merge1[merge_count] = i;
            merge2[merge_count] = j;
            temp_merge[i] = true;
            temp_merge[j] = true;
            merge_count++;
          }
        }
      }

      // ... and merge them ...
      for (i = 0; i < merge_count; i++)
      {
        target = merge1[i];
        source = merge2[i];

        temp_hi[target] = MathMax(temp_hi[target], temp_hi[source]);
        temp_lo[target] = MathMin(temp_lo[target], temp_lo[source]);
        temp_hits[target] += temp_hits[source];
        temp_start[target] = MathMax(temp_start[target], temp_start[source]);
        temp_strength[target] = MathMax(temp_strength[target], temp_strength[source]);
        if (temp_hits[target] > 3)
          temp_strength[target] = ZONE_WEAK;

        if (temp_hits[target] == 0 && temp_turn[target] == false)
        {
          temp_hits[target] = 1;
          if (temp_strength[target] < ZONE_VERIFIED)
            temp_strength[target] = ZONE_VERIFIED;
        }

        if (temp_turn[target] == false || temp_turn[source] == false)
          temp_turn[target] = false;
        if (temp_turn[target] == true)
          temp_hits[target] = 0;

        temp_hits[source] = -1;
      }
    }

    if (zone_showbroken)
    {
      // merge busted zones
      berge_count = 1;
      iterations = 0;
      while (berge_count > 0 && iterations < 3)
      {
        berge_count = 0;
        iterations++;

        for (i = 0; i < bust_count; i++)
          bust_merge[i] = false;

        for (i = 0; i < bust_count - 1; i++)
        {
          if (bust_hits[i] == -1 || bust_merge[j] == true)
            continue;

          for (j = i + 1; j < bust_count; j++)
          {
            if (bust_hits[j] == -1 || bust_merge[j] == true)
              continue;

            if ((bust_hi[i] >= bust_lo[j] && bust_hi[i] <= bust_hi[j]) ||
                (bust_lo[i] <= bust_hi[j] && bust_lo[i] >= bust_lo[j]) ||
                (bust_hi[j] >= bust_lo[i] && bust_hi[j] <= bust_hi[i]) ||
                (bust_lo[j] <= bust_hi[i] && bust_lo[j] >= bust_lo[i]))
            {
              berge1[berge_count] = i;
              berge2[berge_count] = j;
              bust_merge[i] = true;
              bust_merge[j] = true;
              berge_count++;
            }
          }
        }

        // ... and merge them ...
        for (i = 0; i < berge_count; i++)
        {
          target = berge1[i];
          source = berge2[i];

          bust_hi[target] = MathMax(bust_hi[target], bust_hi[source]);
          bust_lo[target] = MathMin(bust_lo[target], bust_lo[source]);
          bust_hits[target] += bust_hits[source];
          bust_start[target] = MathMax(bust_start[target], bust_start[source]);
          bust_end[target] = MathMax(bust_end[target], bust_end[source]);
          bust_strength[target] = MathMax(bust_strength[target], bust_strength[source]);
          if (bust_hits[target] > 3)
            bust_strength[target] = ZONE_WEAK;

          if (bust_hits[target] == 0 && bust_turn[target] == false)
          {
            bust_hits[target] = 1;
            if (bust_strength[target] < ZONE_VERIFIED)
              bust_strength[target] = ZONE_VERIFIED;
          }

          if (bust_turn[target] == false || bust_turn[source] == false)
            bust_turn[target] = false;
          if (bust_turn[target] == true)
            bust_hits[target] = 0;

          bust_hits[source] = -1;
        }
      }
    }
  }

  // copy the remaining list into our official zones arrays
  zone_count = 0;
  for (i = 0; i < temp_count; i++)
  {
    if (temp_hits[i] >= 0 && zone_count < zone_limit)
    {
      zone_hi[zone_count] = temp_hi[i];
      zone_lo[zone_count] = temp_lo[i];
      zone_hits[zone_count] = temp_hits[i];
      zone_turn[zone_count] = temp_turn[i];
      zone_start[zone_count] = temp_start[i];
      zone_strength[zone_count] = temp_strength[i];
      zone_end[zone_count] = LastBar + 0;

      if (zone_hi[zone_count] < iClose(NULL, PERIOD_CURRENT, LastBar + 4))
        zone_type[zone_count] = ZONE_SUPPORT;
      else if (zone_lo[zone_count] > iClose(NULL, PERIOD_CURRENT, LastBar + 4))
        zone_type[zone_count] = ZONE_RESIST;
      else
      {
        for (j = LastBar + 5; j < LastBar + 1000; j++)
        {
          if (iClose(NULL, PERIOD_CURRENT, j) < zone_lo[zone_count])
          {
            zone_type[zone_count] = ZONE_RESIST;
            break;
          }
          else if (iClose(NULL, PERIOD_CURRENT, j) > zone_hi[zone_count])
          {
            zone_type[zone_count] = ZONE_SUPPORT;
            break;
          }
        }

        if (j == LastBar + 1000)
          zone_type[zone_count] = ZONE_SUPPORT;
      }

      zone_count++;
    }
  }

  if (zone_showbroken)
  {
    for (i = bust_count - 1; i >= 0; i--)
    {
      if (bust_hits[i] >= 0 && zone_count < zone_limit)
      {
        zone_hi[zone_count] = bust_hi[i];
        zone_lo[zone_count] = bust_lo[i];
        zone_hits[zone_count] = bust_hits[i];
        zone_turn[zone_count] = bust_turn[i];
        zone_start[zone_count] = bust_start[i];
        zone_strength[zone_count] = bust_strength[i];
        zone_end[zone_count] = bust_end[i];
        zone_type[zone_count] = ZONE_BROKEN;
        zone_count++;
      }
    }
  }
}

void DeleteGlobalVars()
{
  if (SetGlobals == false)
    return;

  GlobalVariableDel("SSSR_Count_" + Symbol() + TimeFrame);
  GlobalVariableDel("SSSR_Updated_" + Symbol() + TimeFrame);

  int old_count = zone_count;
  zone_count = 0;
  DeleteOldGlobalVars(old_count);
}

void DeleteOldGlobalVars(int old_count)
{
  if (SetGlobals == false)
    return;

  for (int i = zone_count; i < old_count; i++)
  {
    GlobalVariableDel("SSSR_HI_" + Symbol() + TimeFrame + i);
    GlobalVariableDel("SSSR_LO_" + Symbol() + TimeFrame + i);
    GlobalVariableDel("SSSR_HITS_" + Symbol() + TimeFrame + i);
    GlobalVariableDel("SSSR_STRENGTH_" + Symbol() + TimeFrame + i);
    GlobalVariableDel("SSSR_AGE_" + Symbol() + TimeFrame + i);
  }
}

void CheckAlerts()
{
  static int lastalert = 0;

  if (zone_show_alerts == false)
    return;

  if (Time[0] - lastalert > zone_alert_waitseconds)
    if (CheckEntryAlerts() == true)
      lastalert = Time[0];
}


bool CheckEntryAlerts()
{
  // check for entries
  bool OK_ALERT = false;

  for (int i = 0; i < zone_count; i++)
  {
    OK_ALERT = false;

    if (Close[0] >= zone_lo[i] && Close[0] < zone_hi[i])
    {
      if (zone_show_alerts == true)
      {

        if (zone_strength[i] == ZONE_UNTESTED && zone_show_untested == true)
        {
          OK_ALERT = true;
        }

        if (zone_strength[i] == ZONE_VERIFIED && zone_show_verified == true)
        {
          OK_ALERT = true;
        }

        if (zone_strength[i] == ZONE_WEAK && zone_show_weak == true)
        {
          OK_ALERT = true;
        }

        if (zone_strength[i] == ZONE_TURNCOAT && zone_show_truncoat == true)
        {
          OK_ALERT = true;
        }

        if (zone_strength[i] == ZONE_POSSIBLE && zone_show_possible == true)
        {
          OK_ALERT = true;
        }

        if ((zone_alert_popups == true) && (OK_ALERT == true))
        {
          if (zone_type[i] == ZONE_SUPPORT)
            Alert(Symbol() + TimeFrameToString(TimeFrame) + ": [Support] Zone Entered");
          else
            Alert(Symbol() + TimeFrameToString(TimeFrame) + ": [Resistance] Zone Entered");
        }

        if ((zone_alert_sounds == true) && (OK_ALERT == true))
        {
          PlaySound("alert.wav");
        }

        if ((use_push == true) && (OK_ALERT == true))
        {
          string sym = Symbol();
          string dirp = "";
          string msgp = StringConcatenate(sym, "-", TimeFrameToString(TimeFrame), " at ", TimeToString(Time[0], TIME_DATE | TIME_SECONDS),
                                          " ", dirp, " Zone Entered");
          if (zone_type[i] == ZONE_SUPPORT)
          {
            dirp = "[Support]";
            SendNotification("Stecator RS alert" + msgp);
          }
          else
          {
            dirp = "[Resistance]";
            SendNotification("Stecator RS alert: " + msgp);
          }
          msgp = StringConcatenate(sym, "-", TimeFrameToString(TimeFrame), " at ", TimeToString(Time[0], TIME_DATE | TIME_SECONDS),
                                   " ", dirp, " Zone Entered");

          SendNotification("Stecator RS alert: " + msgp);
        }
      }

      return (true);
    }
  }

  return (false);
}


void DrawZones()
{
  if (SetGlobals == true)
  {
    GlobalVariableSet("SSSR_Count_" + Symbol() + TimeFrame, zone_count);
    GlobalVariableSet("SSSR_Updated_" + Symbol() + TimeFrame, TimeCurrent());
  }

  for (int i = 0; i < zone_count; i++)
  {

    if (zone_strength[i] == ZONE_UNTESTED && zone_show_untested == false)
    {
      continue;
    }

    if (zone_strength[i] == ZONE_VERIFIED && zone_show_verified == false)
    {
      continue;
    }

    if (zone_strength[i] == ZONE_POSSIBLE && zone_show_possible == false)
      continue;

    if (zone_strength[i] == ZONE_WEAK && zone_show_weak == false)
      continue;

    if (zone_strength[i] == ZONE_TURNCOAT && zone_show_truncoat == false)
      continue;

    string s = "SSSR#" + i + " Strength=";
    if (zone_strength[i] == ZONE_WEAK)
      s = s + "Weak, Test Count=" + zone_hits[i];
    else if (zone_strength[i] == ZONE_VERIFIED)
      s = s + "Verified, Test Count=" + zone_hits[i];
    else if (zone_strength[i] == ZONE_UNTESTED)
      s = s + "Untested";
    else if (zone_strength[i] == ZONE_TURNCOAT)
      s = s + "Turncoat";
    else
      s = s + "Possible";

    string sBorder = "SSSR#Border" + i + " Strength=";
    if (zone_strength[i] == ZONE_WEAK)
      s = s + "Weak, Test Count=" + zone_hits[i];
    else if (zone_strength[i] == ZONE_VERIFIED)
      s = s + "Verified, Test Count=" + zone_hits[i];
    else if (zone_strength[i] == ZONE_UNTESTED)
      s = s + "Untested";
    else if (zone_strength[i] == ZONE_TURNCOAT)
      s = s + "Turncoat";
    else
      s = s + "Possible";

    ObjectCreateMQL4(s, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, s, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, s, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, s, OBJPROP_SELECTED, false);
    ObjectCreateMQL4(sBorder, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, sBorder, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, sBorder, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, sBorder, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, s, OBJPROP_TIME, iTime(NULL, PERIOD_CURRENT, zone_start[i]));
    ObjectSetInteger(0, sBorder, OBJPROP_TIME, iTime(NULL, PERIOD_CURRENT, zone_start[i]));

    if (LastBar > 0)
    {
      ObjectSetInteger(0, s, OBJPROP_TIME, 1, iTime(NULL, PERIOD_CURRENT, zone_end[i]) - 3 * Period() * 60);
      ObjectSetInteger(0, sBorder, OBJPROP_TIME, 1, iTime(NULL, PERIOD_CURRENT, zone_end[i]) - 3 * Period() * 60);
    }

    else
    {
      ObjectSetInteger(0, s, OBJPROP_TIME, 1, iTime(NULL, PERIOD_CURRENT, zone_end[i]) + 3 * Period() * 60);
      ObjectSetInteger(0, sBorder, OBJPROP_TIME, 1, iTime(NULL, PERIOD_CURRENT, zone_end[i]) + 3 * Period() * 60);
    }

    ObjectSetDouble(0, s, OBJPROP_PRICE, zone_hi[i]);
    ObjectSetDouble(0, sBorder, OBJPROP_PRICE, zone_hi[i]);
    ObjectSetDouble(0, s, OBJPROP_PRICE, 1, zone_lo[i]);
    ObjectSetDouble(0, sBorder, OBJPROP_PRICE, 1, zone_lo[i]);
    ObjectSetInteger(0, s, OBJPROP_BACK, true);
    ObjectSetInteger(0, s, OBJPROP_FILL, true);
    ObjectSetInteger(0, sBorder, OBJPROP_BACK, false);
    ObjectSetInteger(0, s, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, sBorder, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, s, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, sBorder, OBJPROP_STYLE, STYLE_DOT);

    if (zone_type[i] == ZONE_SUPPORT)
    {
      ObjectSetInteger(0, sBorder, OBJPROP_COLOR, clrGreen);
      // support zone
      if (zone_strength[i] == ZONE_TURNCOAT)
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_turncoat);
      else if (zone_strength[i] == ZONE_WEAK)
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_weak);
      else if (zone_strength[i] == ZONE_VERIFIED)
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_verified);
      else if (zone_strength[i] == ZONE_UNTESTED)
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_untested);
      else
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_possible);
    }
    else if (zone_type[i] == ZONE_RESIST)
    {
      ObjectSetInteger(0, sBorder, OBJPROP_COLOR, clrRed);
      // resistance zone
      if (zone_strength[i] == ZONE_TURNCOAT)
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_turncoat);
      else if (zone_strength[i] == ZONE_WEAK)
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_weak);
      else if (zone_strength[i] == ZONE_VERIFIED)
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_verified);
      else if (zone_strength[i] == ZONE_UNTESTED)
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_untested);
      else
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_possible);
    }
    else // broken zones
    {
      if (zone_strength[i] == ZONE_WEAK)
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_broken_weak);
      else if (zone_strength[i] == ZONE_VERIFIED)
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_broken_verified);
      else
        ObjectSetInteger(0, s, OBJPROP_COLOR, color_broken_other);
    }

    if (SetGlobals == true && zone_type[i] != ZONE_BROKEN)
    {
      GlobalVariableSet("SSSR_HI_" + Symbol() + TimeFrame + i, zone_hi[i]);
      GlobalVariableSet("SSSR_LO_" + Symbol() + TimeFrame + i, zone_lo[i]);
      GlobalVariableSet("SSSR_HITS_" + Symbol() + TimeFrame + i, zone_hits[i]);
      GlobalVariableSet("SSSR_STRENGTH_" + Symbol() + TimeFrame + i, zone_strength[i]);
      GlobalVariableSet("SSSR_AGE_" + Symbol() + TimeFrame + i, zone_start[i]);
    }
  }
}
