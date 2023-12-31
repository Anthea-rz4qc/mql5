//+------------------------------------------------------------------+
//|                                                    ea数据库使用测试.mq5 |
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
struct Person 
  { 
   datetime          time;
   int               record;
   double            open;
   double            rs1; 
   double            rs2; 
   double            rs3; 
   double            rs4;
   double            rs5;
   double            rt1;
   int   countrt1;
   double  avgrt1; 
  }; 

string filename=IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_trades.sqlite";
int db=DatabaseOpen(filename, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE | DATABASE_OPEN_COMMON);

input int ma1=5;
input int ma2=10;
input int ma3=20;
input int ma4=60;
input int ma5=120;
input int res1 =4;//
input double canshu1 = 0.02;
input string rt_param1 = ">";
input int youxiao = 1500;
input double parma1 = 0.2;
int tally = 0;
int jishu = 0;
double         MABuffer1[];
double         MABuffer2[];
double         MABuffer3[];
double         MABuffer4[];
double         MABuffer5[];
string rs1rs2;
string rs1rs3;
string rs2rs3;
string rs1_1;
string rs2_1;
string rs3_1;
int OnInit()
  {
//--- create timer

 
      if(db==INVALID_HANDLE) 
     { 
      Print("DB: ", filename, " open failed with code ", GetLastError()); 

     } 
//--- create the DEALS table 
   if(!CreateTableDeals(db)) 
     { 
      DatabaseClose(db); 

     } 
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
//---update1
   int param1 = tally;
      if(!InsertDeals(db,param1)) 
      return;
   if(tally>res1){
      if(!update1(db,param1)) 
      return;      
   }    
    double f=Kellyf();
    close1();    
      if(MathAbs(f)>parma1){
         order1(f);
        
      }else{
         f=0;
         
      }
//--- make sure that hedging system for open position management is used on the account 
   if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) 
     { 
      //--- deals cannot be transformed to trades using a simple method through transactions, therefore complete operation 
      DatabaseClose(db); 
      return; 
     }
    tally++; 
  } 

void close1(){
   int total=PositionsTotal();
   for(int i=total; i>=0; i--){
        if(positioninfo.SelectByIndex(i)==true)// 如果根據索引選擇了持倉信息
        {             

            if(positioninfo.PositionType() == POSITION_TYPE_BUY){// 如果持倉類型為買入
             
                 //trade.PositionClose(positioninfo.Ticket(),0);// 平掉該持倉，平倉量為0
              Print("Comment:",positioninfo.Comment());
              string cc= positioninfo.Comment();
               string to_split= positioninfo.Comment(); // 字符串分成子字符串 
                  string sep="_";                // 分隔符为字符 
                  ushort u_sep;                  // 分隔符字符代码 
                  string result[];               // 获得字符串数组 
                  //--- 获得分隔符代码 
                  u_sep=StringGetCharacter(sep,0); 
                  //--- 字符串分为子字符串 
                  int k=StringSplit(to_split,u_sep,result); 
                  int aa =StringToInteger(result[1]);
                  Print("aa:",aa); 
                  if(aa == tally - res1){
                     trade.PositionClose(positioninfo.Ticket(),0);
                  }      
                                                                                   
            }else{// 否則，持倉類型為賣出
              Print("Comment:",positioninfo.Comment());
              string cc= positioninfo.Comment();
               string to_split= positioninfo.Comment(); // 字符串分成子字符串 
                  string sep="_";                // 分隔符为字符 
                  ushort u_sep;                  // 分隔符字符代码 
                  string result[];               // 获得字符串数组 
                  //--- 获得分隔符代码 
                  u_sep=StringGetCharacter(sep,0); 
                  //--- 字符串分为子字符串 
                  int k=StringSplit(to_split,u_sep,result); 
                  int aa =StringToInteger(result[1]);
                  Print("aa:",aa); 
                  if(aa == tally - res1){
                     trade.PositionClose(positioninfo.Ticket(),0);
                  }                 
              
            }
                                           
        }
     }   
}

void order1(double f){//下单
   double ask=SymbolInfoDouble(NULL,SYMBOL_ASK);
   double sl= 0;
   double tp= 0;
   double a1=AccountInfoDouble(ACCOUNT_BALANCE)/100;
   double a2=(a1*canshu1*MathAbs(f))*100;
   double number = MathRound(a2)/100;
   if(f>0){
      jishu = tally;
      trade.Buy(number,NULL,ask,sl,tp,Symbol()+"buy_"+jishu);
      
   }else{
      jishu = tally;
      trade.Sell(number,NULL,ask,sl,tp,Symbol()+"sell_"+jishu);
     
   }   
}
  
