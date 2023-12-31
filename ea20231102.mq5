//+------------------------------------------------------------------+
//|                                                        cctux.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>//导入交易类
#include <Trade\PositionInfo.mqh>
CTrade trade;
CPositionInfo positioninfo;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   按钮("按钮1",0,0,50,100,50,CORNER_LEFT_LOWER,"一键做多",true,true);
   编辑框("编辑1",0,100,50,100,50,CORNER_LEFT_LOWER,"0.1");
   int q1 = iMA(Symbol(),0,10,0,0,0);
   ChartIndicatorAdd(0,0,q1);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
     if(id == CHARTEVENT_OBJECT_CLICK && sparam == "按钮1"){
         double ss = StringToDouble(ObjectGetString(0,"编辑1",OBJPROP_TEXT)); 
         trade.Buy(ss,NULL,SymbolInfoDouble(NULL,SYMBOL_ASK),0,0,Symbol()+"buy");
     }
  }
//+------------------------------------------------------------------+
void 按钮(string 按钮名称,int 按钮窗口,int 按钮X轴,int 按钮Y轴,int 按钮宽度,int 按钮高度,ENUM_BASE_CORNER 角落,string 内容,
bool 状态,bool 可选){
   if(ObjectFind(0,按钮名称)<0){
      bool 按钮 = ObjectCreate(0,按钮名称,OBJ_BUTTON,按钮窗口,0,0);
      if(按钮 == false){
         Print("按钮创建失败",IntegerToString(GetLastError()));
      }
   }
   
    ObjectSetInteger(0,按钮名称,OBJPROP_XDISTANCE,按钮X轴);
    ObjectSetInteger(0,按钮名称,OBJPROP_YDISTANCE,按钮Y轴);  

    ObjectSetInteger(0,按钮名称,OBJPROP_XSIZE,按钮宽度);
    ObjectSetInteger(0,按钮名称,OBJPROP_YSIZE,按钮高度);
   
    ObjectSetInteger(0,按钮名称,OBJPROP_CORNER,角落);
   
    ObjectSetString(0,按钮名称,OBJPROP_TEXT,内容);  
    
    ObjectSetInteger(0,按钮名称,OBJPROP_STATE,状态);
    
    ObjectSetInteger(0,按钮名称,OBJPROP_SELECTABLE,可选);
}

void 编辑框(string 编辑框名称,int 编辑框窗口,int 编辑框X轴,int 编辑框Y轴,int 编辑框宽度,int 编辑框高度,ENUM_BASE_CORNER 角落,string 内容){
   if(ObjectFind(0,编辑框名称)<0){
      bool 编辑框 = ObjectCreate(0,编辑框名称,OBJ_EDIT,编辑框窗口,0,0);
      if(编辑框 == false){
         Print("按钮创建失败",IntegerToString(GetLastError()));
      }
   }
    ObjectSetInteger(0,编辑框名称,OBJPROP_XDISTANCE,编辑框X轴);
    ObjectSetInteger(0,编辑框名称,OBJPROP_YDISTANCE,编辑框Y轴);  

    ObjectSetInteger(0,编辑框名称,OBJPROP_XSIZE,编辑框宽度);
    ObjectSetInteger(0,编辑框名称,OBJPROP_YSIZE,编辑框高度);
   
    ObjectSetInteger(0,编辑框名称,OBJPROP_CORNER,角落);
   
    ObjectSetString(0,编辑框名称,OBJPROP_TEXT,内容);       
}

void 箭头(string 箭头名称,int 箭头窗口,datetime 箭头时间,double 箭头价格,char 箭头风格){
   if(ObjectFind(0,箭头名称)<0){
      bool 箭头 = ObjectCreate(0,箭头名称,OBJ_ARROW,箭头窗口,箭头时间,箭头价格);
      if(箭头 == false){
         Print("箭头创建失败",IntegerToString(GetLastError()));
      }
   }
   if(ObjectGetInteger(0,箭头名称,OBJPROP_TIME)!=箭头时间){
      ObjectSetInteger(0,箭头名称,OBJPROP_TIME,箭头时间);
   }
   if(ObjectGetDouble(0,箭头名称,OBJPROP_PRICE)!=箭头价格){
      ObjectSetDouble(0,箭头名称,OBJPROP_PRICE,箭头价格);
   }
   if(ObjectGetInteger(0,箭头名称,OBJPROP_ARROWCODE)!=箭头风格){
      ObjectSetInteger(0,箭头名称,OBJPROP_ARROWCODE,箭头风格);
   }
   
}