#include <BLEDevice.h>
#include <BLEServer.h>
#include <M5StickCPlus.h>

#define bleServerName "BLE#01"

// Action variables
int click = 0;
int batt = 0;

// Timer variables
unsigned long lastTime = 0;
unsigned long debounceDelay = 50;
unsigned long timerDelay = 15000;  // update refresh every 15sec
unsigned long lastButtonTime = 0;
unsigned long timerButtonDelay = 1000;  // continuous button presses ends if interval is > 1sec

// Other variables
int buzzStatus = 0;
bool deviceConnected = false;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/
#define SERVICE_UUID "01234567-0123-4567-89ab-0123456789ab"

// Buzz On/Off
bool buzzOn() {
  M5.Beep.tone(4000);
  M5.Beep.update();
  return true;
}

bool buzzOff() {
  M5.Beep.mute();
  M5.Beep.update();
  return false;
}

// Report Characteristic and Descriptor (2x)
BLECharacteristic reportCharacteristics("01234567-0123-4567-89ab-0123456789cd", BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor reportDescriptor(BLEUUID((uint16_t)0x2903));

// Emergency Characteristic and Descriptor (3x)
BLECharacteristic emergencyCharacteristics("01234567-0123-4567-89ab-0123456789de", BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor emergencyDescriptor(BLEUUID((uint16_t)0x2904));

// Buzz Characteristic and Descriptor (5x)
BLECharacteristic buzzCharacteristics("01234567-0123-4567-89ab-0123456789ef", BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
BLEDescriptor buzzDescriptor(BLEUUID((uint16_t)0x2905));

// I/flutter (32035): MYSERVICE:  01234567-0123-4567-89ab-0123456789ab | MYCHAR: 01234567-0123-4567-89ab-0123456789ef
// I/flutter (32035): MYSERVICE:  01234567-0123-4567-89ab-0123456789ab | MYCHAR: 01234567-0123-4567-89ab-0123456789de
// I/flutter (32035): MYSERVICE:  01234567-0123-4567-89ab-0123456789ab | MYCHAR: 01234567-0123-4567-89ab-0123456789cd

// Setup callbacks onConnect and onDisconnect
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
    Serial.println("MyServerCallbacks::Connected...");
  };
  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
    Serial.println("MyServerCallbacks::Disconnected...");
    // Restart advertising to accept new connection
    pServer->startAdvertising();
    Serial.println("Restarting advertising...");
  }
};

void setup() {
  // Start serial communication
  Serial.begin(115200);

  // put your setup code here, to run once:
  M5.begin();
  M5.IMU.Init();
  M5.Lcd.setRotation(3);
  M5.Lcd.fillScreen(BLACK);
  M5.Lcd.setCursor(0, 0, 2);

  // Setup Home Button
  pinMode(M5_BUTTON_HOME, INPUT);

  // Create the BLE Device
  BLEDevice::init(bleServerName);

  // Create the BLE Server
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *bleService = pServer->createService(SERVICE_UUID);

  // Create BLE Characteristics and Create a BLE Descriptor
  // Report
  bleService->addCharacteristic(&reportCharacteristics);
  reportDescriptor.setValue("Report Status");
  reportCharacteristics.addDescriptor(&reportDescriptor);

  // Emergency
  bleService->addCharacteristic(&emergencyCharacteristics);
  emergencyDescriptor.setValue("Emergency Status");
  emergencyCharacteristics.addDescriptor(&emergencyDescriptor);

  // Buzz
  bleService->addCharacteristic(&buzzCharacteristics);
  buzzDescriptor.setValue("Buzz Status");
  buzzCharacteristics.addDescriptor(&buzzDescriptor);

  // Start the service
  bleService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);
  pServer->getAdvertising()->start();
  Serial.println("Waiting a client connection to notify...");
}

void loop() {
  if (deviceConnected) {
    // Press the button to activate the Report, Emergency and Buzz by clicks on the BLE server and set new notify status for the BLE Client.
    if (digitalRead(M5_BUTTON_HOME) == LOW && millis() - lastButtonTime > debounceDelay) {
      // Button is pressed and update the count
      click += 1;

      Serial.print("Clicks = ");
      Serial.print(click);
      Serial.print("x");

      M5.Lcd.setCursor(0, 40, 2);
      M5.Lcd.print("Clicks = ");
      M5.Lcd.print(click);
      M5.Lcd.println("x");


      while (digitalRead(M5_BUTTON_HOME) == LOW)
        ;

      lastButtonTime = millis();
    } else {
      if ((millis() - lastButtonTime) > timerButtonDelay && click >= 1) {
        if (click == 2) {
          Serial.print("Report = ");
          Serial.print(click);
          Serial.print("x");

          M5.Lcd.setCursor(0, 60, 2);
          M5.Lcd.print("Report = ");
          M5.Lcd.print(click);
          M5.Lcd.println("x");

          reportCharacteristics.setValue((uint8_t *)&click, sizeof(click));
          reportCharacteristics.notify();
        } else if (click == 3) {
          Serial.print("Emergency = ");
          Serial.print(click);
          Serial.print("x");

          M5.Lcd.setCursor(0, 80, 2);
          M5.Lcd.print("Emergency = ");
          M5.Lcd.print(click);
          M5.Lcd.println("x");

          emergencyCharacteristics.setValue((uint8_t *)&click, sizeof(click));
          emergencyCharacteristics.notify();
        } else if (click == 5) {
          Serial.print("Buzz = ");
          Serial.print(click);
          Serial.print("x");

          M5.Lcd.setCursor(0, 100, 2);
          M5.Lcd.print("Buzz = ");
          M5.Lcd.print(click);
          M5.Lcd.println("x");

          buzzStatus = !buzzStatus;
          if (buzzStatus) {
            buzzOn();
          } else {
            buzzOff();
          }

          buzzCharacteristics.setValue((uint8_t *)&buzzStatus, sizeof(buzzStatus));
          buzzCharacteristics.notify();
        }
        click = 0;
      }
    }
  }
}