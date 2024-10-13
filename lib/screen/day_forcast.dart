import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayForecastScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<DayForecastScreen> {
  Map<String, dynamic>? currentWeather;
  List<dynamic> forecast = [];
  String cityName = "London";

  get http => null;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    String apiKey = 'a521729886fc669ae138ed61ba1f335e';
    String city = 'London'; // Change city if needed
    final currentWeatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    try {
      final currentResponse = await http.get(Uri.parse(currentWeatherUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        setState(() {
          currentWeather = json.decode(currentResponse.body);
          forecast = json.decode(forecastResponse.body)['list'];
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather for $cityName'),
      ),
      body: currentWeather == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Current Weather Display
          CurrentWeather(currentWeather: currentWeather!),

          SizedBox(height: 20),

          // 7-day forecast display
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: forecast.length,
              itemBuilder: (context, index) {
                final dayData = forecast[index];
                final dateTime = DateTime.parse(dayData['dt_txt']);
                final dayTemp = dayData['main']['temp'];
                final weatherIconCode = dayData['weather'][0]['icon'];

                // Format the date
                final formattedDate = DateFormat('EEE d MMM').format(dateTime);

                // Show only every 8th item to get daily forecast
                if (index % 8 == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          formattedDate, // Date format like "Mon 2 Oct"
                          style: TextStyle(fontSize: 16),
                        ),
                        Image.network(
                          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAMAAABHPGVmAAAAbFBMVEX////y8vFISEr19fT5+fjw8O/8/PxRUVNLS00qKiwsLC89PT+wsLFqamxWVlisrK17e3xgYGIjIyWDg4Td3d01NTdEREY6Ojx0dHW9vb7n5+dvb3ClpabFxcXLy8uMjI0NDRDX19iampsXFxoJbFREAAAByElEQVRoge2W3XKCMBBG80cgCIiAoNRqbd//HZugoyChzQaY6XT2XHkhc+bbb0kgBEEQBEEQBEGQv0mblGkWZmm5rVYy8CRnTw5JsILjmLEhYbK0gpZsTN4u6mh3Fgdj2dxqpNDIuyO0OjRzLFLQO8YT2HN0xfjX/1AYiDjUkxKW+sbgfQcV9K2YlrCtn4QO0QNJVTRt8RoYpyMLZ/tpy8nDIV4dppZ3NV3LDu6QFgflpFTT8zovEkQP7PiD5AKWjBq5zSsIN3WslIo343LgW2x16HnlH01+Op3yjWKvGnAp1kpMlEt07f5Q5cVrmAwqsVZiolSimyQnJNlvVpIERAa3H4J8FjMlU+PqIcgu9u+kO9x/l+h9HkoA2yXty2uBVPWglXx5hZa00UDietc7VNGXhE1fQldwUHIuivi5x66nCshB5flwydNa1beX8urmcFipPgE3D1Wl6i6ZwypBNJxyoT/3Gm2JHC9GYJCHiVybhh0dgwC2dwjZfjnfvd4SId0/VXwd5rBcX2IOy9XHpXGWeG4XTAI7VAZwZ8mMeQEk/lEA6zXjdYTgaZEgiZ8FMqwOjz0GO4yGQ+JwHwWCIAiCIAiC/He+AT+DFNksC18oAAAAAElFTkSuQmCC',
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${dayTemp.toStringAsFixed(1)}°C',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(); // Skip non-daily entries
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for displaying current weather
class CurrentWeather extends StatelessWidget {
  const CurrentWeather({ required this.currentWeather}) : super();

  final Map<String, dynamic> currentWeather;

  @override
  Widget build(BuildContext context) {
    final temp = currentWeather['main']['temp'];
    final weatherDescription = currentWeather['weather'][0]['description'];
    final weatherIconCode = currentWeather['weather'][0]['icon'];
    final windSpeed = currentWeather['wind']['speed'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${temp.toStringAsFixed(1)}°C and rising',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          Image.network(
            'data:image/jpeg;base64,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',
            width: 100,
            height: 100,
          ),
          Text(
            weatherDescription,
            style: TextStyle(fontSize: 20),
          ),
          Text('Wind: ${windSpeed.toStringAsFixed(1)} m/s Gentle Breeze'),
        ],
      ),
    );
  }
}