#include "Arduino.h"

//#define USE_ARDUINO_INTERRUPTS true

#include <EEPROM.h>
#include <SoftwareSerial.h>// import the serial library
const byte rx = 2;
const byte tx =3;
SoftwareSerial blueTooth(rx, tx); // RX, TX

const int EEPROM_SIZE = 22;
char deviceName[EEPROM_SIZE]= "";

//const int OUTPUT_TYPE = SERIAL_PLOTTER; // heartbeat pulses

#define SHUTDOWN 12

// data pin and clock pin
const int loadData = 4;


const char start_delimiter = '<';
const char end_delimiter = '>';

const int mic =A0;
const int temp = A1;
int Vo;
float val;

float R1 = 10000;
float logR2,R2,T;
int amplitude =0;


const int pulse = A3;       // PulseSensor PURPLE WIRE connected to ANALOG PIN 0
const int LED = LED_BUILTIN;          // The on-board Arduino LED, close to PIN 13.
//int Threshold = 550;

//pulse constant
#define SAMPLE_SIZE 10
#define RISE_THRESHOLD 3
const int HEART_RATE_UPDATE_INTERVAL = 5000;  //5000// Time interval (ms) to update heart rate
const float HEART_RATE_TOLERANCE = 5.0;      // Minimum change in BPM to update and print

bool passwordCorrect = false;
bool passwordRequested = false;

//pulse varriable

// Variables
int sensorReadings[SAMPLE_SIZE]; // Array to store sensor readings
int ptr = 0;                     // Pointer for reading array
bool lastRising = false;         // Flag to track rising edge
int riseCount = 0;               // Counter for consecutive rising readings
unsigned long lastBeatTime = 0;  // Time of the last detected heartbeat
float lastPrintValue = 0.0;      // Last printed heart rate

//switch pin to control the load module
int sw =6;

// temperature coefficient
float c1 = 0.001129148, c2 = 0.000234125, c3 = 0.0000000876741;

#define EEPROM_PASSWORD_START_ADDRESS 170 // Starting address in EEPROM for the password
#define MAX_PASSWORD_LENGTH 20          // Maximum length of the password

// Function to calculate rolling average
float calculateRollingAverage(int newValue) {
  static int sum = 0;
  sum = sum - sensorReadings[ptr] + newValue;
  sensorReadings[ptr] = newValue;
  ptr = (ptr + 1) % SAMPLE_SIZE;
  return static_cast<float>(sum) / SAMPLE_SIZE;
}

// Function to calculate heart rate
float calculateHeartRate(unsigned long currentTime) {
  float beatInterval = static_cast<float>(currentTime - lastBeatTime);
  if (beatInterval > 0) {
    return 60000.0 / beatInterval;
  }
  return 0.0; // Handle divide by zero
}


 String readPasswordOnce() {
  Serial.print("waiting for password from app... ");
  while (!blueTooth.available()) {}
  String newPassword = blueTooth.readStringUntil('\n');
  newPassword.trim();
  return newPassword;

  // send the password on the EEprom to the app users
   
 
}
 String storedPassword ;

void setup() {
    
  Serial.begin(9600);
  blueTooth.begin(9600);
  
  pinMode(mic,INPUT);
  pinMode(temp,INPUT);
  pinMode(rx,INPUT);
  pinMode(tx,OUTPUT);
  pinMode(sw,INPUT);

  pinMode(SCK, OUTPUT);

  pinMode(10, INPUT); //+lo
  pinMode(11, INPUT);//-lo
  pinMode(A2,INPUT);
  pinMode(pulse,INPUT);
  
  pinMode(loadData,INPUT_PULLUP);
  
  readDeviceNameFromEEPROM();
  //savePasswordToEEPROM("daniel"); // this can be use to stored a new password
  storedPassword = retrieveStoredPassword();
   blueTooth.println("Stored Password: " + storedPassword);
   Serial.println("Stored Password: " + storedPassword);
  

}

int numReadings =5;
int val1;
float weight =0.0;


void loop() {
  // Check if password has been requested
  if (passwordRequested) {
    handlePasswordVerification();
  } else {
    handleBluetoothRequests();
    if (passwordCorrect) {
      handleSensorData();
    }
  }
}

void handlePasswordVerification() {
  String enteredPassword = readPasswordOnce();

  if (comparePassword(enteredPassword)) {
    Serial.println("Password correct!");
    passwordCorrect = true;
    
  // Call the function you want to execute when the password is correct
    //handleSensorData();

  } else {
    Serial.println("Password incorrect!");
    passwordCorrect = false;
  }
  passwordRequested = false;
}

