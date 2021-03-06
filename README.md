#mumble-ruby-pluginbot
mumble-ruby-pluginbot is a Mumble-Ruby based, extensible bot which can play audio, be fed by different sources, and much more :)

##Features
- Can stream audio fed by a MPD
- Supports client certificates and thus can be registered on a server
- No need for additional web interfaces to control the bot; everything can be done with text commands on your Mumble server
- Support for plugins
- Can download music from Youtube or a search on Youtube
- Supports both CELT and Opus codec for maximum compatibility even on old Mumble servers

##Example for the bot usage
Lets say you want to listen to music from Mozart...

* First lets search on youtube:
    **.yts mozart**
* The bot responds with:
    ```0 Mozart for Baby (3 Hours) - ...```

    ```1 The Best of Mozart | 3 HOURS Piano Sonatas ...```
    
    ```2 Mozart for Studying and ...```
    
* Now you can either let the bot download all search results
    **.yta all**
* or just one specific song
    **.yta 2**
* In both cases the bot will inform you about the current download status:
    ```[21:59:22] ♫ Music Bot 1: do 1 time(s)...```
    ```[21:59:22] ♫ Music Bot 1: fetch and convert```
* Followed by a database update:
    ```[21:59:48] ♫ Music Bot 1: Waiting for database update complete...```
* Now lets show the current music queue:
    **.queue**
* The bot responds with:
    ```0 The Best of Mozart _ 3 HOURS Piano Sonatas ...```
* Now lets playl the file with:
    **.play 0**

More examples can be found in the official documentation, see next section.

##Documentation
* General information about the bot can be found at https://wiki.natenom.com/w/Mumble-Ruby-Pluginbot
* A tutorial about the the installation of Mumble-Ruby-Pluginbot can be found at https://wiki.natenom.com/w/Installation_of_mumble-ruby-pluginbot.
* If the bot is already running on your Mumble server, write **.help** to him.

##Included plugins
See [here for the list of all plugins](https://wiki.natenom.com/w/Category:Plugins_for_Mumble-Ruby-Pluginbot) and also for the documentation of each plugin.

Each plugin has its own help implemented. To get it, write **.help pluginname** to the bot, for example **.help youtube**

##Fully set up Mumble-Ruby-Pluginbot as a Virtual Appliance VirtualBox
Instead of setting up the bot yourself you can download a fully set up Mumble-Ruby-Pluginbot as a virtual appliance for VirtualBox. All you need to do after importing it to VirtualBox is to change one configuration file and add your server address and bot name.

The howto can be [found here](https://wiki.natenom.com/w/VirtualBox_Appliance_for_Mumble-Ruby-Pluginbot)

##Pre configured system images
###Banana Pi 
Download one of the following compressed images:
[(banana.img.gz)](https://robingroppe.de/media/mumble-ruby-pluginbot/banana.img.gz), 
[(banana.img.xz)](https://robingroppe.de/media/mumble-ruby-pluginbot/banana.img.xz), 
[(banana.img.zip)](https://robingroppe.de/media/mumble-ruby-pluginbot/banana.img.zip) 

####Install on SD-Card:
#####Linux
`sudo gunzip -c banana.img.gz | dd of=/dev/sdX`

or

`sudo xz -c -d banana.img.xz | dd of=/dev/sdX`

where sdX is the device for your SD-Card!

#####Windows
Unzip banana.img.zip and then write with Win32DiskImager.
####Setup Bot
Set up Bot as described in [Virtual Appliance](https://wiki.natenom.com/w/VirtualBox_Appliance_for_Mumble-Ruby-Pluginbot)
- root password: bananapi
- user name:  botmaster
- user password: botmaster

###Raspberry Pi2
Download one of the following compressed images:
[(image2.img.gz)](https://robingroppe.de/media/mumble-ruby-pluginbot/image2.img.gz), 
[(image2.img.xz)](https://robingroppe.de/media/mumble-ruby-pluginbot/image2.img.xz), 
[(image2.img.zip)](https://robingroppe.de/media/mumble-ruby-pluginbot/image2.img.zip) 

####Install on SD-Card:
#####Linux
`sudo gunzip -c image2.img.gz | dd of=/dev/sdX`

or

`sudo xz -c -d image2.img.xz | dd of=/dev/sdX`

where sdX is the device for your SD-Card!

#####Windows
Unzip image2.img.zip and then write image2.img with Win32DiskImager.
####Setup Bot
Set up Bot as described in [Virtual Appliance](https://wiki.natenom.com/w/VirtualBox_Appliance_for_Mumble-Ruby-Pluginbot)
- root password: raspbian
- user name:  botmaster
- user password: botmaster

###Banana Pi M2
Download one of the following compressed images:
[(bananaPiM2.img.gz)](https://robingroppe.de/media/mumble-ruby-pluginbot/bananaPiM2.img.gz), 
[(bananaPiM2.img.xz)](https://robingroppe.de/media/mumble-ruby-pluginbot/bananaPiM2.img.xz), 
[(bananaPiM2.zip)](https://robingroppe.de/media/mumble-ruby-pluginbot/bananaPiM2.zip) 
####Install on SD-Card:
#####Linux
`sudo gunzip -c bananaPiM2.img.gz | dd of=/dev/sdX`

or

`sudo xz -c -d bananaPiM2.img.xz | dd of=/dev/sdX`

where sdX is the device for your SD-Card!

#####Windows
Unzip bananaPiM2.zip and then write with Win32DiskImager.
####Setup Bot
Set up Bot as described in [Virtual Appliance](https://wiki.natenom.com/w/VirtualBox_Appliance_for_Mumble-Ruby-Pluginbot)
- root password: bananapi
- user name:  botmaster
- user password: botmaster

