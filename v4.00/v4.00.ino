#include <EEPROM.h>
#include <ArduinoJson.h>
#include "ESP8266WiFi.h"
#include <ESP8266WebServer.h>
#include <WiFiUdp.h>
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <IRremoteESP8266.h>
#include <IRrecv.h>
#include <IRutils.h>

#define PWM 14
#define ADC A0
//hằng số 
const int freq=1500;
//tốc độ
int maxSpeed=255;
int minSpeed=0;

//timer
unsigned long  startTimer= 0;   
long interval = 0;

String ssid="";
String password="";
IPAddress ipClient;
char* ssidHost="WiFiSmartFan";
char* passHost="";
IPAddress ipHost;
bool isConnectToHost=false;

ESP8266WebServer server(80);

char packetData[255];
const int port= 17499;
WiFiUDP udp;

const int width=128;
const int height=64;
Adafruit_SSD1306 display(width,height,&Wire,-1);

const uint16_t irPin= 13;
IRrecv irrecv(irPin);
decode_results results;
int currentBtn,pastBtn,currentValue,oldValue;
bool isInput=false;
int modeChoose=0;
bool isRun=false;

int imode=0;
int currentWind=0;
int timer=0;
int row=0;

//function
void saveWiFiToEEPROM(String ssid, String pass);
String getJsonFromEEPROM();
String readValueFromJson(char *json,String key);
void rowShow(char *str,bool isON,int index,int pos);
void lcdShow(int row,int wind1,int timer3, int imode);
int raw2Num(int raw);
int formatNum(int value,int minVal,int maxVal,bool isLoop);
int formatWind(int value);
void setup() {
  Serial.begin(115200);
  analogWriteFreq(freq);
  WiFi.softAP(ssidHost,passHost);
  if(getJsonFromEEPROM()!="{}"){
    Serial.println("RUN");
    String jsonWifi=getJsonFromEEPROM();
    char *charJson=(char*)jsonWifi.c_str();
    ssid=readValueFromJson(charJson,"ssid");
    password=readValueFromJson(charJson,"pass");
  }
  if (ssid!=""){
    int count=0;
    WiFi.begin(ssid,password);
    Serial.printf("Connect to %s",ssid);
    while(WiFi.status()!=WL_CONNECTED&&count<=100){
      delay(500);
      count++;
    }
    if(count<=100){
      Serial.println("Thành Công");
      isConnectToHost=true;
      ipClient=WiFi.localIP();
    }else{
      Serial.println("Lỗi");
    }
  }
  ipHost=WiFi.softAPIP();
  server.on("/", TrangChu);
  server.begin();
  udp.begin(port);

  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) { 
    Serial.println(F("Lỗi LCD"));
  }
  display.display();
  lcdShow(row,currentWind,timer,imode);

  irrecv.enableIRIn();
}
 