void handleBluetoothRequests() {
  if (blueTooth.available()) {
    delay(100);
    String newDeviceName = blueTooth.readStringUntil('\n');
    newDeviceName.trim();
    newDeviceName.toLowerCase();

    // Process the received data and perform actions accordingly
    if (newDeviceName.equals("load")) {
      handleLoadRequest();
    } else if (newDeviceName.equals("password")) {
     // handlePasswordRequest();
      handleLoadRequest();
    } else {
       Serial.println("Received data: " + newDeviceName); // Debugging line
      processReceivedData(newDeviceName);
      
    }
  }
}

void handleLoadRequest() {
  // Retrieve the patient's data from EEPROM
  String savedPatientName = retrievePatientNameFromEEPROM();
  String savedPhoneNumber = retrievePhoneNumberFromEEPROM();
  String savedPatientAge = retrievePatientAgeFromEEPROM();
  String savedPatientGender = retrievePatientGenderFromEEPROM();
  String storedPassword = retrieveStoredPassword();
  passwordRequested = true;

  // Send the retrieved data back to the Bluetooth device
  String patientData = String(savedPatientName) + ", " + String(savedPhoneNumber) + ", " + String(savedPatientAge) + ", " + String(savedPatientGender) + ", " + String(storedPassword);

  blueTooth.println(patientData + end_delimiter);
  //blueTooth.println(savedPhoneNumber+end_delimiter);
 // blueTooth.println(savedPatientAge+end_delimiter);
 // blueTooth.println(savedPatientGender + end_delimiter);
 // blueTooth.println(storedPassword + end_delimiter);

  // Print the retrieved data to the Serial Monitor for debugging
  Serial.println(savedPatientName);
  Serial.println(savedPhoneNumber);
  Serial.println(savedPatientAge);
  Serial.println(savedPatientGender);
  Serial.println(storedPassword);
}

void handlePasswordRequest() {
  // Retrieve the stored password from EEPROM
  String storedPassword = retrieveStoredPassword();
 blueTooth.println(start_delimiter + storedPassword+end_delimiter);
 passwordRequested = true;
}

void processReceivedData(const String &data) {
  // Check if the received data is a request for the password
  if (data.equals("password")) {
    handlePasswordRequest();
  }
  // Check if the received data is a request to load patient data
  else if (data.equals("load")) {
    handleLoadRequest();
  }
  // Check if the received data contains patient information
  else if (data.startsWith("<")) {
    // Split the received data into different parts
    String parts[7]; // Assuming there are 7 parts in the received data
    int numParts = splitString(data, '<', parts, 7);

    if (numParts == 7) {
      String patName = parts[1];
      String age = parts[2];
      String newPassword = parts[3];
      String gender = parts[4];
      String pressure = parts[5];
      String phone = parts[6];
      String deviceName = parts[7];

      // Perform actions with the parsed data
      updateDeviceName(deviceName);
      refreshDeviceName();
      savePatientNameToEEPROM(patName);
      savePhoneNumberToEEPROM(phone);
      savePatientAgeToEEPROM(age);
      savePatientGenderToEEPROM(gender);
      savePasswordToEEPROM(newPassword);

      Serial.println(patName);
      Serial.println(age);
      Serial.println(phone);
      Serial.println(gender);
    }
  }
}

// Function to split a string into parts based on a delimiter
int splitString(const String &input, char delimiter, String parts[], int maxParts) {
  int partCount = 0;
  int start = 0;
  int end = input.indexOf(delimiter);

  while (end != -1 && partCount < maxParts) {
    parts[partCount] = input.substring(start, end);
    start = end + 1;
    end = input.indexOf(delimiter, start);
    partCount++;
  }

  // Add the remaining part
  if (start < input.length() && partCount < maxParts) {
    parts[partCount] = input.substring(start);
    partCount++;
  }

  return partCount;
}
//float pulse;

