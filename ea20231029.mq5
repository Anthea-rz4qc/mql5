//+------------------------------------------------------------------+
//|                                                       cc1019.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Arrays\ArrayDouble.mqh> 
#include <Trade\Trade.mqh>//导入交易类
#include <Trade\PositionInfo.mqh>
#include <Math\Stat\Normal.mqh> 
#include <Math\Stat\Math.mqh> 
CTrade trade;
CPositionInfo positioninfo;
CArrayDouble ArrayDouble;
input double canshu1 = 0.001;
input double canshu2 = 0.2;
input double canshu3 = 0.01;
input int fx = 0;//1是多 2是空 0是双

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

//input double canshu1 = 0.02;
//input double power1 = 3;

double arr1[70];
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   
  }

void OnTick()
  {
//---
   MqlRates rates[]; //结构存储有关价位、交易量和传递的信息
   ArraySetAsSeries(rates,true); // 將數組rates設置為倒序排列
   CopyRates(Symbol(),0,0,40,rates);//获取 MqlRates 结构的历史序列，按指定品种-周期，按指定数量，并存储到矩阵或向量当中
   static int num = 0;
   
   if(num == 0){//第一个数据直接取
      arr1[num] = rates[0].open;
      num++;
   }else {//后面的数据判断
      double qq1 = MathAbs(rates[0].open-arr1[num-1])/arr1[num-1];//计算数据
      if(qq1 > canshu1){//比较
         if(num > 69){//到最大值后数据的数据开始往前落
            double arr2[69];
            ArrayCopy(arr2,arr1,0,1,69);
            ArrayCopy(arr1,arr2,0,0,69);
            num =69;
            
         }
         arr1[num] = rates[0].open;
         if(num == 69){
            
            double mean1 = mean1(arr1,20);//计算均线
            double   array3[20];
            int q1 = ArraySize(arr1);//数组长度
            int q2 = q1 - 20;
            for(int i=0;i<20;i++){//获取stdevp函数要的数据
               array3[i] = arr1[i+q2];
            }
            double std = stdevp(array3,19,20);
            bool log_mode = false; 
            int error_code = 0;
            //double normal =MathProbabilityDensityNormal(arr1[69],mean1,std,log_mode,error_code);
            double normal2=normdist(arr1[69],mean1,std);
            //通过带入stdevp的值和normdist的值计算仓位
            double aa1 = 1-2*normal2;
            double a1=AccountInfoDouble(ACCOUNT_BALANCE)/100*0.02;
            double cang=aa1*a1/rates[0].open*100;
            cang = MathRound(cang)/100;
            
           
            //double fxcang =fx_cang(fx,cang);
            bool A1 = A1(rates);
            bool A2 = A2(rates);
            bool A3 = A3(rates);
            bool A4 = A4(rates);
            bool A5 = A5(rates);
            bool A6 = A6(rates);
            int buy1 = A1+A2+A3+A4+A5+A6;//bool可相加 A1*6
            int sell1=6 -(A1+A2+A3+A4+A5+A6);
            /*
            if(buy1 ==6 || sell1==6){
                   Print("buy1:",buy1);
                  Print("sell1:",sell1);
            }*/

            double xy = xy();
            if(buy1 ==6 || (buy1>3 && xy >0)){//buy>3 and xy >0
               //double fxcang = fx_cang(1,cang);//当天仓位
               zx(cang);           

            }else if(sell1 == 6 || (sell1>3 && xy <0)){//sell>3 and xy <0

               //double fxcang = fx_cang(2,cang);

               zx(cang);
            }else if((buy1 <= 3 && xy>0) || (sell1 <= 3 && xy<0)){

               zx(0);
            }
/*number   仓位 =double a1=AccountInfoDouble(ACCOUNT_BALANCE)/100;
            double a2=(a1*canshu1)*100;
            number = MathRound(a2)/100;* double aa1 = 1-2*normal2;/当天价格 = cang
          cang=xxxxxx;
          if(方向=‘多’)｛
            if cang<0 cang =0
          ｝
          if(方向=‘kong’)｛
            if cang>0 cang =0
          ｝
          if(方向=‘双’) ｛
            正常执行
          ｝
            */    
                 
            
         }
         num++;
         
         
      }
         
   }
   
   
   //ArrayPrint(arr1);
}

