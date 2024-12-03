import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:notific_app/LoginPage.dart';
import 'package:notific_app/notification_helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<Map<dynamic, dynamic>> _cards = [];
  User? _user;

  DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('reminders');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  List<String> items = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchCards();
    _initializeNotifications();
    _requestPermissions();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    final bool? granted1 = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> _fetchCards() async {
    if (_user != null) {
      final DatabaseEvent event =
          await _databaseReference.child(_user!.uid).once();
      final DataSnapshot snapshot = event.snapshot;

      List<Map<dynamic, dynamic>> cards = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          cards.add({
            'key': key,
            'title': value['title'],
            'subtitle': value['subtitle'],
            'date': value['date'],
            'time': value['time'],
          });
        });
      }

      setState(() {
        _cards = cards;
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context, firstDate: DateTime.now(), lastDate: DateTime(2025));

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        dateController.text = DateFormat.yMMMd().format(_selectedDate!);
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        timeController.text = _selectedTime!.format(context);
      });
    }
  }

  void deleteItem(String key) async {
    await _databaseReference.child(_user!.uid).child(key).remove();
  }

  Future<void> _showCardDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Reminder"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Enter Title"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: subtitleController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Add Notes"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: dateController,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                      icon: Icon(CupertinoIcons.calendar),
                      //border: OutlineInputBorder(),
                      hintText: _selectedDate == null ? "Select Date" : null),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: timeController,
                  onTap: _selectTime,
                  decoration: InputDecoration(
                      icon: Icon(CupertinoIcons.clock),
                      // border: OutlineInputBorder(),
                      hintText: _selectedTime == null ? "Select Time" : null),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                            Colors.blue.shade300)),
                    onPressed: () {
                      String? newCardKey =
                          _databaseReference.child(_user!.uid).push().key;

                      setState(() {
                        var _schedulingDate = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _selectedTime!.hour,
                            _selectedTime!.minute);
                        if (!_schedulingDate.isBefore(DateTime.now())) {
                          _cards.add({
                            'key': newCardKey,
                            'title': titleController.text,
                            'subtitle': subtitleController.text,
                            'date': DateFormat.yMMMd().format(_selectedDate!),
                            'time': _selectedTime!.format(context)
                          });
                        }
                      });

                      var _schedulingDate = DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime!.hour,
                          _selectedTime!.minute);
                      if (!_schedulingDate.isBefore(DateTime.now())) {
                        _databaseReference
                            .child(_user!.uid)
                            .child(newCardKey!)
                            .set({
                          'title': titleController.text,
                          'subtitle': subtitleController.text,
                          'date': DateFormat.yMMMd().format(_selectedDate!),
                          'time': _selectedTime!.format(context)
                        });

                        zonNotification(context, _selectedDate, _selectedTime,
                            titleController, subtitleController);
                        Navigator.pop(context);
                      } else {
                        showSnackbar(context, "Select Future Time");
                      }
                    },
                    child: Text(
                      "ADD",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()), // Replace with your login/signup screen
                  (Route<dynamic> route) => false,
                );
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    onLongPress: () {
                      showMenu(
                        context: context,
                        position: RelativeRect.fill,
                        items: [
                          PopupMenuItem(
                            value: 0,
                            child: Text('Delete'),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Text('Modify'),
                          ),
                        ],
                      ).then((value) {
                        if (value == 0) {
                          deleteItem(_cards[index]['key']!);
                          setState(() {
                            _cards.removeAt(index);
                          });
                        } else if (value == 1) {
                          print("MODIFY CARDDD");
                        }
                      });
                    },
                    child: Card(
                      key: Key(_cards[index]['key']!),
                      //borderOnForeground: true,
                      color: Colors.black38,
                      margin: EdgeInsets.only(left: 9, right: 9),
                      elevation: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _cards[index]['title'],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Notes :   " + _cards[index]['subtitle'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Date   :  " + _cards[index]['date'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Time   :  " + _cards[index]['time'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          Padding(
            padding: EdgeInsets.only(left: 20, bottom: 20),
            child: Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                    iconSize: 45,
                    color: Colors.blue.shade700,
                    onPressed: () {
                      _showCardDialog();
                    },
                    icon: Icon(CupertinoIcons.add_circled_solid))),
          )
        ],
      ),
    );
  }

  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
