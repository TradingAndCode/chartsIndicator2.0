int OnSignalInit()
{
    SetIndexBuffer(0, Buffer1);
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetInteger(0, PLOT_ARROW, 233);

    SetIndexBuffer(1, Buffer2);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetInteger(1, PLOT_ARROW, 234);

    SetIndexBuffer(2, Buffer3);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);

    SetIndexBuffer(3, Buffer4);
    PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);

    SetIndexBuffer(4, Index);
    PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);

    // initialize myPoint
    myPoint = Point();
    if (Digits() == 5 || Digits() == 3)
    {
        myPoint *= 10;
    }

    MA_handle = iMA(NULL, PERIOD_CURRENT, 25, 0, MODE_LWMA, PRICE_CLOSE);

    if (MA_handle < 0)
    {
        Print("The creation of iMA has failed: MA_handle=", INVALID_HANDLE);
        Print("Runtime error = ", GetLastError());
        return (INIT_FAILED);
    }

    MATrend_handle = iMA(NULL, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);

    if (MATrend_handle < 0)
    {
        Print("The creation of iMA has failed: MATrend_handle=", INVALID_HANDLE);
        Print("Runtime error = ", GetLastError());
        return (INIT_FAILED);
    }

    Ichimoku_handle = iIchimoku(NULL, PERIOD_CURRENT, 9, 26, 52);
    if (Ichimoku_handle < 0)
    {
        Print("The creation of iIchimoku has failed: Ichimoku_handle=", INVALID_HANDLE);
        Print("Runtime error = ", GetLastError());
        return (INIT_FAILED);
    }

    MACD_handle = iMACD(NULL, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
    if (MACD_handle < 0)
    {
        Print("The creation of iMACD has failed: MACD_handle=", INVALID_HANDLE);
        Print("Runtime error = ", GetLastError());
        return (INIT_FAILED);
    }

    return INIT_SUCCEEDED;
}