void handleSensorData() {
  int heart = readHeartbeat(); // Read heart rate sensor value
  float pulses = heartpulse(); // Process heart rate data
  int breath = Breathing(); // Read breathing sensor value
  float tempValue = temperature(); // Read temperature sensor value

  // You can add more sensor readings and data processing here

  int sw_control = digitalRead(sw); // Read switch status

  Serial.println(sw_control);

  if (sw_control == 1) {
    int load = digitalRead(loadData); // Read load data

    Serial.println(load);

    if (load == 0) {
      weight = 100;
    } else {
      weight = load * 0;
    }
    delay(5);
  }

  if (pulses <30){
     pulses = map(pulses,0.5,30,0,200);
  }


  // Create a string with sensor data
  String sensorData = String(breath) + ", " + String(tempValue) + ", " + String(heart) + ", " + String(pulses) + ", " + String(weight) + "g";

  // Send sensor data over Bluetooth
  blueTooth.println(sensorData+ end_delimiter);

  // Print sensor data to the Serial Monitor
  Serial.println(sensorData+ end_delimiter);
  delay(500);
  // Add any other actions you want to perform with sensor data
}





int temperature(){
  Vo = analogRead(temp);
  R2 =R1*(1023/(float)Vo - 1.0);
  logR2 = log(R2);
  T = 1.0/(c1+ c2*logR2 + c3*logR2* logR2);// to kelvin
  T = T-273.15;//to degree
  return T;
}


unsigned long lastHeartRateUpdateTime = 0;
float heartBPM =0.0;



float heartpulse(){   // heartbeat function
float raw = analogRead(pulse);

if(raw >= 890){
    
// Calculate an average of the sensor over a period of time
float average = calculateRollingAverage(raw);
Serial.println(raw);
Serial.println(average);

// Check for a rising curve (heartbeat)
bool rising = raw > average;
    
if (rising &&!lastRising) {
  riseCount++;
  Serial.println(riseCount);

  if (riseCount >= RISE_THRESHOLD) {
    // Heartbeat detected
    unsigned long currentTime = millis();
    float heartBPM = calculateHeartRate(currentTime);
   
            
    // Print heartbeat rate if it's significantly different from the last value
    if (abs(heartBPM - lastPrintValue) > HEART_RATE_TOLERANCE) {
      
      lastPrintValue = heartBPM;
      
      }
            
    lastBeatTime = currentTime;
    riseCount = 0; // Reset rise count
  }
}
    
lastRising = rising;

 // Check if it's time to update the heart rate
  unsigned long currentTime = millis();
  if (currentTime - lastHeartRateUpdateTime >= HEART_RATE_UPDATE_INTERVAL) {
    heartBPM = calculateHeartRate(currentTime);

    if (abs(heartBPM - lastPrintValue) > HEART_RATE_TOLERANCE) {
      Serial.println(heartBPM);
      lastPrintValue = heartBPM;
    }

    lastHeartRateUpdateTime = currentTime; // Update the last update time
  }
}
else{
  heartBPM =  0;
}
    
delay(10); 

return heartBPM;
}



int Breathing(){
  for (int i = 0; i <= numReadings; i++) {
    
    val = analogRead(mic);

    amplitude += val;
    //delay(20);
  }
  
  // Calculate the average
  int average = amplitude / numReadings;
   amplitude =0;
   
  return average;
}

int valheart;

int readHeartbeat(){
  if((digitalRead(10) == 1)||(digitalRead(11) == 1)){
      Serial.println('!');
      digitalWrite(SHUTDOWN, LOW); //standby mode
    }
else{
// send the value of analog input 0:
digitalWrite(SHUTDOWN, HIGH);
 valheart = analogRead(A2);
}
//Wait for a bit to keep serial data from saturating
delay(1);
return valheart;
}



void readDeviceNameFromEEPROM() {
  bool validName = false; // Flag to check if the stored name is valid

  for (int i = 0; i < EEPROM_SIZE; i++) {
    deviceName[i] = EEPROM.read(i);

    // Check if a null-terminated string is found
    if (deviceName[i] == '\0') {
      validName = true;
      break;
    }
  }

  if (!validName) {
    // If the stored name is not valid, set a default name
    const char* defaultName = "MyDevice";
    strncpy(deviceName, defaultName, EEPROM_SIZE);
    deviceName[EEPROM_SIZE - 1] = '\0'; // Ensure null-terminated
  }

  // Optionally print the device name
  // Serial.println(deviceName);
  // blueTooth.println(deviceName);
}




void updateDeviceName(String newDeviceName) {

  // Ensure the newDeviceName does not exceed the EEPROM_SIZE
  if (newDeviceName.length() >= EEPROM_SIZE) {
    Serial.println("Error: New device name is too long.");
    return;
  }

  // Clear EEPROM
  for (int i = 0; i < EEPROM_SIZE; i++) {
    EEPROM.write(i, 0);
  }
  
   // Write the new device name to EEPROM
  newDeviceName.toCharArray(deviceName, EEPROM_SIZE);
  for (int i = 0; i < newDeviceName.length(); i++) {
    EEPROM.write(i, deviceName[i]);
  }

  Serial.println("Device name updated: " +  newDeviceName);
}



