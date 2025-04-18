# geocoder_pro

**Easy forward and reverse geocodeing From google maps api**
make sure to activate Maps SDK for android and ios and geocode api from  <a href="https://console.cloud.google.com">Google Cloud Console</a> 

## Features

* Easy To Use
* No Errors

## Code Example
```dart
import 'package:geocoder_pro/geocoder_pro.dart';
```

## Get Data Form Coordinates
```dart
    GeoData data = await GeocoderPro.getDataFromCoordinates(
        latitude: 40.714224,
        longitude: -73.961452,
        googleMapApiKey: "GOOGLE_MAP_API_KEY");
    
    //Formated Address
    print(data.address);
    //City Name
    print(data.city);
    //Country Name
    print(data.country);
    //Country Code
    print(data.countryCode);
    //Latitude
    print(data.latitude);
    //Longitude
    print(data.longitude);
    //Postal Code
    print(data.postalCode);
    //State
    print(data.state);
    //Street Number
    print(data.street_number);

```
## Get Data From Address
```dart
    GeoData data = await GeocoderPro.getDataFromAddress(
        address: "277 Bedford Ave, Brooklyn, NY 11211, USA",
        googleMapApiKey: "GOOGLE_MAP_API_KEY");
    
    //Formated Address
    print(data.address);
    //City Name
    print(data.city);
    //Country Name
    print(data.country);
    //Country Code
    print(data.countryCode);
    //Latitude
    print(data.latitude);
    //Longitude
    print(data.longitude);
    //Postal Code
    print(data.postalCode);
    //State
    print(data.state);
    //Street Number
    print(data.street_number);
```

Both methods also have an optional ```language``` parameter to request the results in a specific language.
Here is the [list of supported language codes](https://developers.google.com/maps/faq#languagesupport).

### Buy Me A Coffee
