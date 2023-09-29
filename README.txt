
My Project Package has been submitted with the title - shukri_ahmed_adbb182_project_package.zip

Link to GitHub - https://github.com/Shukriii/MakeupMate

Instructions on how to run/open MakeupMate-----------------------------------------------------

1. Download the zip folder and upzip it
2. Download XCode from https://apps.apple.com/us/app/xcode/id497799835?mt=12
	2.1 I used Version 13.2.1 to develop MakeupMate, the same or later version will work.
3. Open XCode
	3.1 Select option - "Open a project or file"
	3.2 Select the (unzipped) folder (dont open it)
4. At the top of the screen you can see the ios product that the Simulator will display
5. Change this to iPhone 11 
6. Click the Play button the top left corner (after completing the rest of the instructions)

Instructions on how to import Package Dependenicies--------------------------------------

1. On the left hand side navigation pane, click the top file which has a blue icon titled "MakeupMate"
2. Under the "PROJECT" heading on the left, again click the blue icon titled "MakeupMate"
3. On the top click the "Package Dependicies" tab
4. Click the + icon
5. Search the URL - https://github.com/SDWebImage/SDWebImageSwiftUI and click "Add Package"
6. Select dependency rule of "Up to Next Major Version" for package.
7. Once added click the + button again 
8. Search the URL - https://github.com/firebase/firebase-ios-sdk and click "Add Package"
9. Select the following package products:
	9.1 FirebaseAuth
	9.2 FirebaseStorage
	9.3 FirebaseFirestore
10. Select dependency rule of "Up to Next Major Version" for package.
11. Once downloaded you should see two packages
	- Firebase 
	- SDWebImageSwiftUI

Testing------------------------------------------------------------------------------------------

NOTE - You should be able to use MakeupMate whilst its connected to my Firebase database.
I have my DB avaliable until the 30 September. 

This account has been populated with products
email: test13@gmail.com
password: 123123

- To scroll on XCode Simulator, hold down and scroll up or down 
  
- The notification for expiring products is set to 9:00am of the day it will expire. 
You can change the notification time in file CalendarDisplayView lines 151 & 152
Set the time for 2 minutes ahead and re-run the app. 
Change the products expire date to todays date, and click the notification icon. 
Lock the phone (using the right side button) and the notification will appear. 

- To logout click the profile icon on top navigtion bar and Sign Out, 
and then click an icon on the bototm navigation bar and the LoginView will appear.

Instructions how to setup your own Firebase-------------------------------------------------------
 
1. Go to Firebase, and create an account:  https://firebase.google.com/ 
2. Click ‘Add Project’ and enter a project name of choice
3. Once project is created, you should see the message "Get started by adding Firebase to your app"
	3.1 Click the icon that has the message "iOS+"
4. Enter Apple Bundle ID of "city.individual.project.MakeupMate"
5. Download the config file and drag it into XCode project 
	5.1 Remove the previous .plist (make sure the name is "GoogleService-Info.plist")
6. Click Next to the rest of the steps and continue to the console

7. Click the "Build" button on the left hand side 
8. Select Authentication and option "Email/Password"
9. Enable Email/Password and click Save

10. Click the "Build" button on the left hand side, select "Firestore Database"
11. Click "Create database" and "Start in Test Mode"
12. Select a Cloud Firestore location, that is appropiate 

13. Click the "Build" button on the left hand side, select "Storage"
14. Click "Get Started" and "Start in Test Mode"
15. Click Done

- Database Set up complete ! 

MakeupMate Folder Structure--------------------------------------------------------

./MakeupMate (when Xcode is ran this folder is selected)
./MakeupMate/MakeupMate.xcodeproj
./MakeupMate/MakeupMate 
./MakeupMate/MakeupMate/*.swift 
./MakeupMate/MakeupMate/Assets.xcassets (images and colour scheme)
./MakeupMate/MakeupMate/Preview Content 
./MakeupMate/MakeupMate/Utilities (more swift files)
 