void loop() {
  currentValue=analogRead(ADC);
  if((currentValue!=oldValue)&&(abs(oldValue-currentValue)>=10)){
    oldValue=currentValue;
    if(currentValue<15)currentValue=0;
    imode=1;
    row=1;
    currentWind=(int)((float)currentValue/(float)1024*13);
    lcdShow(row,currentWind,timer,imode);
    isRun=true;
  }
  delay(100);
  server.handleClient();
  delay(100);
  int packetSize=udp.parsePacket();
  if(packetSize){
    int len=udp.read(packetData,254);
    if(len>0)packetData[len]='\0';
    Serial.printf("\n%d bytes từ %s:%d data: %s\n", packetSize, udp.remoteIP().toString().c_str(), udp.remotePort(),packetData);
    udp.beginPacket(udp.remoteIP(),udp.remotePort());
    String getmode=readValueFromJson(packetData,"mode");
    if(getmode=="99"){
      String newSSID=readValueFromJson(packetData,"name");
      String newPASS=readValueFromJson(packetData,"pass");
      saveWiFiToEEPROM(newSSID,newPASS);
    }else if(getmode.toInt()>0){
      int wind_str2int=readValueFromJson(packetData,"wind").toInt();
      int timer_str2int=readValueFromJson(packetData,"timer").toInt();
      if(wind_str2int>=0&&timer_str2int>=0){
        currentWind=formatNum(wind_str2int,0,13,false);
        timer=formatNum(timer_str2int,0,99,false);
        if(getmode.toInt()==3){
          startTimer= millis();
          interval = timer*60*1000;
        }
        imode=getmode.toInt();
        isRun=true;
        row=imode;
        lcdShow(row,currentWind,timer,imode);
      }
    }
    udp.endPacket(); 
  }
  if(irrecv.decode(&results)){
    currentBtn=raw2Num(results.value);
    if(currentBtn==17)currentBtn=pastBtn;
    switch(currentBtn){
      case 0:{
        if(isInput)timer=timer*10+currentBtn;
        else{
          timer=currentBtn;
        }
        isInput=!(isInput);
        break;
      }
      case 1:{
        if(isInput)timer=timer*10+currentBtn;
        else{
          timer=currentBtn;
        }
        isInput=!(isInput);
        break;
      }
      case 2:{
        if(isInput)timer=timer*10+currentBtn;
        else{
          timer=currentBtn;
        }
        isInput=!(isInput);
        break;
      }
      case 3:{
        if(isInput)timer=timer*10+currentBtn;
        else{
          timer=currentBtn;
        }
        isInput=!(isInput);
        break;
      }
      case 4:{
        if(isInput)timer=timer*10+currentBtn;
        else{
          timer=currentBtn;
        }
        isInput=!(isInput);
        break;
      }
      case 5:{
        if(isInput)timer=timer*10+currentBtn;
        else{
          timer=currentBtn;
        }
        isInput=!(isInput);
        break;
      }
      case 6:{
        if(isInput)timer=timer*10+currentBtn;
        else{
          timer=currentBtn;
        }
        isInput=!(isInput);
        break;
      }
      case 7:{
        if(isInput)timer=timer*10+currentBtn;
        else{
          timer=currentBtn;
        }
        isInput=!(isInput);
        break;
      }
      case 8:{
        if(isInput)timer=timer*10+currentBtn;
        else{
          timer=currentBtn;
        }
        isInput=!(isInput);
        break;
      }
      case 9:{
        if(isInput)timer=timer*10+currentBtn;
        else{
          timer=currentBtn;
        }
        isInput=!(isInput);
        break;
      }
      case 12:{
        if(modeChoose==0){row--;}
        else{
          if(imode==1){currentWind--;}
          else if(imode==3){timer--;}
        }
        break;
      }
      case 13:{
        if(modeChoose==0){row++;}
        else{
          if(imode==1){currentWind++;}
          else if(imode==3){timer++;}
        }
        break;
      }
      case 14:{
        if(imode==1)currentWind--;
        break;
      }
      case 15:{
        if(imode==1)currentWind++;
        break;
      }
      case 16:{
        if(modeChoose==0){imode=row;modeChoose++;}
        else if(modeChoose==1){
          modeChoose++;
        }
        else{
          if(imode==3){
            startTimer= millis();   
            interval = timer*60*1000;
            Serial.printf("\n%d --- %d\n",startTimer,interval);
          }else if(imode==2)startTimer= millis();
          modeChoose=0;
          isRun=true;
        }
        
        break;
      }
    }
    timer=formatNum(timer,0,99,true);
    currentWind=formatNum(currentWind,0,13,false);
    row=formatNum(row,1,3,true);
    lcdShow(row,currentWind,timer,imode);
    if(currentBtn!=17)pastBtn=currentBtn;
    irrecv.resume();
  }

  if(isRun){
    float speedFloat=(float)formatWind(currentWind)/(float)13*255;
    int speedInt=(int)speedFloat;
    Serial.printf("run mode %d with wind %d and timer %d read speed %d\n",imode,currentWind,timer,speedInt);
    if(imode==1){
      analogWrite(PWM,speedInt);
      isRun=false;
    }
    if(imode==2){
      unsigned long currentMillis = millis();
      if(currentMillis-startTimer>=1000){
        currentWind++;
        if(currentWind>13)currentWind=2;
        analogWrite(PWM,speedInt);
        startTimer=currentMillis;
      }
    }
    if(imode==3){
      unsigned long currentMillis = millis();
      if(currentMillis-startTimer<500)analogWrite(PWM,speedInt);
      if((currentMillis-startTimer)%(60*1000)==0){
          timer--;
          lcdShow(row,currentWind,timer,imode);
        }
      
      if(currentMillis-startTimer>=interval){
        timer=0;
        lcdShow(row,currentWind,timer,imode);
        Serial.println("Stop");
        analogWrite(PWM,0);
        isRun=false;
      }
    }
  }
}


