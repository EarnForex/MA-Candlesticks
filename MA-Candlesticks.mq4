//+------------------------------------------------------------------+
//|                                              MA-Candlesticks.mq5 |
//|                             Copyright © 2010-2022, EarnForex.com |
//| https://www.earnforex.com/metatrader-indicators/MA-Candlesticks/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010-2022, EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-indicators/MA-Candlesticks/"
#property version   "1.01"
#property strict

#property description "Displays the moving average in form of the candlesticks."
#property description "This way, the moving average is shown for Close, Open, High and Low."
#property description "Works with any trading instrument, timeframe, period, and MA type."

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrYellow
#property indicator_color2 clrBlue
#property indicator_color3 clrYellow
#property indicator_color4 clrBlue
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3

input int            MAPeriod = 10; // MA Period
input ENUM_MA_METHOD MAType   = MODE_SMA; // MA Type

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

int ExtCountedBars = 0;

void OnInit()
{
    SetIndexStyle(0, DRAW_HISTOGRAM);
    SetIndexBuffer(0, ExtMapBuffer1);
    SetIndexStyle(1, DRAW_HISTOGRAM);
    SetIndexBuffer(1, ExtMapBuffer2);
    SetIndexStyle(2, DRAW_HISTOGRAM);
    SetIndexBuffer(2, ExtMapBuffer3);
    SetIndexStyle(3, DRAW_HISTOGRAM);
    SetIndexBuffer(3, ExtMapBuffer4);

    SetIndexDrawBegin(0, MAPeriod);
    SetIndexDrawBegin(1, MAPeriod);
    SetIndexDrawBegin(2, MAPeriod);
    SetIndexDrawBegin(3, MAPeriod);

    IndicatorSetString(INDICATOR_SHORTNAME, "MA-Candlesticks(" + IntegerToString(MAPeriod) + ")");
}

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
    double MAOpen, MAHigh, MALow, MAClose;

    if (Bars <= MAPeriod) return 0;
    ExtCountedBars = IndicatorCounted();
    if (ExtCountedBars > 0) ExtCountedBars--;

    int pos = Bars - ExtCountedBars - 1;

    while (pos >= 0)
    {
        MAClose = iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_CLOSE, pos);
        MAOpen =  iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_OPEN,  pos);
        MAHigh =  iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_HIGH,  pos);
        MALow =   iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_LOW,   pos);

        if (MAClose > MAOpen)
        {
            ExtMapBuffer1[pos] = MALow;
            ExtMapBuffer2[pos] = MAHigh;
        }
        else
        {
            ExtMapBuffer1[pos] = MAHigh;
            ExtMapBuffer2[pos] = MALow;
        }
        
        ExtMapBuffer3[pos] = MAOpen;
        ExtMapBuffer4[pos] = MAClose;

        pos--;
    }

    return rates_total;
}
//+------------------------------------------------------------------+