
void monitorSellEntry(double nextCandleTenkan, int i)
{
    if (!nextCandleGreaterThanFlat)
    {
        if (lastFlatPrice > 0)
        {

            if (nextCandleTenkan > lastFlatPrice)
            {
                nextCandleGreaterThanFlat = true;
                nextCandleGreaterThanFlatPrice = nextCandleTenkan;
            }
            else
            {
                resetAll();
            }
        }
        else
        {
            resetAll();
        }
    }
    else
    {
        if (!tenkanCandleComingToFlat)
        {
            if (nextCandleGreaterThanFlatPrice > 0)
            {
                if (nextCandleTenkan < nextCandleGreaterThanFlatPrice)
                {
                    tenkanCandleComingToFlat = true;
                    tenkanCandleComingToFlatPrice = nextCandleTenkan;
                }
                else
                {
                    resetAll();
                }
            }
            else
            {
                resetAll();
            }
        }
        else
        {
            if (tenkanCandleComingToFlatPrice > 0)
            {
                if (nextCandleTenkan < tenkanCandleComingToFlatPrice)
                {
                    tenkanCandleComingToFlatPrice = nextCandleTenkan;
                    double nextCandleKijun = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 1, i);
                    double previousCandleKijun = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 1, i + 1);
                    double previousCandleKijun2 = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 1, i + 2);
                    double previousCandleTenkan = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 0, i + 1);

                    if (signalMode == Aggressiv)
                    {
                        if (MA[i] > nextCandleTenkan) // cross
                        {
                            triangleFound = true;

                            if (ma_Filter && triangleFound)
                            {
                                if (Close[i] < MATrend[i])
                                {
                                    triangleFound = true;
                                }
                                else
                                {
                                    resetAll();
                                    return;
                                }
                            }
                            if (macd_Filter && triangleFound)
                            {
                                if (MACD_Main[i] < 0)
                                {
                                    triangleFound = true;
                                }
                                else
                                {
                                    resetAll();
                                    return;
                                }
                            }
                        }
                    }
                    else
                    {
                        if (
                            //
                            previousCandleKijun2 == nextCandleKijun
                            //
                            && previousCandleKijun == nextCandleKijun
                            //
                            && previousCandleTenkan > previousCandleKijun
                            //
                            && nextCandleKijun > nextCandleTenkan
                            //
                            && nextCandleKijun == lastFlatPrice
                            //
                        )
                        {
                            triangleFound = true;

                            if (ma_Filter && triangleFound)
                            {
                                if (Close[i] < MATrend[i])
                                {
                                    triangleFound = true;
                                }
                                else
                                {
                                    resetAll();
                                    return;
                                }
                            }
                            if (macd_Filter && triangleFound)
                            {
                                if (MACD_Main[i] < 0)
                                {
                                    triangleFound = true;
                                }
                                else
                                {
                                    resetAll();
                                    return;
                                }
                            }
                        }
                    }
                }
                else
                {
                    resetAll();
                }
            }
            else
            {
                resetAll();
            }
        }
    }
}

void monitorBuyEntry(double nextCandleTenkan, int i)
{
    if (!nextCandleGreaterThanFlat)
    {
        if (lastFlatPrice > 0)
        {

            if (nextCandleTenkan < lastFlatPrice)
            {
                nextCandleGreaterThanFlat = true;
                nextCandleGreaterThanFlatPrice = nextCandleTenkan;
            }
            else
            {
                resetAll();
            }
        }
        else
            resetAll();
    }
    else
    {
        if (!tenkanCandleComingToFlat)
        {
            if (nextCandleGreaterThanFlatPrice > 0)
            {
                if (nextCandleTenkan > nextCandleGreaterThanFlatPrice)
                {
                    tenkanCandleComingToFlat = true;
                    tenkanCandleComingToFlatPrice = nextCandleTenkan;
                }
                else
                {
                    resetAll();
                }
            }
            else
                resetAll();
        }
        else
        {
            if (tenkanCandleComingToFlatPrice > 0)
            {
                if (nextCandleTenkan > tenkanCandleComingToFlatPrice)
                {
                    tenkanCandleComingToFlatPrice = nextCandleTenkan;
                    double nextCandleKijun = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 1, i);
                    double previousCandleKijun = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 1, i + 1);
                    double previousCandleKijun2 = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 1, i + 2);
                    double previousCandleTenkan = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 0, i + 1);

                    if (signalMode == Aggressiv)
                    {
                        if (MA[i] < nextCandleTenkan) // cross
                        {
                            triangleFound = true;
                            if (ma_Filter && triangleFound)
                            {
                                if (Close[i] > MATrend[i])
                                {
                                    triangleFound = true;
                                }
                                else
                                {
                                    resetAll();
                                    return;
                                }
                            }
                            if (macd_Filter && triangleFound)
                            {
                                if (MACD_Main[i] > 0)
                                {
                                    triangleFound = true;
                                }
                                else
                                {
                                    resetAll();
                                    return;
                                }
                            }
                        }
                    }
                    else
                    {
                        if (
                            previousCandleKijun2 == nextCandleKijun && previousCandleKijun == nextCandleKijun && previousCandleTenkan < previousCandleKijun && nextCandleKijun < nextCandleTenkan && nextCandleKijun == lastFlatPrice)
                        {
                            triangleFound = true;

                            if (ma_Filter && triangleFound)
                            {
                                if (Close[i] > MATrend[i])
                                {
                                    triangleFound = true;
                                }
                                else
                                {
                                    resetAll();
                                    return;
                                }
                            }
                            if (macd_Filter && triangleFound)
                            {
                                if (MACD_Main[i] > 0)
                                {
                                    triangleFound = true;
                                }
                                else
                                {
                                    resetAll();
                                    return;
                                }
                            }
                        }
                    }
                }
                else
                    resetAll();
            }
            else
                resetAll();
        }
    }
}

bool NewOldBar(int i)
{
    int Shift = i;

    static datetime LastTime = 0;

    if (iTime(NULL, PERIOD_CURRENT, Shift) != LastTime)
    {
        LastTime = iTime(NULL, PERIOD_CURRENT, Shift) + time_offset;
        return (true);
    }
    else
        return (false);
}

void resetAll()
{
    lastFlatPrice = 0;
    lastFlatIndex = 0;
    flatTenkanFound = false;
    nextCandleGreaterThanFlat = false;
    nextCandleGreaterThanFlatPrice = 0;
    tenkanCandleComingToFlat = false;
    tenkanCandleComingToFlatPrice = 0;
    triangleFound = false;
}