void saveWiFiToEEPROM(String ssid, String pass){
  DynamicJsonDocument doc(1024);
  String json="";
  doc["ssid"]=ssid;
  doc["pass"]=pass;
  serializeJson(doc,json);
  EEPROM.begin(50);
  int i;
  for(i=0;i<json.length();i++){
    EEPROM.write(i,json[i]);
  }
  EEPROM.write(json.length(),'\0');
  EEPROM.commit();
  EEPROM.end();
  Serial.println("Lưu thành công");
}
String getJsonFromEEPROM(){
  int i=0;
  String value="";
  EEPROM.begin(50);
  if(char(EEPROM.read(0))!='{')return "{}";
  while(EEPROM.read(i)!='\0'){
    value+=char(EEPROM.read(i));
    i++;
  }
  EEPROM.end();
  return value;
}
String readValueFromJson(char *json,String key){
  const char* _json=json;
  StaticJsonDocument<200> doc;
  deserializeJson(doc,_json);
  return doc[String(key)];
}
void rowShow(char *str,bool isON,int index,int pos){
  display.setTextColor(WHITE);
  if(index==pos){
    display.setTextColor(BLACK, WHITE);
  }
  display.printf(str,isON?"ON":"OFF");
}
void lcdShow(int row,int wind1,int timer3, int imode) {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0,0);
  rowShow("Normal Mode:%7s\n",imode==1?true:false,1,row);
  rowShow("Natural Mode:%6s\n",imode==2?true:false,2,row);
  rowShow("Timer Mode:%8s\n",imode==3?true:false,3,row);
  display.drawRect(0,32,128,32,WHITE);
  if(modeChoose!=0){
    display.setTextColor(BLACK, WHITE);
  }else{
    display.setTextColor(WHITE);
  }
  display.printf("MODE %d",imode);
  display.setCursor(0,34);
  if (imode==0){
    display.setTextColor(WHITE);
    display.printf("Please select mode");
  }else if(imode==1){
    int i;
    for(i=0;i<wind1;i++){
      display.fillRect(3+10*i,35,10,10,WHITE);
    }
  }else if(imode==2){
    display.setTextColor(WHITE);
    display.printf("Natural Mode is ON");
  }else if(imode==3){
    display.setTextColor(WHITE);
    display.printf("Minutes:");
    display.drawRect(80,35,25,25,WHITE);
    display.drawRect(45,35,25,25,WHITE);
    display.setCursor(53,40);
    display.setTextSize(2);
    display.printf("%d",timer3/10);
    display.setCursor(88,40);
    display.printf("%d",timer3%10);
  } 
  display.display();
}
int raw2Num(int raw){
  switch (raw){
      case 16753245:{
        return 1;
        break;
      }
      case 16736925:{
        return 2;
        break;
      }
      case 16769565:{
        return 3;
        break;
      }
      case 16720605:{
        return 4;
        break;
      }
      case 16712445:{
        return 5;
        break;
      }
      case 16761405:{
        return 6;
        break;
      }
      case 16769055:{
        return 7;
        break;
      }
      case 16754775:{
        return 8;
        break;
      }
      case 16748655:{
        return 9;
        break;
      }
      case 16750695:{
        return 0;
        break;
      }
      case 16738455:{
        return 10;//*
        break;
      }
      case 16756815:{
        return 11;//#
        break;
      }
      case 16718055:{
        return 12;//up
        break;
      }
      case 16730805:{
        return 13;//down
        break;
      }
      case 16716015:{
        return 14;//left
        break;
      }
      case 16734885:{
        return 15;//right
        break;
      }
      case 16726215:{
        return 16;//ok
        break;
      }
      case 18446744073709551615:{
        return 17;//dump
        break;
      }
      default:{
        return -1;
        break;
      }
    }
}
int formatNum(int value,int minVal,int maxVal,bool isLoop){
  if(value>maxVal){
    if(isLoop)return minVal;
    return maxVal;
  }else if(value<minVal){
    if(isLoop)return maxVal;
    return minVal;
  }
  return value;
}
int formatWind(int value){
  if (value==0){
    value=1;
  }
  if(value==13){
    value=12;
  }
  return 13-value;
}
void TrangChu(){
  DynamicJsonDocument doc(1024);
  String json="";
  doc["mode"]=imode;
  doc["speed"]=currentWind;
  doc["timer"]=timer;
  serializeJson(doc,json);
  server.send(200, "application/json",json);
}
