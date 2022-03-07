# QuestLauncherTool
Allows you to place sideloaded app on the main screen of the launcher on Oculus/Meta Quest devices

## How It Works
The Quest UI will place applications on the main screen if the package is marked as owned by your Oculus account. This can be exploited by changing the package name of a sideloaded application to that of any application owned by your account.

## Limitations
- Apps with any sort of tamper protection will fail, as it's fairly trivial to determine a modification has occurred
- If the redirected application has an update, you will be prompted to update and some things will misbehave
- Both applications will lose all on-device data (saves, settings, etc) during the process

### Here are a few redirects I have tried and work well:
- **Instagram (Beta)** -> **PiLauncher** *(This is a good one bc PiLauncher will let you open other apps conveniently)*
- **Facebook (Beta)** -> **Discord** *(Install Oculess for background audio)*
- **Beat Saber (Demo)** -> **BMBF** *(Beat Saber modding tool)*

## How To Use
0. Download as zip and extract to a folder of your choice
1. Install the app you want to override on the Quest, as well as the app you want it to open instead
2. Connect your Quest or Quest 2 to you PC over USB in developer mode. (ADB enabled)
3. Run the batch file and select packages
4. *Wait...* (and keep your headset connected)
5. Select NOT to restore the modified app when prompted, and enjoy
