import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';  // Import for Timer

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Box _box;
  DateTime? _quitDate;
  late Timer _timer;  // Add a Timer variable to periodically update the UI

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _box = await Hive.openBox('cigarette_tracker');  // Open the Hive box
    DateTime? quitDate = _box.get('_quitdate');      // Retrieve the quit date from the box

    if (quitDate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, '/profile');
      });
    } else {
      setState(() {
        _quitDate = quitDate;
      });

      // Initialize the Timer to update the UI every second
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {});  // Call setState to refresh the UI
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();  // Cancel the Timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_quitDate == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // Show loading spinner while waiting
      );

    } else {
      // Calculate the time since quitting
      Duration timeSinceQuit = DateTime.now().difference(_quitDate!);
      double daysSinceQuit = timeSinceQuit.inSeconds / (60 * 60 * 24);

      // Extract years, months, days, hours, minutes, and seconds from the duration
      int days = daysSinceQuit.floor();
      int hours = timeSinceQuit.inHours % 24;
      int minutes = timeSinceQuit.inMinutes % 60;
      int seconds = timeSinceQuit.inSeconds % 60;

      // Retrieve user data from Hive
      int cigarettePackAmount = _box.get('cigarette_pack_amount', defaultValue: 20);
      double cigarettePrice = _box.get('cigarette_price', defaultValue: 0.0);
      int dailyCigaretteNumber = _box.get('daily_cigarette_number', defaultValue: 0);

      // Calculate the money saved and cigarettes avoided
      double moneySaved = dailyCigaretteNumber * cigarettePrice * daysSinceQuit / cigarettePackAmount;
      double cigarettesAvoided = dailyCigaretteNumber * daysSinceQuit;

      // Calculate the time saved
      double minutesSaved = dailyCigaretteNumber * 11 * daysSinceQuit;
      Duration timeSaved = Duration(minutes: minutesSaved.toInt());
      int savedDays = timeSaved.inDays;
      int savedHours = timeSaved.inHours % 24;
      double savedMinutes = (timeSaved.inMinutes % 60) + (timeSaved.inSeconds % 60) / 60;  // Include the fractional part of minutes
      double savedSeconds = timeSaved.inSeconds % 60 + (minutesSaved - minutesSaved.toInt()) * 60;  // Include the fractional part of minutes

      // Calculate the progress for the circular tracker
      DateTime now = DateTime.now();
      Duration elapsedToday = now.difference(_quitDate!);
      Duration fullDay = Duration(days: 1);
      double progress = elapsedToday.inMinutes%1440 / fullDay.inMinutes;  // Progress from 0.0 to 1.0

      // Calculate future savings for 1 day, 1 week, 1 month, 1 year, 5 years
      double dailySavings = dailyCigaretteNumber * cigarettePrice / cigarettePackAmount;
      double weeklySavings = dailySavings * 7;
      double monthlySavings = dailySavings * 30;
      double yearlySavings = dailySavings * 365;
      double fiveYearSavings = dailySavings * 365 * 5;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green, // Set the background color to green
          leading: IconButton(
            icon: Icon(Icons.emoji_events), // Achievement icon
            onPressed: () {
              Navigator.pushNamed(context, '/achievements'); // Navigate to the achievements page
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.person), // Profile icon
              onPressed: () {
                Navigator.pushNamed(context, '/profile'); // Navigate to the profile page
              },
            ),
          ],
          toolbarHeight: 40, // Set the height of the AppBar
        ),
        body:SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time Since Quitting:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${days > 0 ? 'Days: $days, ' : ''}${days > 0 || hours > 0 ? 'Hours: $hours, ' : ''}Minutes: $minutes, Seconds: $seconds',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Daily Progress:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        children: [
                          Center(
                            child: CircularProgressIndicator(
                              value: progress.clamp(0.0, 1.0),  // Clamp progress between 0.0 and 1.0
                              strokeWidth: 70,  // Set the stroke width for the ring
                              backgroundColor: Colors.grey[300],  // Background color of the ring
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),  // Color of the progress
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 70,  // Adjust the size of the white space
                              height: 70,  // Adjust the size of the white space
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,  // White space inside the progress indicator
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(progress * 100).toStringAsFixed(0)}%',  // Show percentage as an integer
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),  // Add space between the progress indicator and the day number
                    Text(
                      '${days+1}. Gün',  // Show the number of days
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Time Saved:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${savedDays > 0 ? '$savedDays days, ' : ''}${savedDays > 0 || savedHours > 0 ? '$savedHours hours, ' : ''} ${(savedMinutes + savedSeconds / 60).toStringAsFixed(2)} minutes',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Money Saved:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₺ ${moneySaved.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Cigarettes Avoided:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${cigarettesAvoided.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showResetConfirmationDialog,
                child: Text('Reset Quit Date'),
              ),
              SizedBox(height: 32),  // Add space before the new card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Spending and Savings:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Total Money Spent: ₺ ${(dailyCigaretteNumber * cigarettePrice * daysSinceQuit / cigarettePackAmount).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Total Cigarettes Smoked: ${(dailyCigaretteNumber * daysSinceQuit).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Estimated Savings:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Table(
                        border: TableBorder.all(),
                        columnWidths: {
                          0: FixedColumnWidth(120),
                          1: FixedColumnWidth(80),
                        },
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('1 Day'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('₺ ${dailySavings.toStringAsFixed(0)}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('1 Week'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('₺ ${weeklySavings.toStringAsFixed(0)}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('1 Month'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('₺ ${monthlySavings.toStringAsFixed(0)}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('1 Year'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('₺ ${yearlySavings.toStringAsFixed(0)}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('5 Years'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('₺ ${fiveYearSavings.toStringAsFixed(0)}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      );
    }
  }

  void _resetQuitDate() {
    setState(() {
      _quitDate = DateTime.now();
      _box.put('_quitdate', _quitDate); // Save the new quit date
    });
  }
  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Progress'),
          content: Text('Do you want to reset your progress?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
                _resetQuitDate();  // Reset the quit date
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
