# Sensor Documentation for iOS 

As a participant in Google Summer of Code 2018, I like to believe that I helped an open source organization synchronize the sensors on the iOS mobile application with the ones on the platform, so that programs created with [Pocket Code](https://play.google.com/store/apps/details?id=org.catrobat.catroid&hl=ro) can behave alike as much as possible on both operating systems.

# How I contributed
First things first, Pocket Code is the name of the Android app (which will refer to as Catroid from now on) and Catty is the iOS app. This document is about changes between these two phone app and how I synchronized them to behave alike. Sensors are multiple functions which the user can add to his/her project in order to obtain a larger functionality for the game. Sensors can make use of the device sensors of the actual phone, such as compass, inclination, acceleration etc or they can refer to the program itself (for background images and objects added), such as transparency, brightness, color, position, rotation and many more. <br> 
To make the long story shorter, here is what I did over my awesome summer: I checked how the sensors behave on Android and how they behaved on iOS. I noticed patterns and I wrote tests for the iOS sensors, knowing what values I should obtain. Afterwards, I wrote the conversion functions and I checked if the tests were passing, making certain improvements whenever necessary.

1. **Date & time:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/965/files](https://github.com/Catrobat/Catty/pull/965/files)</br> <br>
Sensors for the date (day, year, month) and time (hour, minute, second) were already synchronized because they depend on the phone settings, but the sensor _weekday_ needed some changes, because:
 + on Catty, Sunday is day 1 and Saturday is day 7 (here, the Gregorian calendar was used)
 + on Catroid, Sunday is day 7 and Monday is day 1

2. **Position X and Y:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/966/files](https://github.com/Catrobat/Catty/pull/966/files)<br> <br>
These sensors refer to the (X, Y) position of an object on the screen, where (0, 0) is right in the middle of the screen. Their values depend on the size of the screen and for both apps, the object can exit the screen (can be positioned somewhere outside of the screen).

    On Catroid, the position (0, 0) is the center of the screen, whereas on Catty, the implementation for the SpriteKit objects imposes that (0, 0) be situated at the bottom left. To synchronize any point on the screen, it is enough to synchronize the bottom left so that it is situated in the middle, because the same function will shift all the other points. So how can a point (bottom left) be moved half to the right and half upwards (the middle of the screen). Exactly! All that is needed is to add to the coordinates half of the sizes of the screen, like this: ` f(x, y) = (x + width / 2, y + height / 2) `. The function is correct because we have to move every point to the right and upwards, so this is why addition is needed (to the right, there are positive values, the same are upwards and the point was already situated at (0, 0)).  

3. **Background & Look numbers:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/967/files](https://github.com/Catrobat/Catty/pull/967/files) <br> <br>
A game can have multiple backgrounds and an object can have more looks. I had to synchronize these values, because the first background/look number on Catroid was 1, while on Catty it was counted from 0. Additionally, I wrote tests and I made sure that the sensor for background number is only available for background images, whereas the sensor for look number is only available for sprite objects.

4. **Brightness:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/971/files](https://github.com/Catrobat/Catty/pull/971/files) </br> <br>
The user can set the brightness of the background image or of an object. But the range of the sensors were different:
+ on Catty, brightness is between [-1, 1]
+ on Catroid it was between [0, 200]
+ both of them were ascending functions

    Here is the conversion I made: let's consider a function f(x) = y, where x is the the value on Catty, and y is the corresponding Catroid value. It is a function on 3 branches: 
+ if x < -1, then y will be 0 (minimum value)
+ if x > 1 then y will be 200 (maximum value)
+ for any x between -1 and 1, y will be equal to 100 * x + 100

    I also needed a function to convert from Catroid to Catty (i.e. to convert the value introduced by the user to the internal sensor range on Catty), which was, as expected, the inverse of f. 

5. **Transparency:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/975/files](https://github.com/Catrobat/Catty/pull/975/files) <br> <br>
Transparency was similar to brightness, but the differences I found were:
+ on Catty, transparency was between [-1, 1]
+ on Catroid, transparency was between [0, 100]
+ on Catty, transparency was descending, whereas on Catroid it was ascending

    The conversion I made was: f(x) = y, where x is the Catty value, and y is the corresponding Catroid value
+ if x > 1, then y is 0 (minimum value)
+ if x < -1, then y is 100 (maximum value)
+ if x is between [-1, 1], then y will be 100 - 100 * x

    Needless to say, I also made use of the inverse of f.

6. **Compass:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/976/files](https://github.com/Catrobat/Catty/pull/976/files) <br> <br>
This sensor is useful to show the cardinal points. The values shown were different as such:

| Position       |Catroid (degrees)    | Catty (radians)  | Catty (degrees)
| ------------- | ------------- | ----------|-----------|
| N | 0 | 0 |0|
| N - E | -45 | pi/4 | 45 |
| E | -90 | pi/2 | 90 |
| S - E | -135 |  3/4 * pi | 135 |
| S | -180 | pi | 180 |
| S - V | 135 | 5/4 * pi | 225 |
| V | 90 | 3/2 * pi | 270 |
| N - V | 45 | 7/4 * pi | 315 |

 As you can notice, the values on Catroid are between (-180, 180], while on Catty they are between [0, pi). So, for values smaller or equal than 180, the conversion is the negative value, whereas for values greater than 180, the conversion is 360 - value.

7. **Inclination:** 
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/977/files](https://github.com/Catrobat/Catty/pull/977/files) <br> <br>
These sensors were a little bit trickier. First of all, the axis X and Y were reversed on Catty than those on Catroid, so I had to be careful here. 

    + X inclination: it had a range of [-pi, pi] on Catty and [-180, 180] on Catroid. When tilting the phone to the right, the values were positive on Catroid and negative on Catty. When tilting the phone to the left, the values were negative on Catroid and positive on Catty. So the conversion I had to make was to reverse the sign and to convert from radians to degrees. 
    + Y inclination: it had a range of [-pi/2, pi/2] on Catty and [-180, 180] on Catroid. When tilting front/back, the signs matched on both operating system, so there was no sign conversion needed. However, the fact that Catty had a range of only 90 degrees while covering a movement of 180 degrees made it difficult to convert. Another factor appeared, wether or not the screen was (almost) facing up or (almost) facing down. I used a property called acceleration.z which was positive when the screen was facing downwards and negative when the screen was facing upwards. In the end, I converted from radians to degrees. You can checkout the code in the pull request. 

8. **Location:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/978/files](https://github.com/Catrobat/Catty/pull/978/files) <br> <br>
Location (altitude, latitude, longitude) depends on the phone gps, so there was no conversion needed to be made. But there is another sensor, called location accuracy, where on Catroid it is 0 if accuracy is not available, but on Catty it has a negative value if it is not available. I synchronized them by comparing the value returned, and if it was smaller than 0, then I returned 0. Any other positive value means that the accuracy is good.

9. **Acceleration:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/979/files](https://github.com/Catrobat/Catty/pull/979/files) <br> <br>
Acceleration was a difficult sensor to measure and to synchronize. It depends on the speed with which the user moves the phone. On the Catty documentation, it says that with every increase with 9.8 m/s^2, the sensor increases with a value of only 1. When I tested by hand, trying to move my hand in a certain direction with the same speed, the values on Catroid were much bigger (around 19-20 on Catroid, and 1.5 - 2.5 on Catty). I concluded that the Catty values should be multiplied with 9.8 so they could have the same scale as the Catroid ones. 

10. **Size:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/982/files](https://github.com/Catrobat/Catty/pull/982/files) <br> <br>
The size of an object can be set by the user and modified any time. Ever since I tested the default values, I noticed that the objects had different sizes on the Catroid phone than on the iPhone, more precisely, the Catroid object was smaller. After trying other values and measuring the screenshots of the object size in photoshop, I concluded that the Catroid object is exactly 2.4 times smaller, which is the constant I used for converting the Catty sensor. Another aspect worth mentioning is that on Catroid, the values memorised were between 0 and very big ones, whereas on Catty, they 100 times smaller (1 on Catty meand 100 on Catroid, this is why I multiplied by 100). On Catty, the object could have a negative size and it showed it upside down, and of the correct size in absolute value. This 'feature' was not implemented in Catroid, so I had to remove it, by simply returning 0 is the value of the sensor was smaller than 0.

11. **Color:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/983/files](https://github.com/Catrobat/Catty/pull/983/files) <br> <br>
On Catroid, the color sensor represents a rotation in degrees between 0 and 200, gradually moving from the original color of the object/background to other colors. For example, it could go like this: dark blue -> purple -> pink -> red -> orange -> yellow -> green -> turqoise -> light blue -> dark blue. It is a circular list and it can start at any base color. The same is on Catty, except that the Catty values were in radians, not in degrees. The Catty values could be both negative and positive, had no limit, but I tested and concluded that ca full circle is obtained with values from 0 to 2 * pi, hence I decided that the value of pi on Catty, corresponds to 100 on Catroid, and a value of 2 * pi on Catty corresponds to 200 on Catroid. <br>
    
Another notable thing to say for the conversion is that Catroid has all its values between 0 and 200, this is why I had to reduce the Catty value using periodicity to 0 and 2 * pi. To do this, I first converted to Catroid degrees and then I exctracted the rest by division with 200, of course, while taking care of the sign of the Catty value. 

12. **Rotation:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/985/files](https://github.com/Catrobat/Catty/pull/985/files)<br> <br>
Rotation is a sensor that keeps track of the direction to which an object on the screen points. On Catroid, it is a value between (-180, 180], in degrees. It starts from 90, when the object is with his head up, going to the right it will be 180, going to the left it will be 0, and with the head down, the object has a rotation of -90. <br>

On Catty, first of all, the values were in radians, so I had to cover the conversion from radians to degrees. Secondly, just like the color sensor, any value could be set on the Catty sensor (not matter of the sign or how big it was). This is why I had to reduce every value to the first trigonometric circle [0, 360) by calculating the rest for division by 360. Additionally, when the object is with its head up, the Catty showed 0 degreed (whereas Catroid showed 90), so there was a difference of 90 to be taken into account to calibrate the sensors. Last but not least, after making sure that the values belong to the first trigonomtric circle and that the default value showed 90 degrees on both operating systems, I had to shift the Catty values from [0, 360) to (-180, 180] so they could properly match the ones on Catroid. 

13. **Layer**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/980/files](https://github.com/Catrobat/Catty/pull/980/files)<br> <br>
Layer was a easy sensor to convert. It refers to the position of an object on the screen (in front of another element or behind it). The values were already synchronized (Catty didn't start from 0 here). The only difference was that the Catty had a layer of 0 for the background image, whereas Catroid saw it as -1 (which means that the background does not have a layer). 

14. **Loudness:**
<br>You can check out the initial pull request here: [https://github.com/Catrobat/Catty/pull/989/files](https://github.com/Catrobat/Catty/pull/989/files)<br> 
[And an improved pull request here.](https://github.com/Catrobat/Catty/pull/997) <br> <br>
The iOS development kit does not offer out-of-the box a sensor that measures the microphone's level of noise in decibels, so I had to do it myself, which proved to be a difficult task. After many tries, the sensor is finally recording and measuring the external noise. <br>

On Catroid, the loudness sensor is 0 if there is complete silence and it shows greater values when there is noise. (I measured values of around 100, but I did not scream very loudly at the device, for obvious reasons.) On Catty, a value of 0 means absolute noise and then, when there is noise, there are negative values. The bigger the value, the louder the noise (-2 is bigger than -5, for instance). <br>
    
I tested the raw values on the Catty app and when there was only very little background noise, it showed values between -35 and - 40, while on Catroid it showed values between 0 and 2. Synchronizing these is a bit tricky. Luckily, I found a function that converted rawValue from Catty to values between [0, 1], which means that all I had to do was to multiply by 100 in order to get matching Catroid values. The function is: `f(x) = 10 ^ (0.05 * rawValue)` . Come to think of it, if rawValue -> 0, then f(x) -> 10 ^ 0, which is 1 (which means a very loud noise, scaled to 100 for Catroid) and values such as -160 will result in an f(x) very small, towards 0. 

15. **Background & Look names:**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/990/files](https://github.com/Catrobat/Catty/pull/990/files) <br> <br>
No conversion was needed here, as these sensors simply return the name of a background or look (the string with which they are being identified by the users). Additionally, just like the number sensor, I wrote tests and I made sure that the sensor for background name is only available for background images, whereas the sensor for look name is only available for sprite objects.

16. **Arduino Bricks**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/987/files](https://github.com/Catrobat/Catty/pull/987/files) <br> <br>
Pocket Code allows the user to connect an Arduino board or to a robot via Bluetooth and to program them by using the bricks available in the application. For these sensors I had to test that they are not shown in the bricks section if the user did not enable their usage in the settings of the app. I wrote tests when they were enabled and disabled and checked to see if they are available for use or not. There was no conversion needed for the Arduino pins, because their set values already match those on Catroid. 

17. **Face detection**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/1011/files(https://github.com/Catrobat/Catty/pull/1011/files) <br> <br>

18. **Touch**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/996/files](https://github.com/Catrobat/Catty/pull/996/files) <br> <br>
The touch sensors represented a group of four sensors: 
+ the sensor that shows if the screen is touched (1 = touched, 0 = not touched) (nothing to synchronize here)
+ the sensor which shows the X coordinates of the touch
+ the sensor which shows the Y coordinates of the touch
+ the sensor which counts the number of touches (nothing to synchronize here)

As for touch coordinates, on Catroid, the (0, 0) position is in the middle of the screen, whereas on Catty, the top left corner represents the coordinates (0, 0) and the bottom right represents the coordinates (screenWidth, screenHeight) for any device. I could conclude that touchX = positionX, but touchY = -positionY. In this manner, the sensors are behaving alike on both operating systems.  


19. **Math**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/1000/files](https://github.com/Catrobat/Catty/pull/1000/files) <br> <br>
I had to make sure that the math functions (sin, cos, ln etc.) showed the same default value like on Catroid and that they also computed to the same value.

20. **String**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/1001/files](https://github.com/Catrobat/Catty/pull/1001) <br> <br>
I had to make sure that the string functions (join, length and letter) showed the same default value like on Catroid and that they also computed to the same value.

21. **List**
<br> You can check out the pull request here: [https://github.com/Catrobat/Catty/pull/1012/files](https://github.com/Catrobat/Catty/pull/1012/files) <br> <br>
I had to make sure that the list functions (number_of_elements, element, contains) showed the same default value like on Catroid and that they also computed to the same value.

# Other things I did

Among my tasks, I had a few Objective C to Swift code conversions and refactoring. Here are the pull requests I made: 
[Formula Editor conversion](https://github.com/Catrobat/Catty/pull/968/files) <br>
[Sensor Button conversion](https://github.com/Catrobat/Catty/pull/969/files) <br> 
[Intern Formula Keyboard Adapter](https://github.com/Catrobat/Catty/pull/970/files) <br> 
[New sensor protocol](https://github.com/Catrobat/Catty/pull/992/files) <br> 
[Simplify sensor protocol](https://github.com/Catrobat/Catty/pull/994/files) <br>
[Compute button continuous - In development]() <br> 

# What I learnt

 + Git (pull requests, merge conflicts, rebasing, I had plenty of unsolicited adventures with these)
 + Test Driven Development ([TDD](https://en.wikipedia.org/wiki/Test-driven_development))
 + To write a markup document (Am I doing a good job?)
 + To be creative: find ways to test the sensors and try to get a value as accurate as possible
 + Last, but not least:
 ```
for(i = 0; i < 1000; i++) {
    print("I will read the documentation...");
}
```

# Bonus

General advice for whoever is reading this: pay attention in math classes! You never know when a math function will help you sort things out. :wink:
