import 'dart:convert';
import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_items.dart';
import 'package:weather_app/hourly_forecast_item.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temp = 0;

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    String urlAddress =
        "https://api.openweathermap.org/data/2.5/forecast?lat=28.70&lon=77.10&appid=${dotenv.env['API_KEY']}";
    try {
      final url = Uri.parse(urlAddress);
      final res = await http.get(url);
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw data["message"];
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final data = snapshot.data!['list'];
            final currentTemp = data[0]['main']['temp'];
            final currentPressure = data[0]['main']['pressure'];
            final humidity = data[0]['main']['humidity'];
            final currentSky = data[0]['weather'][0]['main'];
            final windSpeed = data[0]['wind']['speed'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,

                    /// main display
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  "$currentTemp K",
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Icon(
                                  currentSky == 'Clouds' || currentSky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 64,
                                ),
                                Text(
                                  currentSky,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  /// text
                  const Text(
                    "Weather forcast",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  /// scroller
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: [
                  //       for (int i = 1; i < 6; i++)
                  //         HourlyForecastItem(
                  //             icon: data[i]["weather"][0]["main"] == 'Clouds' ||
                  //                     data[i]["weather"][0]["main"] == 'Rain'
                  //                 ? Icons.cloud
                  //                 : Icons.sunny,
                  //             temp: data[i]['main']['temp'].toString(),
                  //             time: data[i]["dt_txt"]
                  //                 .toString()
                  //                 .split(" ")[1]
                  //                 .substring(0, 5),),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 15,
                        itemBuilder: (context, index) {
                          final hourlyForecast = data[index + 1];
                          final time = DateTime.parse(hourlyForecast['dt_txt']);
                          final sky = hourlyForecast["weather"][0]["main"];
                          return HourlyForecastItem(
                              icon: sky == 'Clouds' || sky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              temp: hourlyForecast['main']['temp'].toString(),
                              time: DateFormat.Hm().format(time));
                        }),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  /// Additional info text
                  const Text(
                    "Additional Information",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  /// additional info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfoItem(
                          icon: Icons.water_drop,
                          value: humidity.toString(),
                          label: "Humidity"),
                      AdditionalInfoItem(
                          icon: Icons.air,
                          value: windSpeed.toString(),
                          label: "Wind Speed"),
                      AdditionalInfoItem(
                          icon: Icons.beach_access,
                          value: currentPressure.toString(),
                          label: "Pressure"),
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }
}
