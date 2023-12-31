//+------------------------------------------------------------------+
//|                                                         经济日历.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Arrays\ArrayDouble.mqh>

int OnInit()
  {

   return(INIT_SUCCEEDED);
  }

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
   MqlCalendarValue values[];
   string code="EUR";
   datetime time1 = iTime(Symbol(),0,0);
   datetime time2 = time1 + PeriodSeconds(PERIOD_M5);
   CalendarValueHistory(values,time1,time2,NULL,code);
   for(int a = 0; a< ArraySize(values); a++){
      double xgx = his1((string)values[a].event_id);
      /*
      
      平单看取的什么时候的开盘，如果取的5分钟后的开盘就在5分钟后平，无论是亏还是赚
      开单 是先获取当前最新的实际值，这里要加一个时间判断，如果获取的事件实际值时间过长，则放弃开单 
         只要获取到了实际值，则可进行判断后开单
      if(xgx>?){
      
         
         buy()
      }
      if(xgx<?){
         sell()
      }
      
      */
   }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {

   
  }
  
double his1(string eventid){
    MqlCalendarValue values[];
   string code="EUR"; 
   datetime time1 = iTime(Symbol(),0,0);
   datetime endtime = time1;
   datetime starttime = endtime - (PeriodSeconds(PERIOD_MN1)*12);
   //Print("starttime:",starttime);
   double actual1[60];
   double hisopen1[60];
   int q=0;
   CalendarValueHistory(values,starttime,endtime,NULL,code);
   for(int a = 0; a< ArraySize(values); a++) {
      if((string)values[a].event_id == eventid){
         MqlCalendarEvent event;
         CalendarEventById(values[a].event_id,event);
         MqlCalendarCountry country;
         CalendarCountryById(event.country_id,country);
         
         double actual=values[a].actual_value==LONG_MIN?values[a].prev_value/1000000.:values[a].actual_value/1000000.;
         actual1[q] = actual;
         
         datetime histime1 = values[a].time;
         datetime histime2 = histime1 + PeriodSeconds(PERIOD_M5);
 
         MqlRates rates1[1]; 
         ArraySetAsSeries(rates1,true);
         CopyRates(Symbol(),0,histime1,1,rates1);
         
         MqlRates rates2[1]; 
         ArraySetAsSeries(rates2,true);
         CopyRates(Symbol(),0,histime2,1,rates2);
         
         double ratio1 = rates2[0].open/rates1[0].open;

         hisopen1[q] = ratio1;
         
         q++; 
      }

   }
   int w = 0;
   double actual2[60];
   for(int a = 0; a< ArraySize(actual1); a++){
      if(a>0){
         double ww = actual1[a]/actual1[a-1];
         if(ww > 0){
            actual2[w] =ww;
            w++;
         }else{
            break;
         }
         
      }
   }
   double hisopen2[60];
   for(int a = 0; a< w; a++){
      if(a>0){
        hisopen2[a-1] = hisopen1[a];
      }      
   }
  double correlation = CalculateCorrelation(actual2, hisopen2);
  //ArrayPrint(actual2);
 Print("Correlation: ", correlation);
 return correlation;     
}


double CalculateCorrelation(const double& data1[], const double& data2[])
{
    const int dataSize = ArraySize(data1);
    if (dataSize != ArraySize(data2))
    {
        Print("Error: Data size mismatch");
        return 0.0;
    }
    
    double sum1 = 0.0;
    double sum2 = 0.0;
    double sum1Sq = 0.0;
    double sum2Sq = 0.0;
    double productSum = 0.0;
    
    for (int i = 0; i < dataSize; i++)
    {
        sum1 += data1[i];
        sum2 += data2[i];
        sum1Sq += data1[i] * data1[i];
        sum2Sq += data2[i] * data2[i];
        productSum += data1[i] * data2[i];
    }
    
    double numerator = dataSize * productSum - sum1 * sum2;
    double denominator = sqrt((dataSize * sum1Sq - sum1 * sum1) * (dataSize * sum2Sq - sum2 * sum2));
    
    if (denominator == 0.0)
    {
        Print("Error: Denominator is zero");
        return 0.0;
    }
    
    return numerator / denominator;
}

void cc(){
    MqlCalendarValue values[];
   string code="USD"; 
   datetime starttime = iTime(Symbol(),0,0);
   datetime endtime = starttime + PeriodSeconds(PERIOD_H1);
   Print("starttime:",starttime);
   CalendarValueHistory(values,starttime,endtime,NULL);
   for(int a = 0; a< ArraySize(values); a++) {
      MqlCalendarEvent event;
      CalendarEventById(values[a].event_id,event);
      MqlCalendarCountry country;
      CalendarCountryById(event.country_id,country);      
      Print("event.name:",event.name);
      Print("country:",country.name);
      Print("time:",values[a].time);
      Print("actual_value:",values[a].actual_value==LONG_MIN?double("nan"):values[a].actual_value/1000000.);
   }    
}