void refreshDeviceName() {
  // Define a timeout for waiting for the module's response
  unsigned long timeout = millis() + 5000; // Adjust the timeout as needed

  blueTooth.print("AT+NAME");
  blueTooth.print(deviceName);
  blueTooth.write('\r');
  blueTooth.write('\n');

  // Wait for the module to respond
  while (!blueTooth.available() && millis() < timeout) {
    // Wait for data or until timeout is reached
  }

  // Check if a response is received
  if (blueTooth.available()) {
    while (blueTooth.available()) {
      char c = blueTooth.read();
      Serial.write(c); // Print the module's response to the Serial Monitor
    }
    Serial.println("Device name updated successfully.");
  } else {
    Serial.println("Error: No response from Bluetooth module.");
  }
}


// saving pattient name and phone number  AND retrieving the saved name and phone number 

#define EEPROM_START_ADDRESS 25 // Starting address in EEPROM for patient name

void savePatientNameToEEPROM(const String &patientName) {
  // Limit the maximum length of the patient name to fit in EEPROM
  int maxLength = min(patientName.length(), EEPROM.length() - EEPROM_START_ADDRESS);

  // Write each character of the patient name to EEPROM
  for (int i = 0; i < maxLength; i++) {
    char c = patientName.charAt(i);
    EEPROM.write(EEPROM_START_ADDRESS + i, c);
  }

  // Null-terminate the string in EEPROM to indicate the end of the name
  EEPROM.write(EEPROM_START_ADDRESS + maxLength, '\0');

  // Commit the changes to EEPROM
 // EEPROM.commit();
}



#define EEPROM_PHONE_START_ADDRESS 75 // Starting address in EEPROM for phone number
#define MAX_PHONE_NUMBER_LENGTH 16    // Maximum length of the phone number

void savePhoneNumberToEEPROM(const String &phoneNumber) {
  // Limit the maximum length of the phone number to fit in EEPROM
  int maxLength = min(phoneNumber.length(), MAX_PHONE_NUMBER_LENGTH);

  // Write each character of the phone number to EEPROM
  for (int i = 0; i < maxLength; i++) {
    char c = phoneNumber.charAt(i);
    EEPROM.write(EEPROM_PHONE_START_ADDRESS + i, c);
  }

  // Null-terminate the string in EEPROM to indicate the end of the phone number
  EEPROM.write(EEPROM_PHONE_START_ADDRESS + maxLength, '\0');

  // Commit the changes to EEPROM
 // EEPROM.commit();
}

#define EEPROM_START_AGE_ADDRESS 100

void savePatientAgeToEEPROM(const String &age){
  int maxLength = min(age.length(), EEPROM.length() - EEPROM_START_AGE_ADDRESS);

  // Write each character of the patient name to EEPROM
  for (int i = 0; i < maxLength; i++) {
    char c = age.charAt(i);
    EEPROM.write(EEPROM_START_AGE_ADDRESS + i, c);
  }

  // Null-terminate the string in EEPROM to indicate the end of the name
  EEPROM.write(EEPROM_START_AGE_ADDRESS + maxLength, '\0');
}

#define EEPROM_START_Gender_ADDRESS 150

void savePatientGenderToEEPROM(const String &age){
  int maxLength = min(age.length(), EEPROM.length() - EEPROM_START_Gender_ADDRESS);

  // Write each character of the patient name to EEPROM
  for (int i = 0; i < maxLength; i++) {
    char c = age.charAt(i);
    EEPROM.write(EEPROM_START_Gender_ADDRESS + i, c);
  }

  // Null-terminate the string in EEPROM to indicate the end of the name
  EEPROM.write(EEPROM_START_Gender_ADDRESS + maxLength, '\0');
}


void savePasswordToEEPROM(const String &password) {
  // Limit the maximum length of the password to fit in EEPROM
  int maxLength = min(password.length(), MAX_PASSWORD_LENGTH);

  // Write each character of the password to EEPROM
  for (int i = 0; i < maxLength; i++) {
    char c = password.charAt(i);
    EEPROM.write(EEPROM_PASSWORD_START_ADDRESS + i, c);
  }

  // Null-terminate the string in EEPROM to indicate the end of the password
  EEPROM.write(EEPROM_PASSWORD_START_ADDRESS + maxLength, '\0');
}

