//+------------------------------------------------------------------+
//|                                              MA-Candlesticks.mq5 |
//|                             Copyright © 2010-2022, EarnForex.com |
//| https://www.earnforex.com/metatrader-indicators/MA-Candlesticks/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010-2022, EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-indicators/MA-Candlesticks/"
#property version   "1.01"

#property description "Displays the moving average in form of the candlesticks."
#property description "This way, the moving average is shown for Close, Open, High and Low."
#property description "Works with any trading instrument, timeframe, period, and MA type."

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrBlue, clrYellow
#property indicator_label1  "MA Open;MA High;MA Low;MA Close"

// Indicator buffers
double ExtOBuffer[];
double ExtHBuffer[];
double ExtLBuffer[];
double ExtCBuffer[];
double ExtColorBuffer[];

// MA buffers
double MACloseBuf[];
double MAOpenBuf[];
double MAHighBuf[];
double MALowBuf[];

input int            MAPeriod = 10; // MA Period
input ENUM_MA_METHOD MAType   = MODE_SMA; // MA Type

void OnInit()
{
    SetIndexBuffer(0, ExtOBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, ExtHBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, ExtLBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, ExtCBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, ExtColorBuffer, INDICATOR_COLOR_INDEX);

    IndicatorSetString(INDICATOR_SHORTNAME, "MA-Candlesticks(" + IntegerToString(MAPeriod) + ")");

    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, MAPeriod);
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
    int myMA;

    myMA = iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_CLOSE);
    if  (CopyBuffer(myMA, 0, 0, rates_total, MACloseBuf) != rates_total) return 0;

    myMA = iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_OPEN);
    if  (CopyBuffer(myMA, 0, 0, rates_total, MAOpenBuf) != rates_total) return 0;

    myMA = iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_HIGH);
    if  (CopyBuffer(myMA, 0, 0, rates_total, MAHighBuf) != rates_total) return 0;

    myMA = iMA(NULL, 0, MAPeriod, 0, MAType, PRICE_LOW);
    if  (CopyBuffer(myMA, 0, 0, rates_total, MALowBuf) != rates_total) return 0;

    // Preliminary calculations.
    int limit;
    if (prev_calculated <= 1)
    {
        // Set the first candle.
        ExtLBuffer[0] = MALowBuf[0];
        ExtHBuffer[0] = MAHighBuf[0];
        ExtOBuffer[0] = MAOpenBuf[0];
        ExtCBuffer[0] = MACloseBuf[0];
        limit = 1;
    }
    else limit = prev_calculated - 1;

    // The main loop of calculations.
    for (int i = limit; i < rates_total; i++)
    {
        ExtOBuffer[i] = MAOpenBuf[i];
        ExtCBuffer[i] = MACloseBuf[i];

        if (MAOpenBuf[i] < MACloseBuf[i])
        {
            ExtLBuffer[i] = MALowBuf[i];
            ExtHBuffer[i] = MAHighBuf[i];
            ExtColorBuffer[i] = 0.0;
        }
        else
        {
            ExtLBuffer[i] = MAHighBuf[i];
            ExtHBuffer[i] = MALowBuf[i];
            ExtColorBuffer[i] = 1.0;
        }
    }

    return rates_total;
}
//+------------------------------------------------------------------+