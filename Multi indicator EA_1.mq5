//+------------------------------------------------------------------+
//|                                                        cc107.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>//导入交易类
#include <Trade\PositionInfo.mqh>
CTrade trade;
CPositionInfo positioninfo;
//可调节参数
input int diff_aver1 = 8;
input int diff_aver2 = 13;

input int dea_aver1 = 5;

input int rsv1_period = 8;
input int k_m = 1;
input int k_n = 3;
input int d_m = 1;
input int d_n = 3;

input int refa = 1;
input int rsi1_m = 1;
input int rsi1_n = 5;
input int rsi2_m = 1;
input int rsi2_n = 13;

input int rsi_period = 13;
input int lwr1_n = 3;
input int lwr1_m = 1;
input int lwr2_n = 3;
input int lwr2_m = 1;

input int ma1 = 3;
input int ma2 = 6;
input int ma3 = 12;
input int ma4 = 24;

input int mtm_ref = 1;
input int mms1 = 5;
input int mms2 = 3;
input int mmm1 = 13;
input int mmm2 = 8;

input int buy = 6;
input int sell = 6;
input int close_buy = 3;
input int close_sell = 3;
// 初始化函数
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)//是初始化失败事件处理程序
  {

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()//处理一个新报价
  {
//---
   MqlRates rates[]; //结构存储有关价位、交易量和传递的信息
   ArraySetAsSeries(rates,true); // 將數組rates設置為倒序排列
   CopyRates(Symbol(),0,0,30,rates);//获取 MqlRates 结构的历史序列，按指定品种-周期，按指定数量，并存储到矩阵或向量当中
   
   static double diff_ema1 =rates[1].close;//静态变量
   static double diff_ema2 =rates[1].close;  
  
   double diff1 = Emas(rates[0].close,diff_aver1,diff_ema1);// 計算diff1，使用rates數組中下標為0的K線的收盤價和diff_aver1、diff_ema1作為參數
   double diff2 = Emas(rates[0].close,diff_aver2,diff_ema2);
   double diff = diff1 - diff2;
   
   diff_ema1 = diff1;// 更新diff_ema1的值為diff1
   diff_ema2 = diff2;// 更新diff_ema2的值為diff2
   
   static double dea_ema1 =diff;
   double dea = Emas(diff,dea_aver1,dea_ema1);// 計算dea，使用diff、dea_aver1和dea_ema1作為參數
   dea_ema1 = dea;// 更新dea_ema1的值為dea
   
   bool A1 = diff > dea;// 比較diff和dea的值，將結果賦給布爾變量A1
   
   double low8 = maxmin(rsv1_period,rates,2,"low");// 計算最近rsv1_period個K線中的最低價格，將結果賦給變量low8
   double high8 = maxmin(rsv1_period,rates,1,"high");// 計算最近rsv1_period個K線中的最高價格，將結果賦給變量high8
   double rsv1 = (rates[0].close - low8)/(high8-low8)*100;// 計算RSV1，根據當前K線的收盤價、low8和high8計算
   
   static double k_sma1 =rsv1;
   double k = Smas(rsv1,k_n,k_m,k_sma1);
   k_sma1 = k;// 更新k_sma1的值為k
   static double d_sma1 =k;
   double d = Smas(k,d_n,d_m,d_sma1);
   d_sma1 = d;
   
   bool A2 = k > d;// 比較K值和D值，將結果賦給布爾變量A2
   
    
   double lc = rates[refa].close;// 將rates數組中索引為refa的K線的收盤價賦值給變量lc
   double aa1 = rates[0].close - lc;
   double aa2 = MathAbs(aa1);// 計算aa2，取aa1的絕對值
   double ss1 = max(lc,rates[0].close,0);// 計算ss1，取lc和當前K線的收盤價中的最大值，並與0比較取較大值
   
   static double rsi1_sma1 =ss1;
   double dd1 = Smas(ss1,rsi1_n,rsi1_m,rsi1_sma1);
   rsi1_sma1 = dd1;
   
   static double rsi1_sma2 =aa2;
   double dd2 = Smas(aa2,rsi1_n,rsi1_m,rsi1_sma2);
   rsi1_sma1 = dd2;
   
   double rsi1 = dd1/dd2*100;
   
   static double rsi2_sma1 =ss1;
   double ff1 = Smas(ss1,rsi2_n,rsi2_m,rsi2_sma1);
   rsi2_sma1 = ff1;
   
   static double rsi2_sma2 =aa2;
   double ff2 = Smas(aa2,rsi2_n,rsi2_m,rsi2_sma2);// 計算FF2值，使用aa2、rsi2_n、rsi2_m和rsi2_sma2作為參數
   rsi2_sma2 = ff2;
   
   double rsi2 = ff1/ff2*100;
   
   bool A3 = rsi1 > rsi2;// 比較rsi1值和rsi2值，將結果賦給布爾變量A2
   
   
   double high13 = maxmin(rsi_period,rates,1,"high");// 計算最近rsi_period個K線中的最高價格，並將結果賦值給high13
   double low13 = maxmin(rsi_period,rates,2,"low");
   double gg1 = -(high13 - rates[0].close);// 計算gg1，使用high13減去當前K線的收盤價，並取其負值
   double rsv = gg1/(high13-low13)*100;
   
   static double lwr1_sma1 =rsv;
   double lwr1 = Smas(rsv,lwr1_n,lwr1_m,lwr1_sma1);
   lwr1_sma1 =lwr1;
   
   static double lwr2_sma1 =lwr1;
   double lwr2 = Smas(lwr1,lwr2_n,lwr2_m,lwr2_sma1);
   lwr2_sma1 =lwr2;
   
   bool A4 = lwr1 > lwr2;
   
   double bbi = (ma(ma1,rates)+ma(ma2,rates)+ma(ma3,rates)+ma(ma4,rates))/4;// 計算bbi，使用ma1、ma2、ma3、ma4和rates作為參數，將結果賦給bbi
   
   bool A5 = rates[0].close > bbi;
   
   double mtm = rates[0].close - rates[mtm_ref].close;
   double mtm2 = MathAbs(mtm);
   
   static double mms_ema1 =mtm;// 設定mms_ema1為mtm的值
   double mms_1 = Emas(mtm,mms1,mms_ema1);// 計算mms_1，使用mtm、mms1和mms_ema1作為參數
   mms_ema1 = mms_1;// 更新mms_ema1的值為mms_1
   
   static double mms_ema2 =mms_1;// 設定mms_ema2為mms_1的值
   double mms_2 = Emas(mms_1,mms2,mms_ema2);// 計算mms_2，使用mms_1、mms2和mms_ema2作為參數
   mms_ema2 = mms_2;// 更新mms_ema2的值為mms_2
   
   static double mms2_ema1 =mtm2;// 設定mms2_ema1為mtm2的值
   double mms2_1 = Emas(mtm2,mms1,mms2_ema1);// 計算mms2_1，使用mtm2、mms1和mms2_ema1作為參數
   mms2_ema1 = mms2_1;// 更新mms2_ema1的值為mms2_1
   
   static double mms2_ema2 =mms2_1;// 設定mms2_ema2為mms2_1的值
   double mms2_2 = Emas(mms2_1,mms2,mms2_ema2);// 計算mms2_2，使用mms2_1、mms2和mms2_ema2作為參數
   mms2_ema2 = mms2_2;// 更新mms2_ema2的值為mms2_2
   
   double mms = 100*mms_2/mms2_2;// 計算mms，使用mms_2和mms2_2的值進行計算
   

   static double mmm_ema1 =mtm;
   double mmm_1 = Emas(mtm,mmm1,mmm_ema1);
   mmm_ema1 = mmm_1;
   
   static double mmm_ema2 =mms_1;
   double mmm_2 = Emas(mmm_1,mmm2,mmm_ema2);
   mmm_ema2 = mmm_2;
   
   static double mmm2_ema1 =mtm2;
   double mmm2_1 = Emas(mtm2,mmm1,mmm2_ema1);
   mmm2_ema1 = mmm2_1;
   
   static double mmm2_ema2 =mmm2_1;
   double mmm2_2 = Emas(mmm2_1,mmm2,mmm2_ema2);
   mmm2_ema2 = mmm2_2;
   
   double mmm = 100*mmm_2/mmm2_2;
   
   bool A6 = mms > mmm;
   
   int buy1 = A1+A2+A3+A4+A5+A6;//bool可相加
   int sell1=6 -(A1+A2+A3+A4+A5+A6);
   
   
   double ask=SymbolInfoDouble(NULL,SYMBOL_ASK);
   double sl= 0;
   double tp= 0;   
   int total=PositionsTotal();
   if(total > 0){
   for(int i=total; i>=0; i--){
        if(positioninfo.SelectByIndex(i)==true)// 如果根據索引選擇了持倉信息
        {                    
            if(positioninfo.PositionType() == POSITION_TYPE_BUY){// 如果持倉類型為買入
               if(sell1 >= close_sell){// 如果賣出價大於或等於平倉賣出價
                    trade.PositionClose(positioninfo.Ticket(),0);      // 平掉該持倉，平倉量為0    
                 }                                               
               
            }else{// 否則，持倉類型為賣出
               if(buy1 >= close_buy){
                     trade.PositionClose(positioninfo.Ticket(),0);               
                 }                    
            }
                                           
        }
     }
   }else{
      if(buy1 == buy){
         trade.Buy(0.01,NULL,ask,sl,tp,Symbol()+"buy");      
      }else if(sell1 == sell){
         trade.Sell(0.01,NULL,ask,sl,tp,Symbol()+"sell");
      }
   
   }
       
  }

double ma(int cs,MqlRates& rate[]){
   double result = 0.0;
   for(int i=0; i<cs; i++){
      result+=rate[i].close;
   }
   result=result/cs;
   return result;
}
  
double max(double lc,double data1,int a){
   double qq = data1 - lc;
   if(qq > a){
      return qq;
   }else{
      return a;
   }
}
  
double Smas(double data1,int n,int m,double k_sma1){
   double result = 0.0;// 定義並初始化結果變量為0.0
   result = (data1*m+k_sma1*(n-m))/n; // 使用給定的公式計算結果
   return result;
} 

double maxmin(int period,MqlRates& rate[],int a,string type){//a=1最大值 a=2最小值
   double arr[30];
   int key;
   if(type == "low"){// 如果類型為"low"
      for(int i=0; i< period; i++){
         arr[i] = rate[i].low;
      }   
   }
   if(type == "high"){// 如果類型為"high"
      for(int i=0; i< period; i++){
         arr[i] = rate[i].high;
      }   
   }
   if(a == 1){
      key = ArrayMaximum(arr,0,WHOLE_ARRAY);// 使用ArrayMaximum函數獲取數組中的最大值的索引
   }else {
      key = ArrayMinimum(arr,0,WHOLE_ARRAY);// 使用ArrayMinimum函數獲取數組中的最小值的索引
   }
   return(arr[key]);
     
}   
  
double Emas(double close1,int aver,double ema1){  //ema1为上次Emas的返回值，
   double result = 0.0;

   result = (close1*2+ema1*(aver-1))/(aver+1); 
  // Print("result:",result);
   return result;
}  