bool comparePassword(const String &enteredPassword) {
  char savedPassword[MAX_PASSWORD_LENGTH + 1]; // +1 for null-terminator
  int i = 0;

  // Read characters from EEPROM until a null-terminator is encountered
  while (i < MAX_PASSWORD_LENGTH) {
    char c = EEPROM.read(EEPROM_PASSWORD_START_ADDRESS + i);

    if (c == '\0') {
      break; // End of the saved password
    }

    savedPassword[i] = c;
    i++;
  }

  // Null-terminate the character array to create a C-style string
  savedPassword[i] = '\0';

  // Compare the entered password with the saved password
  return (enteredPassword.equals(savedPassword));
}


#define EEPROM_START_ADDRESS 25 // Starting address in EEPROM for patient name
#define MAX_NAME_LENGTH 50     // Maximum length of the patient's name

String retrievePatientNameFromEEPROM() {
  char patientName[MAX_NAME_LENGTH + 1]; // +1 for null-terminator
  int i = 0;

  // Read characters from EEPROM until a null-terminator is encountered
  while (i < MAX_NAME_LENGTH) {
    char c = EEPROM.read(EEPROM_START_ADDRESS + i);

    if (c == '\0') {
      break; // End of the patient's name
    }

    patientName[i] = c;
    i++;
  }

  // Null-terminate the character array to create a String
  patientName[i] = '\0';

  // Return the patient's name as a String
  return String(patientName);
}



#define EEPROM_PHONE_START_ADDRESS 75 // Starting address in EEPROM for phone number
#define MAX_PHONE_NUMBER_LENGTH 16    // Maximum length of the phone number

String retrievePhoneNumberFromEEPROM() {
  char phoneNumber[MAX_PHONE_NUMBER_LENGTH + 1]; // +1 for null-terminator
  int i = 0;

  // Read characters from EEPROM until a null-terminator is encountered
  while (i < MAX_PHONE_NUMBER_LENGTH) {
    char c = EEPROM.read(EEPROM_PHONE_START_ADDRESS + i);

    if (c == '\0') {
      break; // End of the phone number
    }

    phoneNumber[i] = c;
    i++;
  }

  // Null-terminate the character array to create a String
  phoneNumber[i] = '\0';

  // Return the phone number as a String
  return String(phoneNumber);
}

#define EEPROM_START_AGE_ADDRESS 100 // Starting address in EEPROM for patient name
#define MAX_NAME_LENGTH_AGE 20     // Maximum length of the patient's name

String retrievePatientAgeFromEEPROM() {
  char age[MAX_NAME_LENGTH_AGE + 1]; // +1 for null-terminator
  int i = 0;

  // Read characters from EEPROM until a null-terminator is encountered
  while (i < MAX_NAME_LENGTH_AGE) {
    char c = EEPROM.read(EEPROM_START_AGE_ADDRESS + i);

    if (c == '\0') {
      break; // End of the patient's name
    }

    age[i] = c;
    i++;
  }

  // Null-terminate the character array to create a String
  age[i] = '\0';

  // Return the patient's name as a String
  return String(age);
}


#define EEPROM_START_Gender_ADDRESS 150 // Starting address in EEPROM for patient name
#define MAX_NAME_LENGTH_GENDER 10     // Maximum length of the patient's name

String retrievePatientGenderFromEEPROM() {
  char GENDER[MAX_NAME_LENGTH_GENDER + 1]; // +1 for null-terminator
  int i = 0;

  // Read characters from EEPROM until a null-terminator is encountered
  while (i < MAX_NAME_LENGTH_GENDER) {
    char c = EEPROM.read(EEPROM_START_Gender_ADDRESS + i);

    if (c == '\0') {
      break; // End of the patient's name
    }

    GENDER[i] = c;
    i++;
  }

  // Null-terminate the character array to create a String
  GENDER[i] = '\0';

  // Return the patient's name as a String
  return String(GENDER);
}

String retrieveStoredPassword() {
  char storedPassword[MAX_PASSWORD_LENGTH + 1]; // +1 for null-terminator
  int i = 0;

  // Read characters from EEPROM until a null-terminator is encountered
  while (i < MAX_PASSWORD_LENGTH) {
    char c = EEPROM.read(EEPROM_PASSWORD_START_ADDRESS + i);

    if (c == '\0') {
      break; // End of the stored password
    }

    storedPassword[i] = c;
    i++;
  }

  // Null-terminate the character array to create a C-style string
  storedPassword[i] = '\0';

  // Return the stored password as a String
  return String(storedPassword);
}