double Kellyf(){//计算凯利公式
   int start;
   int end = tally;
   if(youxiao>tally){
      start = 0;
   }else{
      start = tally - youxiao;
   }
   string query =StringFormat("SELECT count(rt1) as countrt1,avg(rt1) as avgrt1 FROM DEALS WHERE rs1 %s 1 AND rs2 %s 1 AND rs3 %s 1 AND  rs1 %s rs2 AND rs2 %s rs3 AND rs1 %s rs3 AND rt1 > 0 AND record > %d AND record < %d",
                                 rs1_1,rs2_1,rs3_1,rs1rs2,rs2rs3,rs1rs3,start,end);                                                              
   int request=DatabasePrepare(db, query);
   Print("query:",query);
   if(request==INVALID_HANDLE) 
     { 
      Print("DB: ", filename, " request failed with code ", GetLastError()); 
      DatabaseClose(db); 
      return 1.0; 
     }
      double avgrt1;
      int countrt1;     
 while(DatabaseRead(request)) //输出对应的数据
     { 

      DatabaseColumnInteger(request,0, countrt1); 
      DatabaseColumnDouble(request,1, avgrt1);
      Print("countrt1=", countrt1); 
      Print("avgrt1=", avgrt1); 
     }  
//--- delete request after use 
   DatabaseFinalize(request);
   string query2 =StringFormat("SELECT count(rt1) as countrt2,avg(rt1) as avgrt2 FROM DEALS WHERE rs1 %s 1 AND rs2 %s 1 AND rs3 %s 1 AND rs1 %s rs2 AND rs2 %s rs3 AND rs1 %s rs3 AND rt1 < 0 AND record > %d AND record < %d",
                                  rs1_1,rs2_1,rs3_1,rs1rs2,rs2rs3,rs1rs3,start,end);
   int request2=DatabasePrepare(db, query2);
   Print("query:",query2);
    if(request2==INVALID_HANDLE) 
     { 
      Print("DB: ", filename, " request failed with code ", GetLastError()); 
      DatabaseClose(db); 
      return 2.0; 
     }
      double avgrt2;
      int countrt2; 
 while(DatabaseRead(request2)) 
     { 
      DatabaseColumnInteger(request2,0, countrt2); 
      DatabaseColumnDouble(request2,1, avgrt2);
      Print("countrt2=", countrt2); 
      Print("avgrt2=", avgrt2); 
     }                                                
   DatabaseFinalize(request2);   
   if(countrt1 < 5 || countrt2<5){
      return 0.0;
   }else{
      double win = (double)countrt1/((double)countrt1+(double)countrt2);//胜率
      double p_loss =avgrt1/-avgrt2;   //净盈亏比率
      double ff = win - (1-win)/p_loss;//f = 胜率 - (1-胜率)/ 净盈亏比率
      Print("win:",win);
      Print("p_loss:",p_loss);
      Print("ff:",ff);
      
      return ff;
   }
 
}
bool CreateTableDeals(int database) //创建表格
  { 
//--- if the DEALS table already exists, delete it 
   if(!DeleteTable(database, "DEALS")) 
     { 
      return(false); 
     } 
//--- check if the table exists 
   if(!DatabaseTableExists(database, "DEALS")) 
      //--- create the table time,rs1,rs2,rs3,rs4,rs5,rt1,rt2,rt3,rt4,rt5,rt6,rt7,rt8
      if(!DatabaseExecute(database, "CREATE TABLE DEALS(" 
                          "time   INT KEY NOT NULL,"
                          "record    INT      NOT NULL,"
                          "open   REAL     NOT NULL," 
                          "rs1    REAL     NOT NULL," 
                          "rs2    REAL     NOT NULL," 
                          "rs3    REAL     NOT NULL," 
                          "rs4    REAL     NOT NULL," 
                          "rs5    REAL     NOT NULL," 
                          "rt1    REAL," 
                          "rt2    REAL," 
                          "rt3    REAL," 
                          "rt4    REAL," 
                          "rt5    REAL," 
                          "rt6    REAL," 
                          "rt7    REAL," 
                          "rt8    REAL );")) 
        { 
         Print("DB: create the DEALS table failed with code ", GetLastError()); 
         return(false); 
        } 
//--- the table has been successfully created 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Deletes a table with the specified name from the database        | 
//+------------------------------------------------------------------+ 
bool DeleteTable(int database, string table_name) 
  { 
   if(!DatabaseExecute(database, "DROP TABLE IF EXISTS "+table_name)) 
     { 
      Print("Failed to drop the DEALS table  with code ", GetLastError()); 
      return(false); 
     } 
//--- the table has been successfully deleted 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Adds deals to the database table                                 | 
//+------------------------------------------------------------------+ 


bool update1(int database,int param1){
   bool failed=false;
   MqlRates rates[]; 
   ArraySetAsSeries(rates,true); 
   CopyRates(Symbol(),0,0,30,rates);
   double end1 = 0.0;

   int cc=  param1-res1;
   end1 = (rates[0].open/rates[res1].open)-1;
   DatabaseTransactionBegin(database);
      string request_text=StringFormat("UPDATE DEALS SET rt1=%G WHERE record = %G" , 
                                       end1,cc);
      Print("request_text:",request_text);                                  
      if(!DatabaseExecute(database, request_text)) 
        { 
         Print("添加数据失败");
         failed=true; 
         
        } 
     
//--- check for transaction execution errors   0.35*
   if(failed) 
     { 
      //--- roll back all transactions and unlock the database 
      DatabaseTransactionRollback(database); 
      PrintFormat("%s: DatabaseExecute() failed with code %d", __FUNCTION__, GetLastError()); 
      return(false); 
     } 
//--- all transactions have been performed successfully - record changes and unlock the database 
   DatabaseTransactionCommit(database); 
   return(true);   
         
}
bool InsertDeals(int database,int param1) 
  { 
//--- Auxiliary variables 

//--- go through all deals and add them to the database 
   bool failed=false;
   MqlRates rates[]; 
   ArraySetAsSeries(rates,true); 
   CopyRates(Symbol(),0,0,30,rates);
   int ma_handle1=iMA(NULL,PERIOD_CURRENT,ma1,0,MODE_SMA,PRICE_OPEN);
   int ma_handle2=iMA(NULL,PERIOD_CURRENT,ma2,0,MODE_SMA,PRICE_OPEN);
   int ma_handle3=iMA(NULL,PERIOD_CURRENT,ma3,0,MODE_SMA,PRICE_OPEN);
   int ma_handle4=iMA(NULL,PERIOD_CURRENT,ma4,0,MODE_SMA,PRICE_OPEN);
   int ma_handle5=iMA(NULL,PERIOD_CURRENT,ma5,0,MODE_SMA,PRICE_OPEN);      
   
   ArraySetAsSeries(MABuffer1, true);
   ArraySetAsSeries(MABuffer2, true);
   ArraySetAsSeries(MABuffer3, true);
   ArraySetAsSeries(MABuffer4, true);
   ArraySetAsSeries(MABuffer5, true);      
   CopyBuffer(ma_handle1,0,0,1,MABuffer1);
   CopyBuffer(ma_handle2,0,0,1,MABuffer2);
   CopyBuffer(ma_handle3,0,0,1,MABuffer3);
   CopyBuffer(ma_handle4,0,0,1,MABuffer4);
   CopyBuffer(ma_handle5,0,0,1,MABuffer5);
   
   int deals=HistoryDealsTotal(); 
// --- lock the database before executing transactions 
   DatabaseTransactionBegin(database); 

   datetime  time= (datetime)rates[0].time;
   int     record = param1;
   double open = rates[0].open;
   double   rs1=MABuffer1[0]/rates[0].open; 
   double   rs2=MABuffer2[0]/rates[0].open; 
   double   rs3=MABuffer3[0]/rates[0].open;
   double   rs4=MABuffer4[0]/rates[0].open; 
   double   rs5=MABuffer5[0]/rates[0].open; 
   
   if(rs1>1){
     rs1_1=">";
   }else{
      rs1_1="<";
   }
   if(rs2>1){
     rs2_1=">";
   }else{
      rs2_1="<";
   }
   if(rs3>1){
     rs3_1=">";
   }else{
      rs3_1="<";
   }      
   if(rs1>rs2){
     rs1rs2=">";
   }else{
      rs1rs2="<";
   }
   if(rs2>rs3){
      rs2rs3=">";
   }else{
      rs2rs3="<";
   }      
   if(rs1>rs3){
      rs1rs3=">";
   }else{
      rs1rs3="<";
   }   
      //--- add each deal to the table using the following request 
      string request_text=StringFormat("INSERT INTO DEALS (time,record,open,rs1,rs2,rs3,rs4,rs5)" 
                                       "VALUES (%d,%G,%G, %G, %G, %G, %G, %G)", 
                                       time,record,open, rs1, rs2, rs3, rs4, rs5); 
      if(!DatabaseExecute(database, request_text)) 
        { 
         Print("添加数据失败");
         failed=true; 
         
        } 
     
//--- check for transaction execution errors 
   if(failed) 
     { 
      //--- roll back all transactions and unlock the database 
      DatabaseTransactionRollback(database); 
      PrintFormat("%s: DatabaseExecute() failed with code %d", __FUNCTION__, GetLastError()); 
      return(false); 
     } 
//--- all transactions have been performed successfully - record changes and unlock the database 
   DatabaseTransactionCommit(database); 
   return(true); 
  } 