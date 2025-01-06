import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedule_app/main.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleScheduleController = TextEditingController();
  TextEditingController dateScheduleController = TextEditingController();
  TextEditingController timeScheduleController = TextEditingController();
  TextEditingController descriptionScheduleController = TextEditingController();

  String? _titleErrorMessage;
  String? _dateErrorMessage;

  void _inputChecker() {
    setState(() {
      _titleErrorMessage =
          titleScheduleController.text.isEmpty ? 'Title can\'t be empty' : null;
      _dateErrorMessage =
          dateScheduleController.text.isEmpty ? 'Date can\'t be empty' : null;
    });
  }

  Future<void> _selectedDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1700),
      lastDate: DateTime(2300),
    );

    if (picked != null) {
      setState(() {
        dateScheduleController.text = DateFormat('yyyy-MM-dd').format(picked);
        print(dateScheduleController.text);
      });
    }
  }

  Future<void> _selectedTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      timeScheduleController.text = picked.format(context);

      print(picked.toString());
    } else {
      timeScheduleController.text = TimeOfDay.now().toString();
    }
  }

  Future<void> _addSchedule() async {
    final userId = supabase.auth.currentUser?.id;

    if (descriptionScheduleController.text.isEmpty) {
      descriptionScheduleController.text = 'No description';
    }

    try {
      await supabase.from('schedules').insert(
        {
          'schedule': titleScheduleController.text,
          'user_id': userId,
          'do_date': dateScheduleController.text,
          'time': timeScheduleController.text,
          'description': descriptionScheduleController.text
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data added successfully'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Add',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Column(
            children: [
              TextFormField(
                controller: titleScheduleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  label: const Text('Title'),
                  hintText: 'Enter your Schedule title',
                  focusColor: Theme.of(context).focusColor,
                  errorText: _titleErrorMessage,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 25.0),
                child: TextFormField(
                  controller: descriptionScheduleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    label: const Text('Description'),
                    hintText: 'Enter your schedule description',
                    focusColor: Theme.of(context).focusColor,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dateScheduleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          label: const Text('Date'),
                          filled: true,
                          focusColor: Theme.of(context).focusColor,
                          prefixIcon: const Icon(Icons.calendar_month),
                          errorText: _dateErrorMessage,
                        ),
                        readOnly: true,
                        onTap: () {
                          _selectedDate();
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: timeScheduleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          label: const Text('Time'),
                          filled: true,
                          focusColor: Theme.of(context).focusColor,
                          prefixIcon: const Icon(Icons.timer_sharp),
                        ),
                        readOnly: true,
                        onTap: () {
                          _selectedTime();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      _inputChecker();
                      _addSchedule();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary, // Teks
                      backgroundColor:
                          Theme.of(context).colorScheme.primary, // Latar
                    ),
                    child: const Text('Add Schedule'),
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
