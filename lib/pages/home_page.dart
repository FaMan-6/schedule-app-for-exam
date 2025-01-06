import 'package:flutter/material.dart';
import 'package:schedule_app/main.dart';
import 'package:schedule_app/pages/add_page.dart';
import 'package:schedule_app/pages/profile_page.dart';
import 'package:schedule_app/pages/update_page.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  /// Jadwal berdasarkan stream database
  final _scheduleStream = supabase.from('schedules').stream(primaryKey: ['id']);

  @override
  void initState() {
    super.initState();
    // Set default selectedDay ke hari ini
    _selectedDay = DateTime.now();
  }

  /// Fungsi untuk memfilter jadwal berdasarkan tanggal yang dipilih dan user_id
  Stream<List<Map<String, dynamic>>> getFilteredSchedules() {
    final userId = supabase.auth.currentUser?.id;

    return _scheduleStream.map((schedules) {
      // Filter jadwal sesuai user_id dan tanggal yang dipilih
      final filteredSchedules = schedules.where((schedule) {
        final scheduleDate = DateTime.tryParse(schedule['do_date'] ?? '');

        // Gunakan _selectedDay, jika null gunakan _focusedDay (hari ini)
        final filterDay = _selectedDay ?? _focusedDay;

        return schedule['user_id'] == userId &&
            scheduleDate != null &&
            isSameDay(scheduleDate, filterDay);
      }).toList();

      // Urutkan jadwal berdasarkan waktu
      

      return filteredSchedules;
    });
  }

  /// Fungsi untuk mengubah string waktu ke DateTime
  DateTime? _parseTimeToDateTime(String time) {
    try {
      final timeParts = time.split(":").map(int.parse).toList();
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, timeParts[0], timeParts[1]);
    } catch (e) {
      debugPrint("Error parsing time: $e");
      return null;
    }
  }

  /// Perbarui onDaySelected agar tidak menghapus selectedDay jika hari yang dipilih adalah hari ini
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      // Jika pengguna memilih hari ini, jangan ubah selectedDay
      if (isSameDay(selectedDay, DateTime.now())) {
        _selectedDay = null; // Tampilkan jadwal hari ini
      } else {
        _selectedDay = selectedDay; // Set hari yang dipilih
      }
      _focusedDay = focusedDay; // Perbarui fokus kalender
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: null,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SizedBox(
              height: 270,
                child: TableCalendar(
                  locale: "en_US",
                  rowHeight: 30,
                  focusedDay: _focusedDay,
                  firstDay: DateTime(1950, 01, 01),
                  lastDay: DateTime(2050, 12, 31),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    todayTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    weekendDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onDaySelected: _onDaySelected, // Menggunakan metode baru
                ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: getFilteredSchedules(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        );
                      }

                      final dataSchedules = snapshot.data!;

                      if (dataSchedules.isEmpty) {
                        return Center(
                          child: Text(
                            "No schedule yet",
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: dataSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = dataSchedules[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: ,
                              subtitle: Text(
                                  schedule['description'] ?? 'No Description'),
                              trailing: Text(
                                schedule['time'] ?? 'No Time',
                                style: const TextStyle(fontSize: 15),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdatePage(
                                      dataSchedule: schedule,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
