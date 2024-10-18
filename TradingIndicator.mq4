//+------------------------------------------------------------------+
//|                                            TradingIndicator.mq4  |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//|                                                author: Nyarducks |
//|    repository: https://github.com/Nyarducks/TradingIndicator.git |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window

#include <ChartObjects\ChartObjectsTxtControls.mqh>

// GLOBAL VARIABLES (STORE)
#define GLOBAL_VAR_DAY_MAX_DRAW_DOWN "DAY_MAX_DRAW_DOWN"
#define GLOBAL_VAR_DAY_MAX_LATENT_LOSS "DAY_MAX_LATENT_LOSS"

// CONSTANTS
const string VERSION = "v1.0-en";
const string LABEL_MAX_DD = "Max DD (Day):";
const string LABEL_MAX_LOSS = "Max Loss (Day):";
const string LABEL_CURRENT_PROFIT = "Current Profit(DD):";
const string LABEL_PRICE_BUY_POSITION = "Current buy position price:";
const string LABEL_PRICE_SELL_POSITION = "Current sell position price:";

//+------------------------------------------------------------------+
//| CanvasSettingEntity                                              |
//+------------------------------------------------------------------+
struct CanvasSetting {
    long chartId;       // chartId
    string name;        // canvas name prefix
    int window;         // sub window numbers, usually zero.
    int paddingLeft;    // styles canvas left-padding
    int paddingTop;     // styles canvas padding-top
    int width;          // styles canvas width
    int height;         // styles canvas height
};

//+------------------------------------------------------------------+
//| DayMaxDrawDownDataEntity                                         |
//+------------------------------------------------------------------+
struct DayMaxDrawDownData {
    double profit;      // profit
    double percent;     // percent
    color fontColor;    // fontColor
};

//+------------------------------------------------------------------+
//| DayMaxLatentLossDataEntity                                       |
//+------------------------------------------------------------------+
struct DayMaxLatentLossData {
    double profit;      // profit
    color fontColor;    // fontColor
};

//+------------------------------------------------------------------+
//| CurrentProfitDataEntity                                          |
//+------------------------------------------------------------------+
struct CurrentProfitData {
    double profit;      // profit
    double percent;     // percent
    color fontColor;    // fontColor
};

//+------------------------------------------------------------------+
//| BreakevenPriceEntity                                             |
//+------------------------------------------------------------------+
struct BreakEvenPrice {
    double price;       // price
    int positions;      // positions
};

//+------------------------------------------------------------------+
//| BreakevenPriceDataEntity                                         |
//+------------------------------------------------------------------+
struct BreakevenPriceData {
    BreakEvenPrice buy;     // buy
    BreakEvenPrice sell;    // sell
};

//+------------------------------------------------------------------+
//| TradingDataEntity                                                |
//+------------------------------------------------------------------+
struct TradingData {
    DayMaxDrawDownData dayMaxDrawDownData;      // Maximum drawdown data per day
    DayMaxLatentLossData dayMaxLatentLossData;  // Maximum latent loss data per day
    CurrentProfitData currentProfitData;        // Current profit data
    BreakevenPriceData breakevenPriceData;      // Breakeven price data
};

//+------------------------------------------------------------------+
//| Class Paper                                                      |
//+------------------------------------------------------------------+
class Paper : public CChartObjectRectLabel {
    CChartObjectLabel m_title1, m_value1;
    CChartObjectLabel m_title2, m_value2;
    CChartObjectLabel m_title3, m_value3;
    CChartObjectLabel m_title4, m_value4;
    CChartObjectLabel m_title5, m_value5;
    // Create paper instance with title and value labels
    public: bool Create(CanvasSetting &p) {
        if(!CChartObjectRectLabel::Create(p.chartId, p.name, p.window, p.paddingLeft, p.paddingTop, p.width, p.height)) {
            return false;
        } else {
            // Create title label
            m_title1.Create(p.chartId, p.name + "_title1", p.window, p.paddingLeft + 8, p.paddingTop + 12);
            m_title2.Create(p.chartId, p.name + "_title2", p.window, p.paddingLeft + 8, p.paddingTop + 40);
            m_title3.Create(p.chartId, p.name + "_title3", p.window, p.paddingLeft + 8, p.paddingTop + 68);
            m_title4.Create(p.chartId, p.name + "_title4", p.window, p.paddingLeft + 8, p.paddingTop + 96);
            m_title5.Create(p.chartId, p.name + "_title5", p.window, p.paddingLeft + 8, p.paddingTop + 124);

            // Create value label
            m_value1.Create(p.chartId, p.name + "_value1", p.window, p.paddingLeft + 150, p.paddingTop + 12);
            m_value2.Create(p.chartId, p.name + "_value2", p.window, p.paddingLeft + 150, p.paddingTop + 40);
            m_value3.Create(p.chartId, p.name + "_value3", p.window, p.paddingLeft + 150, p.paddingTop + 68);
            m_value4.Create(p.chartId, p.name + "_value4", p.window, p.paddingLeft + 150 + 50, p.paddingTop + 96);
            m_value5.Create(p.chartId, p.name + "_value5", p.window, p.paddingLeft + 150 + 50, p.paddingTop + 124);

            // Set title colors (Black)
            m_title1.Color(clrBlack);
            m_title2.Color(clrBlack);
            m_title3.Color(clrBlack);
            m_title4.Color(clrBlack);
            m_title5.Color(clrBlack);
            return true;
        }
    }
    // set labels
    bool SetLabels(const string text1, const string text2, const string text3, const string text4, const string text5) {
        return m_title1.Description(text1) && m_title2.Description(text2) && m_title3.Description(text3) && m_title4.Description(text4) && m_title5.Description(text5);
    }
    // set values
    bool SetValues(const string value1, const string value2, const string value3, const string value4, const string value5) {
        return m_value1.Description(value1) && m_value2.Description(value2) && m_value3.Description(value3) && m_value4.Description(value4) && m_value5.Description(value5);
    }
    // set value colors
    bool SetValueColors(const color clr1, const color clr2, const color clr3, const color clr4, const color clr5) {
        return m_value1.Color(clr1) && m_value2.Color(clr2) && m_value3.Color(clr3) && m_value4.Color(clr4) && m_value5.Color(clr5);
    }
    // destroy (Initialisation)
    void Destroy(CanvasSetting &p) {
        int totalObjects = ObjectsTotal();
        for (int i = totalObjects - 1; i >= 0; i--) {
            string object = ObjectName(i);
            if (StringFind(object, p.name) == 0) ObjectDelete(p.chartId, object);
        }
    }
};

