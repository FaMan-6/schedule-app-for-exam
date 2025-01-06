import 'package:flutter/material.dart';
import 'package:schedule_app/main.dart';
import 'package:intl/intl.dart';

class UpdatePage extends StatefulWidget {
  final Map<String, dynamic> dataSchedule;

  const UpdatePage({super.key, required this.dataSchedule});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late TextEditingController _titleScheduleController;
  late TextEditingController _dateScheduleController;
  late TextEditingController _timeScheduleController;
  late TextEditingController _descriptionScheduleController;

  @override
  void initState() {
    super.initState();
    final data = widget.dataSchedule;
    if (widget.dataSchedule.isNotEmpty) {
      _titleScheduleController = TextEditingController(
        text: data['schedule'] ?? '',
      );
      _dateScheduleController = TextEditingController(
        text: data['do_date'] ?? '',
      );
      _timeScheduleController = TextEditingController(
        text: data['time'] ?? '',
      );
      _descriptionScheduleController = TextEditingController(
        text: data['description'] ?? '',
      );
    } else {
      _titleScheduleController = TextEditingController();
      _dateScheduleController = TextEditingController();
      _timeScheduleController = TextEditingController();
      _descriptionScheduleController = TextEditingController();
    }
    debugPrint("Data Schedule: $data");
  }

  String? _titleErrorMessage;
  String? _dateErrorMessage;

  void _inputChecker() {
    setState(() {
      _titleErrorMessage = _titleScheduleController.text.isEmpty
          ? 'Title can\'t be empty'
          : null;
      _dateErrorMessage =
          _dateScheduleController.text.isEmpty ? 'Date can\'t be empty' : null;
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
        _dateScheduleController.text = DateFormat('yyyy-MM-dd').format(picked);
        print(_dateScheduleController.text);
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
      _timeScheduleController.text = picked.format(context);

      print(picked.toString());
    } else {
      _timeScheduleController.text = TimeOfDay.now().toString();
    }
  }

  Future<void> _updateSchedule() async {
    final data = widget.dataSchedule;
    try {
      final response = await supabase
          .from('schedules')
          .update({
            'schedule': _titleScheduleController.text.toString(),
            'do_date': _dateScheduleController.text.toString(),
            'time': _timeScheduleController.text.toString(),
            'description': _descriptionScheduleController.text.isEmpty
                ? null
                : _descriptionScheduleController.text.toString(),
          })
          .eq('id', data['id'])
          .select();

      if (response.isEmpty) {
        debugPrint("Update failed: No data returned");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil dirubah')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Exception caught: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat update')),
      );
    }
  }

  Future<void> _deleteSchedule() async {
    final data = widget.dataSchedule;
    await supabase.from('schedules').delete().eq('id', data['id']);

    const snackBar = SnackBar(
      content: Text('Data berhasil dihapus'),
    );
    Navigator.popUntil(context, (route) => route.isFirst);

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.dataSchedule;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Edit',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Yakin data '),
                          TextSpan(
                            text: data['schedule'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const TextSpan(text: ' ingin dihapus?')
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          _deleteSchedule();
                        },
                        child: const Text('Ya'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Tidak'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleScheduleController,
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
                  controller: _descriptionScheduleController,
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
                        controller: _dateScheduleController,
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
                        controller: _timeScheduleController,
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
                      _updateSchedule();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary, // Teks
                      backgroundColor:
                          Theme.of(context).colorScheme.primary, // Latar
                    ),
                    child: const Text('Edit Schedule'),
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
