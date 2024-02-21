# Whistle
Whistle integrates IoT and Google Technology with a push-button mechanism to address discrimination, bullying, and threats faced by vulnerable groups. This system empowers individuals to boost their personal safety, report potential threats, and alert trusted contacts without the need to navigate through a phone during urgent situations, thereby reducing crucial response time in emergencies. By ensuring accessible and efficient emergency assistance, we want to foster a safer urban environment where everyone can feel secure.

## Overview

### Purpose
Despite the advancements in civilization, discrimination, bullying, and various threats continue to persist in the 21st century, posing significant risks to vulnerable segments of society such as women, disabled individuals, and the elderly. While Singapore boasts a relatively low rate of violent crimes at 9 per 100,000 population in 2021, the United States experienced a much higher rate of 379.4 violent crimes per 100,000 people in 2019. These statistics underscore the critical need for safety measures for all individuals, as violent crimes can have severe impacts on victims, their families, and communities, leading to long-lasting emotional and psychological trauma. Therefore, our solution aims to address these risks by creating a safer environment and ensuring the safety and well-being of all individuals, regardless of their circumstances.

### Features
1. IoT Device Integration
    - Seamless connection between the mobile app and the IoT device using Bluetooth Low Energy (BLE) for efficient, low-power communication.
    - Allows users to create reports or trigger emergencies via button presses on the IoT device.
3. Reporting Features
    - Create Report: In the event of a minor accident or incident, it can be challenging to remember every detail. The reporting feature allows users to create a record using the IoT device immediately, then document important information later. This helps users capture accurate details and maintain a record of the event for future reference.
    - View: Users can view their own reports and reports from their close contacts, enhancing awareness and support within their network.
    - Edit Later: Users can update or modify their reports after triggering, allowing for the addition of new information or clarification of existing details.
5. Emergency Response
    - Emergency Contact: Friends can facilitates immediate actions such as calling emergency services or notifying the user's predefined contacts, enabling a swift response to urgent situations.
6. Mapping and Localization
    - Real-time Location Sharing: Utilizes Google Maps to display the real-time locations of users and their close contacts, providing geographical context to reports and emergencies.
8. Notifications
    - Notify: Sends timely alerts and updates about reports, emergencies, and other relevant activities, ensuring users are promptly informed of significant events within their network of close contacts.
9. Friends
   - Share: Allows users to add close contacts as friends to share reports, emergencies, and locations for improved safety and support.

### Target Audience
- Women: At higher risk of harassment or assault in various settings, they can benefit from a quick and discreet way to alert authorities or loved ones.
- Elderly Individuals: Those with mobility issues or living alone can gain reassurance and safety, knowing they have a direct line for emergency assistance.
- Disabled Individuals: People with disabilities, who might find themselves in situations where they are unable to use standard communication devices easily, could benefit from the simple, physical button interface provided by the IoT device for immediate assistance.
- Children and Teenagers: Young individuals, particularly those who commute alone or are out of their parents’ direct supervision, can use the app as a safety tool to alert their guardians in case of emergencies or uncomfortable situations.
- Outdoor Enthusiasts: People who engage in activities like hiking, running, or cycling in remote areas might find themselves in need of emergency assistance with limited access to traditional communication methods.
- Commuters and Travelers: Individuals who often travel or commute late at night need quick help in unfamiliar or unsafe situations.

## Getting Started
This section provides instructions on how to set up and run the application locally on your development machine. Follow these steps to get the app up and running:

### How to Install

#### Prerequisites
Ensure you have the following installed before you start:
- [Flutter](https://flutter.dev/) (including the Dart SDK)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with the Flutter and Dart plugins
- [Git](https://git-scm.com/) for version control
- [Arduino IDE](https://www.arduino.cc/) with M5Stack board management and M5StickC Plus development kit libraries
- M5StickC Plus

#### Setup Instructions
1. Clone the Repository
First, clone the project repository to your local machine using Git:
`git clone https://github.com/osshiya/GDSC-2024.git`

2. Navigate to Project Directory

#### Flutter Mobile App
1. After cloning, change into the Flutter project directory on Andriod Studio or VS Code:
`cd GDSC-2024/flutter_app`

2. Run the following command to install the necessary Flutter dependencies:
`flutter pub get`

3. Run the Application
Make sure an Android emulator is running or a device is connected to your computer. Then, execute the following command to run the app:
`flutter run`

#### IoT Device
1. After cloning, change into the IoT Device project directory:
`GDSC-2024/iot_device`

2. Open the file `BLE_Server.ino` on Arduino IDE.

3. Connect the M5StickC Plus to the PC via USB, select board and port on Arduino IDE.

4. Upload the code to the M5StickC Plus to run the program.

### How to Use

#### Flutter Mobile App
1. Login for Testing
    - Email: tester@whistletester.com
    - Password: 123123
2. Home: Displays lists of reports and emergencies made by you and your friends.
3. Friends: Add existing users as friends via email to share reports, emergency records, and locations with your friends.
4. Map: View the live locations of you and your friends on the map.
5. Reports: View and update reports created by you.
6. Settings: Change your name and emergency contact information.

#### IoT Device
1. Report: Press the home button on the M5StickC Plus twice to trigger a report.
2. Emergency: Press the home button on the M5StickC Plus thrice to trigger an emergency.

### Examples
<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/cba9eafe-94ac-4e9e-8512-561f8a534126" width="150">
<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/b6e0b8fd-9b86-4e0c-b737-a2c6f9e33906" width="150">

<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/6d3bdd91-a371-4b2e-a7fa-5f613a0b9e6e" width="150">
<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/f1244871-46df-42ef-bb21-edb5ba348502" width="150">
<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/da1d4f21-6400-4c13-a00a-3b6a34fbedfa" width="150">
<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/9ba5fe59-8f57-439e-93a6-4b5a012021d0" width="150">
<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/242f6618-6e02-4f97-996f-4edaa24b979f" width="150">
<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/db21aa1d-c1f4-4059-b078-807850459050" width="150">

<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/332946aa-4ff1-45bd-8b5c-fc8b84f744ab" width="150">
<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/9cc15792-3820-4b0a-b880-7b580b021f37" width="150">
<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/4eb9428c-96e4-4f9b-b842-2f1c3745976c" width="150">
<img src="https://github.com/osshiya/GDSC-2024/assets/64403759/bd2a5cc4-15cf-4b83-84cd-e61c10fb9840" width="150">

## Contact
- [Shi Ya](mailto:osshiya@gmail.com)
- [Chloe Loh](mailto:chloe.r.loh@gmail.com)
