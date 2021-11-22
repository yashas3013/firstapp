# Park Assit

we take an app based approach to identify free 
and paid parking spots in streets and at curbs in dense areas of 
cities and hence saving time and fuel.


In this model, the user requests data regarding free or
paid parking spots available near his/her current location. The request will be sent to the
server that will search for available parking spots in
the database near his/her current location.

Nearby available parking spots will be displayed to the user, on clicking the location, the app will redirect the user to google maps for directions.

Thus, it helps in saving time and fuel as users won't have to manually search for free parking spaces.


## Details

We used flutter and android studio for app development, and Firebase as backend database.
The database will contain all the parking spots[location coordinates of area extremities) and maximum capacity of the spot.

* For the time-being, we used distance formula of coordinates to calculate nearest 3 parking spots as we don't have access to google maps API key, but if we get, we can use the directions feature to find nearest 3 parking spots accurately.
* we will use it's coordinates to check if it's parked in the parking coordinates and add it in the database.
* In a larger model, we will be using android auto/apple carplay to exactly determine if car has stopped and hence parking data will be even more accurate.
* Once the user clicks on one of the location options he will redirected to google maps app for the directions
 
### APK link
https://drive.google.com/file/d/1aL3K1HwDNA6durwsSt_6RX93pjnEiobw/view?usp=sharing
Apk file is also present in build\app\outputs\flutter-apk\app-release.apk
