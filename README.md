# EzSFEnc
Easy MP4 to Encrypted Softdec Prime Script

# Credits
* https://github.com/donmai-me/WannaCRI
* https://tekkenmods.com/article/46/creating-custom-usm-files
* https://github.com/vgmstream/vgmstream/

# Setup WSL
0. Download and Extract the code a folder https://github.com/UiharuKazari2008/EzSFEnc/archive/refs/heads/main.zip
1. Install Ubuntu from the Microsoft Store
  * If you want to deal with Python on windows **b e  m y  g u e s t** and make a pull request
2. Run Ubuntu from the start menu
3. Setup the enviorment
```
Installing, this may take a few minutes...
Please create a default UNIX user account. The username does not need to match your Windows username.
For more information visit: https://aka.ms/wslusers
Enter new UNIX username: ykazari
New password: ********************
Retype new password: ********************
passwd: password updated successfully
Installation successful!
```
4. Close the terminal, The PowerShell script will do the rest

# Encode Video
1. Drop your MP4 files in the root of the folder
  * **PLEASE KEEP THE FILENAME CLEAN AND SIMPLE**, PowerShell seems to like to have issues with filenames at times and will not say anything about the error like its normal.
2. Right Click `mp4-to-enc.ps1` and select `Run in PowerShell`
3. If this is your first time it will take a few minutes to set up the linux enviorment, once complete it will then start to encode
4. When complete your videos will be placed in the root of the folder with the .enc extention