//+------------------------------------------------------------------+
//| Class TradingDataCalculation                                     |
//+------------------------------------------------------------------+
class TradingDataCalculation {
    // RestoreTradingData
    public: void RestoreTradingData(TradingData &p) {
        if(GlobalVariableCheck(GLOBAL_VAR_DAY_MAX_DRAW_DOWN)) {
            p.dayMaxDrawDownData.profit = GlobalVariableGet(GLOBAL_VAR_DAY_MAX_DRAW_DOWN);
        }
        if(GlobalVariableCheck(GLOBAL_VAR_DAY_MAX_LATENT_LOSS)) {
            p.dayMaxLatentLossData.profit = GlobalVariableGet(GLOBAL_VAR_DAY_MAX_LATENT_LOSS);
        }
    }
    // UpdateDayMaxDrawdownData
    public: void UpdateDayMaxDrawdownData(TradingData &p) {
        const DayMaxDrawDownData _i = p.dayMaxDrawDownData;
        double balancePeak = AccountBalance();
        double currentDrawdown = 0;
        double floatingLoss = 0;

        // Calculate opened drawdown
        for (int i = 0; i < OrdersTotal(); i++) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
                datetime orderOpenTime = OrderOpenTime();
                if (orderOpenTime >= iTime(NULL, PERIOD_D1, 0)) {
                    double orderProfit = OrderProfit();
                    if (orderProfit < 0) {
                        floatingLoss += orderProfit;
                    }
                }
            }
        }

        currentDrawdown = balancePeak - (balancePeak + floatingLoss);  // calculate peak balance takeaway by losses
        p.dayMaxDrawDownData.profit = MathMax(_i.profit, currentDrawdown);  // update one
        p.dayMaxDrawDownData.percent = (p.dayMaxDrawDownData.profit / balancePeak) * 100.0;  // calculate drawdown percentages

        // Set color per drawdown levels.
        if(p.dayMaxDrawDownData.percent < 50) {
            p.dayMaxDrawDownData.fontColor = clrGreen;  // 0% ~ 49% -> Green
        } else if(p.dayMaxDrawDownData.percent < 80) {
            p.dayMaxDrawDownData.fontColor = clrYellow;  // 50% ~ 79% -> Yellow
        } else {
            p.dayMaxDrawDownData.fontColor = clrRed;  // more than 80% -> Red
        }
    }
    // UpdateDayMaxLatentLossData
    public: void UpdateDayMaxLatentLossData(TradingData &p) {
        const DayMaxLatentLossData _i = p.dayMaxLatentLossData;
        double maxLatentLoss = 0;

        for(int i = 0; i < OrdersTotal(); i++) {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
                double latentLoss = OrderProfit();
                if(latentLoss < 0) {
                    maxLatentLoss += latentLoss;
                }
            }
        }

        p.dayMaxLatentLossData.profit = MathMin(_i.profit, maxLatentLoss);
        // Set color (zero is black, loss is red)
        p.dayMaxLatentLossData.fontColor = (int) p.dayMaxLatentLossData.profit == 0 ? clrBlack : clrRed;
    }
    // UpdateCurrentProfitData
    public: void UpdateCurrentProfitData(TradingData &p) {
        // Create instance of it
        CurrentProfitData data = {0,0, clrBlack};

        // Calculate current profit and loss
        for (int i = 0; i < OrdersTotal(); i++) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
                if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                    data.profit += OrderProfit();  // Add both positions profit and loss
                }
            }
        }
        // Calculation current drawdown
        const double accountBalance = AccountBalance();
        if (accountBalance > 0) {
            data.percent = (data.profit / accountBalance) * 100;
        } else {
            data.percent = 0;
        }
        // Set color (zero is black, profit is blue, loss is red)
        data.fontColor = (int) p.currentProfitData.profit == 0 ? clrBlack : (int) p.currentProfitData.profit >= 0 ? clrBlue : clrRed;
        // update one
        p.currentProfitData = data;
    }
    // UpdateBreakevenPriceData
    public: void UpdateBreakevenPriceData(TradingData &p) {
        double buyTotalLots = 0;
        double buyTotalPrice = 0;
        double sellTotalLots = 0;
        double sellTotalPrice = 0;

        int buyPositionCount = 0;
        int sellPositionCount = 0;

        // Calculate each breakeven prices
        for(int i = 0; i < OrdersTotal(); i++) {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
                if(OrderType() == OP_BUY) {
                    buyTotalLots += OrderLots();
                    buyTotalPrice += OrderOpenPrice() * OrderLots();
                    buyPositionCount++;
                } else if(OrderType() == OP_SELL) {
                    sellTotalLots += OrderLots();
                    sellTotalPrice += OrderOpenPrice() * OrderLots();
                    sellPositionCount++;
                }
            }
        }
        // update one
        if(buyTotalLots > 0) {
            p.breakevenPriceData.buy.price = buyTotalPrice / buyTotalLots;
            p.breakevenPriceData.buy.positions = buyPositionCount;
        } else {
            p.breakevenPriceData.buy.price = 0;
            p.breakevenPriceData.buy.positions = 0;
        }
        if(sellTotalLots > 0) {
            p.breakevenPriceData.sell.price = sellTotalPrice / sellTotalLots;
            p.breakevenPriceData.sell.positions = sellPositionCount;
        } else {
            p.breakevenPriceData.sell.price = 0;
            p.breakevenPriceData.sell.positions = 0;
        }
    }
};

//+------------------------------------------------------------------+
//| InstanceCreate: Data Structures                                  |
//+------------------------------------------------------------------+
// Create canvas setting instance with default constructor
CanvasSetting canvasSetting = {-1, "canvas", 0, 5, 80, 350, 170};
TradingData tradingData;        // Create trading data instance
Paper canvas;                   // Create memo instance
TradingDataCalculation c;       // Create TradingDataCalculation instance

//+------------------------------------------------------------------+
//| Event: OnInit                                                    |
//+------------------------------------------------------------------+
int OnInit() {
    canvasSetting.chartId = ChartID(); // overwrite current chartId
    canvas.Destroy(canvasSetting); // initialise trading indicator
    c.RestoreTradingData(tradingData); // restore maximum latent loss from global variables if exists
    // setup canvas
    if(!canvas.Create(canvasSetting)
        || !canvas.BackColor(clrAqua)
        || !canvas.SetLabels(LABEL_MAX_DD, LABEL_MAX_LOSS, LABEL_CURRENT_PROFIT, LABEL_PRICE_BUY_POSITION, LABEL_PRICE_SELL_POSITION)
        || !canvas.SetValues("--", "--", "--", "--", "--")
        || !canvas.FontSize(14)
    ) { Alert("INIT_FAILED"); return INIT_FAILED; }
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Event: OnCalculate                                               |
//+------------------------------------------------------------------+
int OnCalculate(
    const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[],
    const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]
) {
    // Update every
    c.UpdateDayMaxDrawdownData(tradingData);
    c.UpdateDayMaxLatentLossData(tradingData);
    c.UpdateCurrentProfitData(tradingData);
    c.UpdateBreakevenPriceData(tradingData);
    // Get calculated data
    const DayMaxDrawDownData dayMaxDrawDownData = tradingData.dayMaxDrawDownData;
    const DayMaxLatentLossData dayMaxLatentLossData = tradingData.dayMaxLatentLossData;
    const CurrentProfitData currentProfitData = tradingData.currentProfitData;
    const BreakevenPriceData breakevenPriceData = tradingData.breakevenPriceData;

    // Set fields
    canvas.SetValues(
        StringFormat("%.0f (%.2f%%)", dayMaxDrawDownData.profit, dayMaxDrawDownData.percent),
        StringFormat("%.0f", dayMaxLatentLossData.profit),
        StringFormat("%.0f (%.2f%%)", tradingData.currentProfitData.profit, tradingData.currentProfitData.percent),
        StringFormat("%.2f [%d]", breakevenPriceData.buy.price, breakevenPriceData.buy.positions),
        StringFormat("%.2f [%d]", breakevenPriceData.sell.price, breakevenPriceData.sell.positions)
    );

    // Set font colors
    canvas.SetValueColors(
        dayMaxDrawDownData.fontColor,
        dayMaxLatentLossData.fontColor,
        currentProfitData.fontColor,
        clrBlack, // buy breakeven price color
        clrBlack  // sell breakeven price color
    );

    return rates_total;
}

//+------------------------------------------------------------------+
//| Event: OnDeinit                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    // store data
    GlobalVariableSet(GLOBAL_VAR_DAY_MAX_DRAW_DOWN, tradingData.dayMaxDrawDownData.profit);
    GlobalVariableSet(GLOBAL_VAR_DAY_MAX_LATENT_LOSS, tradingData.dayMaxLatentLossData.profit);
    // delete trading indicator
    canvas.Destroy(canvasSetting);
}
