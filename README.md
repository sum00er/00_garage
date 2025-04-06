# 00_garage
![image](https://forum-cfx-re.akamaized.net/original/5X/f/1/c/7/f1c77b79e3ca693668220c0462518198540fc69e.jpeg)

### Full version
Purchase full version here: [Tebex](https://sum00er.tebex.io/package/6652843)

### Feature
* Display vehicle name, plate and health
* Garage and impound both included
* Separate job and private vehicles, also allow setting job garage (require job column in database)
* Separate different vehicle types, also allow setting garage for different vehicle types (e.g. boat, helicopters, planes, etc.)
* Allow setting the vehicle condition when retrieve from impound
* exports to open the UI and to store vehicles (can be used to integrate with property or other scripts)
```
--isImpound (boolean)
--SpawnPoint (vector4)
--parking? (string): The name of garage to be opened, leave blank (nil) if not using seperate garage
exports['00_garage']:OpenGarageMenu(isImpound, SpawnPoint, parking, job, vehType)

--parking? (string): The name of garage to be stored, leave blank (nil) if not using seperate garage
exports['00_garage']:StoreVehicle(parking, job, vehType)
```

### Installation
1. Download the zip file and unzip it into your resource folder
3. name the folder 00_garage
2. add ensure 00_garage to your server.cfg

### Requirement
* ox_lib
* oxmysql
* esx/qb (optional)

### Support
Discord: https://discord.gg/pjuPHPrHnx
