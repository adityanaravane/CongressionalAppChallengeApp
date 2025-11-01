If you want a full app demo/explanation here it is: https://www.youtube.com/watch?v=qBhYtcL9ltU

If you want to follow the congressional app challenge style video here it is: https://www.youtube.com/watch?v=2BE54_GO-Hc

Cardian can predict the possibility of heart disease. It takes in a few medical parameters like age, gender, heart rate, blood sugar,  blood pressure, resting ECG, and if the user has chest pain. These are either recorded by smart devices (like apple watch) and in a routine lab or yearly physical. 

The app asks users for permission to read their health information and clinical records. User can choose to not share this information, in which case, user can input the values manually. This app does not save, modify or share this information, the parameters are simple read from the Apple Health app and used only when the app is opened. 
The app landing page displays a realistic heart animation
The second screen is a simple form that displays all information obtained from the Apple Healthkit. The second screen allows you to input any symptoms like chest pain or irregular ECG.
The last screen shows results whether the user may or may not have any heart disease.

The app uses machine learning (feed forward neural network) that is trained using a 1000 point dataset. I did this training separately using python - pytorch library. So the development happened in 2 stages: training and creating a machine learning model in python, then export the trained model to CoreML and then iOS app using swiftUI and Xcode.



If you want to try out this app by yourself, then you should clone the git repository
If you want to try out the python interface, open the folder titled "python" and run the GUI.py file
If you want to try the ios app, then you should open the folder titled "HeartSense" in Xcode, and then run the simulator