void zx(double d){//83  5 -2
    
   int total=PositionsTotal();
   double y = xy();
   //Print("y:",y);
   double cc1 = d-y;
   
   if(cc1 > 0 ){
      trade.Buy(cc1,NULL,SymbolInfoDouble(NULL,SYMBOL_ASK),0,0,Symbol()+"buy1");
   }else if(cc1 < 0){
      trade.Sell(-cc1,NULL,SymbolInfoDouble(NULL,SYMBOL_ASK),0,0,Symbol()+"Sell1");
   }
   close1_by();
}

double xy(){
   double y =0.0;//静态变量
   int total=PositionsTotal();
   if(total>0){//有单时
      for(int i=total; i>=0; i--){
         if(positioninfo.SelectByIndex(i)==true){
            if(positioninfo.PositionType() == POSITION_TYPE_BUY){//手上的单是买单时
               y += positioninfo.Volume();
               //Print("Volume1b:",positioninfo.Volume());
               
            }else {
               y -= positioninfo.Volume();
               //Print("Volume1s:",positioninfo.Volume());
            }                                            
                                                                                       
         }
        }               
   }
   return  y;
}

bool A1(MqlRates& rates[]){
   static double diff_ema1 =rates[1].open;//静态变量
   static double diff_ema2 =rates[1].open;  
  
   double diff1 = Emas(rates[0].open,diff_aver1,diff_ema1);// 計算diff1，使用rates數組中下標為0的K線的收盤價和diff_aver1、diff_ema1作為參數
   double diff2 = Emas(rates[0].open,diff_aver2,diff_ema2);
   
   double diff = diff1 - diff2;
   
   diff_ema1 = diff1;// 更新diff_ema1的值為diff1
   diff_ema2 = diff2;// 更新diff_ema2的值為diff2
   
   static double dea_ema1 =diff;
   double dea = Emas(diff,dea_aver1,dea_ema1);// 計算dea，使用diff、dea_aver1和dea_ema1作為參數
   dea_ema1 = dea;// 更新dea_ema1的值為dea
   
   bool a1 = diff > dea;// 比較diff和dea的值，將結果賦給布爾變量A1
   return a1;
}

bool A2(MqlRates& rates[]){
   double low8 = maxmin(rsv1_period,rates,2,"low");// 計算最近rsv1_period個K線中的最低價格，將結果賦給變量low8
   double high8 = maxmin(rsv1_period,rates,1,"high");// 計算最近rsv1_period個K線中的最高價格，將結果賦給變量high8
   double rsv1 = (rates[0].open - low8)/(high8-low8)*100;// 計算RSV1，根據當前K線的收盤價、low8和high8計算
   
   static double k_sma1 =rsv1;
   double k = Smas(rsv1,k_n,k_m,k_sma1);
   k_sma1 = k;// 更新k_sma1的值為k
   static double d_sma1 =k;
   double d = Smas(k,d_n,d_m,d_sma1);
   d_sma1 = d;
   
   bool A2 = k > d;// 比較K值和D值，將結果賦給布爾變量A2
   return A2;

}
bool A3(MqlRates& rates[]){
   double lc = rates[refa].open;// 將rates數組中索引為refa的K線的收盤價賦值給變量lc
   double aa1 = rates[0].open - lc;
   double aa2 = MathAbs(aa1);// 計算aa2，取aa1的絕對值
   double ss1 = max(lc,rates[0].open,0);// 計算ss1，取lc和當前K線的收盤價中的最大值，並與0比較取較大值
   
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
   return A3;

}


bool A4(MqlRates& rates[]){
   double high13 = maxmin(rsi_period,rates,1,"high");// 計算最近rsi_period個K線中的最高價格，並將結果賦值給high13
   double low13 = maxmin(rsi_period,rates,2,"low");
   double gg1 = -(high13 - rates[0].open);// 計算gg1，使用high13減去當前K線的收盤價，並取其負值
   double rsv = gg1/(high13-low13)*100;
   
   static double lwr1_sma1 =rsv;
   double lwr1 = Smas(rsv,lwr1_n,lwr1_m,lwr1_sma1);
   lwr1_sma1 =lwr1;
   
   static double lwr2_sma1 =lwr1;
   double lwr2 = Smas(lwr1,lwr2_n,lwr2_m,lwr2_sma1);
   lwr2_sma1 =lwr2;
   
   bool A4 = lwr1 > lwr2;
   return A4;

}

bool A5(MqlRates& rates[]){
   double bbi = (ma(ma1,rates)+ma(ma2,rates)+ma(ma3,rates)+ma(ma4,rates))/4;// 計算bbi，使用ma1、ma2、ma3、ma4和rates作為參數，將結果賦給bbi
   
   bool A5 = rates[0].open > bbi;
   return A5;

}

bool A6(MqlRates& rates[]){
   double mtm = rates[0].open - rates[mtm_ref].open;
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
   return A6;

}

double ma(int cs,MqlRates& rate[]){
   double result = 0.0;
   for(int i=0; i<cs; i++){
      result+=rate[i].open;
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
// (当天仓位/原始)-1   如果原始=0 and当天仓位!=0 ，则zz1=1
double zz1(double d,double y){
   double result = 0.0;
   if(y == 0 && d !=0){
      result = 1;
   }else {
      result =d-y;
   }
   return result;
}

double fx_cang(int c1,double c2){//1是多 2是空 0是双
  double result = 0.0;
  if(c1 ==1 ){
      if( c2 <0){
         result = 0;
      }      
  }
  if(c1 == 2){
      if( c2 >0){
         result = 0;
      } 
  }
  if(c1 == 0){
     result = c2;
  }
 return result;
}

bool close1_by()
{

   int q = 0;
   int w = 0;
   bool result = false;
   double vol_c=0,volx=0,vold=0,volk=0;
    double vol_d[100], voolk[100];
    ulong  ticket_k[100],ticket[100];
   int total=PositionsTotal();
      for(int i=total; i>=0; i--)
     {
      if(positioninfo.SelectByIndex(i)==true)
        {
         //trade.PositionClose(_Symbol,0);POSITION_TYPE_BUY   POSITION_TYPE_SELL  Symbol()
         
         Print("PositionType",positioninfo.PositionType());
         Print("Ticket",positioninfo.Ticket());

          if (positioninfo.PositionType()==POSITION_TYPE_BUY)
                 {
                  ticket[q]=positioninfo.Ticket();
                  
                  q++;
                 }
                     
           if (positioninfo.PositionType()==POSITION_TYPE_SELL)
             {
               ticket_k[w]=positioninfo.Ticket();
               w++;
             }
         
        
        }
     }
     if(q == 0 || w == 0)
      return(true);
     
     //Print("i:",q);
     //Print("k:",w);
     //Print("ticket:",ticket[0]);
     //Print("ticket_k:",ticket_k[0]);
     int d = 0;
     int jd = 0;
     if(q<=w)
         d=q;
      else
        d=w;
     for(jd=d-1;jd>=0;jd--) 
       {
         //result=OrderCloseBy( ticket[jd],ticket_k[jd],Yellow) ;
         
          result=trade.PositionCloseBy(ticket[jd],ticket_k[jd]);
        
       if(result==false)
          break;             
       }
      return(q==0 || w==0);
}  

double mean1(double& array[],int a1){
   double result = 0.0;
   int q1 = ArraySize(array);
   int q2 = q1 - a1;
   for(int i = q2; i<q1; i++){
      result+=array[i];
   }
   result = result/a1;
   return result;
}
                                               
double stdevp(double& array[],int index,int prd)
{

int i=0;
double sum=0,ary=0,ary2=0,sum2=0,stdevp,tocal=0;

while(i<prd)
   {
   //Print("index-i:",index-i);
   ary=array[index-i];
   sum=ary+sum;
   ary2=ary*ary;
   sum2=ary2+sum2;

   i++;

   }
   tocal=((prd*sum2)-sum*sum )/(prd*prd);
   stdevp=MathSqrt(tocal);

return(stdevp);

}

double normdist(double x,double mean,double std_dev)
{
double k2_std=0.85;
double n_data[310]={0.5,0.504,0.508,0.512,0.516,0.5199,0.5239,0.5279,0.5319,0.5359,0.5398,0.5438,0.5478,0.5517,0.5557,0.5596,0.5636,0.5675,0.5714,0.5753,0.5793,0.5832,0.5871,0.591,0.5948,0.5987,0.6026,0.6064,0.6103,0.6141,0.6179,0.6217,0.6255,0.6293,0.6331,0.6368,0.6406,0.6443,0.648,0.6517,0.6554,0.6591,0.6628,0.6664,0.67,0.6736,0.6772,0.6808,0.6844,0.6879,0.6915,0.695,0.6985,0.7019,0.7054,0.7088,0.7123,0.7157,0.719,0.7224,0.7257,0.7291,0.7324,0.7357,0.7389,0.7422,0.7454,0.7486,0.7517,0.7549,0.758,0.7611,0.7642,0.7673,0.7703,0.7734,0.7764,0.7794,0.7823,0.7852,0.7881,0.791,0.7939,0.7967,0.7995,0.8023,0.8051,0.8078,0.8106,0.8133,0.8159,0.8186,0.8212,0.8238,0.8264,0.8289,0.8315,0.834,0.8365,0.8389,0.8413,0.8438,0.8461,0.8485,0.8508,0.8531,0.8554,0.8577,0.8599,0.8621,0.8643,0.8665,0.8686,0.8708,0.8729,0.8749,0.877,0.879,0.881,0.883,0.8849,0.8869,0.8888,0.8907,0.8925,0.8944,0.8962,0.898,0.8997,0.9015,0.9032,0.9049,0.9066,0.9082,0.9099,0.9115,0.9131,0.9147,0.9162,0.9177,0.9192,0.9207,0.9222,0.9236,0.9251,0.9265,0.9278,0.9292,0.9306,0.9319,0.9332,0.9345,0.9357,0.937,0.9382,0.9394,0.9406,0.9418,0.943,0.9441,0.9452,0.9463,0.9474,0.9484,0.9495,0.9505,0.9515,0.9525,0.9535,0.9545,0.9554,0.9564,0.9573,0.9582,0.9591,0.9599,0.9608,0.9616,0.9625,0.9633,0.9641,0.9648,0.9656,0.9664,0.9671,0.9678,0.9686,0.9693,0.97,0.9706,0.9713,0.9719,0.9726,0.9732,0.9738,0.9744,0.975,0.9756,0.9762,0.9767,0.9772,0.9778,0.9783,0.9788,0.9793,0.9798,0.9803,0.9808,0.9812,0.9817,0.9821,0.9826,0.983,0.9834,0.9838,0.9842,0.9846,0.985,0.9854,0.9857,0.9861,0.9864,0.9868,0.9871,0.9874,0.9878,0.9881,0.9884,0.9887,0.989,0.9893,0.9896,0.9898,0.9901,0.9904,0.9906,0.9909,0.9911,0.9913,0.9916,0.9918,0.992,0.9922,0.9925,0.9927,0.9929,0.9931,0.9932,0.9934,0.9936,0.9938,0.994,0.9941,0.9943,0.9945,0.9946,0.9948,0.9949,0.9951,0.9952,0.9953,0.9955,0.9956,0.9957,0.9959,0.996,0.9961,0.9962,0.9963,0.9964,0.9965,0.9966,0.9967,0.9968,0.9969,0.997,0.9971,0.9972,0.9973,0.9974,0.9974,0.9975,0.9976,0.9977,0.9977,0.9978,0.9979,0.9979,0.998,0.9981,0.9981,0.9982,0.9982,0.9983
,0.9984,0.9984,0.9985,0.9985,0.9986,0.9986,0.9987,0.999,0.9993,0.9995,0.9997,0.9998,0.9998,0.9999,0.9999,1};

int aax,aas;
double kks,kk,aa,n_aax,n_aas,n_aasx,x1,n_xb,n_x1;

kks=x-mean;
kk=MathAbs(kks)/std_dev*k2_std;
if(kk>=3)
{
return(1);
}
else if(kk<-3)
{
return(0);
}
else
{
aa=MathAbs(kk)*100 ;
aax=(int)MathFloor(aa); 
aas=(int)MathCeil(aa);
n_aax=n_data[aax];
n_aas=n_data[aas];
n_aasx=n_aas-n_aax;
x1=aa-aax;
n_xb=x1*n_aasx;

if (kks>=0)
{
n_x1=n_aax+n_xb;
}
else
{
n_x1=1-(n_aax+n_xb);
}

return(n_x1);

}

}

int sign(double a1){
   int a=0; 
   if(a1 > 0){
      a=1;
   }
   else if(a1 == 0){
      a=0;
   }
   else if(a1 < 0){
      a=-1;
   }
   return a;
}