int OnCalcSignal(int rates_total, int prev_calculated)
{
    int limit = rates_total - prev_calculated;
    //--- counting from 0 to rates_total

    ArraySetAsSeries(Buffer1, true);
    ArraySetAsSeries(Buffer2, true);
    ArraySetAsSeries(Buffer3, true);
    ArraySetAsSeries(Buffer4, true);
    //--- initial zero
    if (prev_calculated < 1)
    {
        ArrayInitialize(Buffer1, EMPTY_VALUE);
        ArrayInitialize(Buffer2, EMPTY_VALUE);
        ArrayInitialize(Buffer3, EMPTY_VALUE);
        ArrayInitialize(Buffer4, EMPTY_VALUE);
    }
    else
        limit++;

    datetime Time[];

    if (BarsCalculated(MA_handle) <= 0)
        return (0);
    if (CopyBuffer(MA_handle, 0, 0, rates_total, MA) <= 0)
        return (rates_total);
    ArraySetAsSeries(MA, true);

    if (BarsCalculated(MATrend_handle) <= 0)
        return (0);
    if (CopyBuffer(MATrend_handle, 0, 0, rates_total, MATrend) <= 0)
        return (rates_total);
    ArraySetAsSeries(MATrend, true);

    if (BarsCalculated(MACD_handle) <= 0)
        return (0);
    if (CopyBuffer(MACD_handle, MAIN_LINE, 0, rates_total, MACD_Main) <= 0)
        return (rates_total);
    ArraySetAsSeries(MACD_Main, true);

    if (CopyLow(Symbol(), PERIOD_CURRENT, 0, rates_total, Low) <= 0)
        return (rates_total);
    ArraySetAsSeries(Low, true);

    if (CopyClose(Symbol(), PERIOD_CURRENT, 0, rates_total, Close) <= 0)
        return (rates_total);
    ArraySetAsSeries(Close, true);

    if (CopyOpen(Symbol(), PERIOD_CURRENT, 0, rates_total, Open) <= 0)
        return (rates_total);
    ArraySetAsSeries(Open, true);

    if (CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0)
        return (rates_total);
    ArraySetAsSeries(High, true);

    if (CopyTime(Symbol(), Period(), 0, rates_total, Time) <= 0)
        return (rates_total);
    ArraySetAsSeries(Time, true);

    if (BarsCalculated(Ichimoku_handle) <= 0)
        return (0);
    if (CopyBuffer(Ichimoku_handle, TENKANSEN_LINE, 0, rates_total, Ichimoku_tenkan) <= 0)
        return (rates_total);
    ArraySetAsSeries(Ichimoku_tenkan, true);

    ArraySetAsSeries(Index, true);

    double value = 0;

    //--- main loop
    for (int i = limit - 1; i >= 0; i--)
    {
        if (i >= MathMin(5000 - 1, rates_total - 1 - 50))
            continue; // omit some old rates to prevent "Array out of range" or slow calculation

        double nextCandleTenkan = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 0, i + 1);

        Index[i] = i;

        if (!flatTenkanFound)
        {
            if (DetectFlatTenkan(value, i + 1))
            {
                // flat detected
            }
        }
        else
        {
            if (NewOldBar(i))
            {
                if (tradeType == Sell)
                {
                    monitorSellEntry(nextCandleTenkan, i + 1);
                }
                else
                    monitorBuyEntry(nextCandleTenkan, i + 1);
            }
        }

        bool normalTradeBuy = tradeType == Buy && triangleFound;

        bool normalTradeSell = tradeType == Sell && triangleFound;

        bool revengeTradeBuy = tradeType == Buy && revengeSignal && Close[i + 1] < Open[i + 1];
        // bool revengeTradeBuy = tradeType == Buy && revengeSignal && Close[i + 2] < Open[i + 2] && Close[i + 1] > Open[i + 1];
        bool revengeTradeSell = tradeType == Sell && revengeSignal && Close[i + 1] > Open[i + 1];
        // bool revengeTradeSell = tradeType == Sell && revengeSignal && Close[i + 2] > Open[i + 2] && Close[i + 1] < Open[i + 1];

        if (normalTradeBuy)
        {
            Buffer1[i + 1] = Low[1 + i]; // Set indicator value at Candlestick Low
            if (normalTradeBuy)
            {
                resetAll();
            }

            if (i == 0 && Time[0] != time_alert)
            {
                myAlert("indicator", "Buy");
                time_alert = Time[0];
            } // Instant alert, only once per bar
        }
        else
        {
            if (Buffer1[i + 1] != Low[1 + i])
            {
                Buffer1[i + 1] = EMPTY_VALUE;
            }
        }

        if (revengeTradeBuy)
        {
            Buffer3[i + 1] = Low[1 + i]; // Set indicator value at Candlestick Low
            if (normalTradeBuy)
            {
                resetAll();
            }
        }
        else
        {
            if (Buffer3[i + 1] != Low[1 + i])
            {
                Buffer3[i + 1] = EMPTY_VALUE;
            }
        }

        if (normalTradeSell)
        {
            Buffer2[i + 1] = High[i + 1]; // Set indicator value at Candlestick High
            if (normalTradeSell)
            {
                resetAll();
            }
            if (i == 0 && Time[0] != time_alert)
            {
                myAlert("indicator", "Sell");
                time_alert = Time[0];
            } // Instant alert, only once per bar
        }
        else
        {
            if (Buffer2[i + 1] != High[i + 1])
            {
                Buffer2[i + 1] = EMPTY_VALUE;
            }
        }

        if (revengeTradeSell)
        {
            Buffer4[i + 1] = High[i + 1]; // Set indicator value at Candlestick High
        }
        else
        {
            if (Buffer4[i + 1] != High[i + 1])
            {
                Buffer4[i + 1] = EMPTY_VALUE;
            }
        }
    }
    return 0;
}
