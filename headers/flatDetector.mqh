

int numberOfBackCandlesToSearch = 3;
int numberOfCandlesForFlat = 2;

bool DetectFlatTenkan(double &price, int j)
{
    if (j + numberOfBackCandlesToSearch >= lastFlatIndex && lastFlatIndex != 0) // if the to study candles include the last flat index return 
    {
        Print("return on first if");
        return false;
    }

    double trailPrice = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 0, j);

    int i = j;
    int total = 0;
    for (i; i < j + numberOfBackCandlesToSearch; i++)
    {
        double temp = iIchimokuMQL4(NULL, PERIOD_CURRENT, 9, 26, 52, 0, i);
        if (temp == trailPrice)
        {
            total++;
        }
        else
        {
            trailPrice = temp;
        }
        if (total >= 2)
        {
            break;
        }
    }

    if (total >= numberOfCandlesForFlat)
    {
        price = trailPrice;

        // drawSegmentHLine(indicatorName + i, price, i, i + numberOfCandlesForFlat);

        lastFlatIndex = j;

        lastFlatPrice = price;

        flatTenkanFound = true;

        return true;
    }
    return false;
}