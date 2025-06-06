import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/meetings/presentation/widget/custom_calendar.dart';
import 'package:Appointly/module/meetings/presentation/widget/dropdown_time.dart';
import 'package:Appointly/module/meetings/presentation/widget/empty_state_service.dart';
import 'package:Appointly/module/meetings/presentation/widget/expanded_text.dart';
import 'package:Appointly/module/meetings/presentation/widget/success_state.dart';
import 'package:Appointly/module/meetings/presentation/widget/calendar_sync_dialog.dart';
import 'package:Appointly/module/meetings/repository/service_repository.dart';
import 'package:Appointly/core/service/permission_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Appointly/module/meetings/model/service_model.dart';
import 'package:intl/intl.dart';
import 'package:Appointly/module/notification/utils/notification_helper.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:Appointly/module/notification/presentation/bloc/notification_bloc.dart';

class DetailMeetingScreen extends StatefulWidget {
  final int serviceId;
  final int bookingId;
  final String userId;

  const DetailMeetingScreen({
    super.key,
    required this.serviceId,
    required this.userId,
    required this.bookingId,
  });

  @override
  State<DetailMeetingScreen> createState() => _DetailMeetingScreenState();
}

class _DetailMeetingScreenState extends State<DetailMeetingScreen> {
  String selectedOption = 'Offline';
  final TextEditingController _noteController = TextEditingController();
  final ServiceRepository _serviceRepository = ServiceRepository();

  DateTime? selectedDate;
  int _selectedTimeIndex = 0;
  bool _isBookingInProgress = false;
  bool _enableCalendarSync = true;

  // Menyimpan index waktu yang dipilih alih-alih menyimpan string waktu
  // Getter untuk mendapatkan waktu yang dipilih dari service
  String get selectedTime {
    final state = context.read<ServiceBloc>().state;
    if (state is ServiceLoaded) {
      try {
        final service = state.services.firstWhere(
          (service) => service.id == widget.serviceId,
          orElse: () => state.services.first,
        );

        if (service.time.isNotEmpty) {
          // Gunakan index untuk mengambil waktu yang dipilih
          final timeIndex =
              _selectedTimeIndex < service.time.length ? _selectedTimeIndex : 0;
          return convert24To12Format(service.time[timeIndex]);
        }
      } catch (e) {
        // Jika terjadi error, gunakan waktu default
      }
    }
    return '08:00 AM'; // Nilai default
  }

  // Setter (fungsi) untuk memperbarui index waktu yang dipilih
  void _updateSelectedTimeIndex(String time12Format) {
    final state = context.read<ServiceBloc>().state;
    if (state is ServiceLoaded) {
      try {
        final service = state.services.firstWhere(
          (service) => service.id == widget.serviceId,
          orElse: () => state.services.first,
        );

        if (service.time.isNotEmpty) {
          // Konversi waktu ke format 24 jam untuk perbandingan
          final time24Format = convert12To24Format(time12Format);

          // Cari index waktu yang cocok
          final index = service.time.indexWhere((t) =>
              convert24To12Format(t) == time12Format || t == time24Format);

          if (index >= 0) {
            setState(() {
              _selectedTimeIndex = index;
            });
            return;
          }
        }
      } catch (e) {
        // Jika error, gunakan index 0
      }
    }

    setState(() {
      _selectedTimeIndex = 0;
    });
  }

  // Fungsi untuk mengkonversi format waktu 24 jam ke 12 jam
  String convert24To12Format(String time24) {
    try {
      final timeParts = time24.split(':');
      if (timeParts.length < 2) {
        return time24; // Jika format tidak valid, kembalikan string asli
      }

      int hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = timeParts[1];
      final period = hour >= 12 ? 'PM' : 'AM';

      // Konversi jam ke format 12 jam
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      return time24; // Jika terjadi error, kembalikan string asli
    }
  }

  // Fungsi untuk mengkonversi format waktu 12 jam ke 24 jam
  String convert12To24Format(String time12) {
    try {
      // Cek jika sudah dalam format 24 jam
      if (!time12.contains('AM') && !time12.contains('PM')) {
        return time12;
      }

      final isPM = time12.contains('PM');
      final timeWithoutPeriod =
          time12.replaceAll(' AM', '').replaceAll(' PM', '');
      final timeParts = timeWithoutPeriod.split(':');

      if (timeParts.length < 2) {
        return time12; // Jika format tidak valid, kembalikan string asli
      }

      int hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = timeParts[1];

      // Konversi jam ke format 24 jam
      if (isPM && hour < 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:$minute';
    } catch (e) {
      return time12; // Jika terjadi error, kembalikan string asli
    }
  }

  // Google Calendar Integration Methods
  Future<void> _handleCalendarSync(Service service, String formattedDate,
      String time24, int bookingId) async {
    try {
      // Show loading dialog for calendar sync
      CalendarSyncLoadingDialog.show(context);

      try {
        // Create calendar event
        final calendarSuccess = await _serviceRepository.createCalendarEvent(
          serviceTitle: service.title,
          serviceDescription: service.description,
          bookingDate: DateTime.parse(formattedDate),
          bookingTime: time24,
          location: selectedOption.toLowerCase() == 'online'
              ? 'Online Meeting'
              : service.location,
          meetingUrl: selectedOption.toLowerCase() == 'online'
              ? 'Meeting URL akan diberikan sebelum appointment'
              : null,
        );

        // Hide loading dialog
        if (mounted) {
          CalendarSyncLoadingDialog.hide(context);

          if (calendarSuccess) {
            CalendarSyncMessages.showSuccess(context);
          } else {
            CalendarSyncMessages.showError(context);
          }
        }
      } catch (calendarError) {
        // Hide loading dialog
        if (mounted) {
          CalendarSyncLoadingDialog.hide(context);

          // Check specific error types
          String errorMessage = 'Gagal sync ke calendar';
          if (calendarError.toString().contains('Permission calendar')) {
            errorMessage =
                calendarError.toString().replaceAll('Exception: ', '');

            // Show dialog for permission settings if permanently denied
            if (calendarError.toString().contains('permanen')) {
              _showPermissionDialog();
              return;
            }
          } else if (calendarError.toString().contains('Authentication')) {
            errorMessage = 'Gagal login ke Google Account. Silakan coba lagi.';
          }

          CalendarSyncMessages.showError(context, errorMessage);
        }
      }
    } catch (e) {
      print('Error in calendar sync: $e');
      if (mounted) {
        CalendarSyncMessages.showError(
            context, 'Terjadi kesalahan saat sync ke calendar');
      }
    }
  }

  // Show permission dialog when calendar permission is permanently denied
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.settings, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permission Diperlukan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi memerlukan akses ke Calendar untuk menambahkan appointment ke Google Calendar.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              'Silakan aktifkan permission Calendar di:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              '• Pengaturan > Apps > Appointly > Permissions > Calendar',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await PermissionService.openDeviceSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    // Dapatkan service dari state saat ini
    final state = context.read<ServiceBloc>().state;
    if (state is ServiceLoaded) {
      final service = state.services.firstWhere(
        (service) => service.id == widget.serviceId,
        orElse: () => state.services.first,
      );

      final DateTime? picked = await showModalBottomSheet<DateTime>(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: GestureDetector(
              onTap: () => Navigator.of(context)
                  .pop(), // Prevents tap from propagating to parent
              child: Container(
                height: MediaQuery.of(context).size.height * 0.70,
                decoration: BoxDecoration(
                  color: Colors.white, // Adding background color
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(24),
                    right: Radius.circular(24),
                  ),
                ),
                child: CustomCalendar(
                  service: service,
                  onDateSelected: (DateTime selected) {
                    setState(() {
                      selectedDate = selected;
                    });
                  },
                ),
              ),
            ),
          );
        },
      );

      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tunggu service sedang dimuat...')),
      );
    }
  }

  Future<void> _refreshData() async {
    context.read<ServiceBloc>().add(GetServiceIdEvent(id: widget.serviceId));
  }

  @override
  void initState() {
    super.initState();
    // Load service data when screen opens
    context.read<ServiceBloc>().add(GetServiceIdEvent(id: widget.serviceId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Stack(
            children: [
              BlocBuilder<ServiceBloc, ServiceState>(
                builder: (context, state) {
                  if (state is ServiceLoading) {
                    return Skeletonizer(
                      enabled: true,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Skeleton for background image
                            Container(
                              height: 300,
                              color: Colors.grey[200],
                            ),
                            // Skeleton for content
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title section skeleton
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 24,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        height: 16,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24),
                                  // Schedule section skeleton
                                  _buildSkeletonScheduleSection(),
                                  SizedBox(height: 16),
                                  // Location section skeleton
                                  _buildSkeletonLocationSection(),
                                  SizedBox(height: 16),
                                  // Note section skeleton
                                  _buildSkeletonNoteSection(),
                                  SizedBox(height: 16),
                                  // Button skeleton
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    color: Colors.grey[200],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is ServiceFailure) {
                    return Center(
                      child: Text(
                        'Error: ${state.failure}',
                      ),
                    );
                  } else if (state is ServiceLoaded) {
                    if (state.services.isEmpty) {
                      return Center(
                        child: Text('Service tidak ditemukan'),
                      );
                    }
                    try {
                      // Cari service dengan ID yang sesuai
                      final service = state.services.firstWhere(
                        (service) => service.id == widget.serviceId,
                        orElse: () => state.services.first,
                      );

                      return RefreshIndicator(
                        onRefresh: _refreshData,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildBackgroundImage(service),
                              _buildContent(service),
                            ],
                          ),
                        ),
                      );
                    } catch (e) {
                      return Center(
                        child: Text('Terjadi kesalahan saat memuat service'),
                      );
                    }
                  }
                  return const Center(child: EmptyStateService());
                },
              ),
              _buildBackButton(),
            ],
          ),
          // _buildContent(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0.0,
      toolbarHeight: 8.0,
    );
  }

  Widget _buildBackgroundImage(Service service) {
    if (service.image.isEmpty) {
      return Container(
        height: 300,
        color: ColorPallete.concrete50,
        child: Center(
          child: Image.asset(
            'assets/image/404page.png',
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (service.image.startsWith('http://') ||
        service.image.startsWith('https://')) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(service.image),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      try {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(service.image),
              fit: BoxFit.cover,
            ),
          ),
        );
      } catch (e) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/service-1.png'),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }
  }

  Widget _buildBackButton() {
    return Positioned(
      left: 12,
      top: 12,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: IconButton(
          onPressed: () {
            context.read<ServiceBloc>().add(GetServiceEvent());
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
      ),
    );
  }

  Widget _buildContent(Service service) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(service),
            SizedBox(height: 24),
            _buildScheduleSection(),
            SizedBox(height: 16),
            _buildLocationSection(service),
            SizedBox(height: 16),
            _buildNoteSection(service),
            SizedBox(height: 16),
            _buildGoogleCalendarSection(),
            SizedBox(height: 16),
            _buildButtonSend()
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(Service service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.title,
          style: GoogleFonts.ubuntu(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ColorPallete.darkBlack,
          ),
        ),
        SizedBox(height: 2.0),
        ExpandedText(
          text: service.description,
          maxLine: 120,
        )
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorPallete.darkBlack,
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: ColorPallete.concrete50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatePicker(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        if (state is ServiceLoaded) {
          // Ambil service dengan ID yang sesuai
          final service = state.services.firstWhere(
            (service) => service.id == widget.serviceId,
            orElse: () => state.services.first,
          );

          // Konversi daftar waktu dari format 24 jam ke 12 jam jika diperlukan
          List<String> timeOptions = service.time.isNotEmpty
              ? service.time.map((time) => convert24To12Format(time)).toList()
              : ['08:00 AM', '09:00 AM', '10:00 AM'];

          // Set nilai default untuk selectedTime jika belum dipilih
          if (timeOptions.isNotEmpty &&
              selectedTime == '08:00 AM' &&
              !timeOptions.contains('08:00 AM')) {
            setState(() {
              _selectedTimeIndex = 0;
            });
          }

          return Row(
            children: [
              Expanded(
                child: _buildPickerButton(
                  onTap: _selectDate,
                  iconPath: 'assets/icons/icon-calendar.svg',
                  text: selectedDate != null
                      ? DateFormat('d MMM yyyy').format(selectedDate!)
                      : 'Select Date',
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: DropdownTime(
                  selectedValue: selectedTime,
                  items: timeOptions,
                  onChanged: (value) {
                    setState(() {
                      _updateSelectedTimeIndex(value!);
                    });
                  },
                ),
              ),
            ],
          );
        }

        // Tampilkan default widget saat loading atau error
        return Row(
          children: [
            Expanded(
              child: _buildPickerButton(
                onTap: _selectDate,
                iconPath: 'assets/icons/icon-calendar.svg',
                text: selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    : 'Select Date',
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: DropdownTime(
                selectedValue: selectedTime,
                items: ['08:00 AM', '09:00 AM', '10:00 AM'],
                onChanged: (value) {
                  setState(() {
                    _updateSelectedTimeIndex(value!);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPickerButton({
    required VoidCallback onTap,
    required String iconPath,
    required String text,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.0,
        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 2, color: ColorPallete.backgroundBody),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, height: 24),
            SizedBox(width: 8.0),
            Text(
              text,
              style: GoogleFonts.ubuntu(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorPallete.darkBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(Service service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorPallete.darkBlack,
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: ColorPallete.concrete50,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedOption = 'Offline';
                        });
                      },
                      child: Container(
                        height: 54.0,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              width: 2, color: ColorPallete.backgroundBody),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<String>(
                              value: service.option.firstWhere(
                                (option) => option.toString() == 'Offline',
                                orElse: () => 'Offline',
                              ),
                              activeColor: ColorPallete.primaryColor,
                              groupValue: selectedOption,
                              visualDensity:
                                  VisualDensity(horizontal: -4, vertical: -4),
                              onChanged: (value) {
                                setState(() {
                                  selectedOption = value ?? 'Offline';
                                });
                              },
                            ),
                            const SizedBox(width: 4.0),
                            SvgPicture.asset('assets/icons/icon-location.svg',
                                height: 24),
                            const SizedBox(width: 8.0),
                            Text(
                              'Offline',
                              style: GoogleFonts.ubuntu(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: ColorPallete.darkBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  // Online Field
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedOption = 'Online';
                        });
                      },
                      child: Container(
                        height: 54.0,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: ColorPallete.backgroundBody,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<String>(
                              value: service.option.firstWhere(
                                (option) => option.toString() == 'Online',
                                orElse: () => 'Online',
                              ),
                              groupValue: selectedOption,
                              activeColor: ColorPallete.primaryColor,
                              visualDensity:
                                  VisualDensity(horizontal: -4, vertical: -4),
                              onChanged: (value) {
                                setState(() {
                                  selectedOption = value ?? 'Online';
                                });
                              },
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Icon(
                              Icons.wifi_tethering_rounded,
                              color: ColorPallete.darkBlack,
                              size: 24,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'Online',
                              style: GoogleFonts.ubuntu(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: ColorPallete.darkBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildNoteSection(Service service) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.notes ?? 'Note',
            style: GoogleFonts.ubuntu(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorPallete.darkBlack,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: ColorPallete.concrete50,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: SizedBox(
              height: 90,
              width: double.infinity,
              child: TextField(
                controller: _noteController,
                cursorColor: ColorPallete.primaryColor,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Optional Notes',
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoogleCalendarSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: ColorPallete.concrete50),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: ColorPallete.primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Google Calendar',
                style: GoogleFonts.ubuntu(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.darkBlack,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Otomatis tambahkan appointment ke Google Calendar dengan reminder',
                  style: GoogleFonts.ubuntu(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorPallete.darkBlack.withOpacity(0.7),
                  ),
                ),
              ),
              Switch(
                value: _enableCalendarSync,
                onChanged: (value) {
                  setState(() {
                    _enableCalendarSync = value;
                  });
                },
                activeColor: ColorPallete.primaryColor,
                activeTrackColor: ColorPallete.primaryColor.withOpacity(0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),
            ],
          ),
          if (_enableCalendarSync) ...[
            SizedBox(height: 8.0),
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: ColorPallete.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                    color: ColorPallete.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ColorPallete.primaryColor,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '• Reminder 30 menit sebelum appointment\n• Reminder 1 jam sebelum appointment\n• Detail lokasi dan catatan akan disertakan',
                      style: GoogleFonts.ubuntu(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: ColorPallete.primaryColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtonSend() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: ColorPallete.gradientPrimary,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: TextButton(
        onPressed: _isBookingInProgress
            ? null
            : () async {
                // 1. First check for notification permissions
                final settings =
                    await FirebaseMessaging.instance.requestPermission();
                if (settings.authorizationStatus !=
                    AuthorizationStatus.authorized) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Please enable notifications to receive booking confirmations'),
                    ),
                  );
                  return;
                }

                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a date'),
                    ),
                  );
                  return;
                }

                // Format selected date
                final formattedDate = selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    : '';

                // Get the time in 24-hour format
                final time24 = convert12To24Format(selectedTime);

                // Get note from controller
                final note = _noteController.text.trim();

                final state = context.read<ServiceBloc>().state;
                if (state is ServiceLoaded) {
                  final service = state.services.firstWhere(
                    (service) => service.id == widget.serviceId,
                    orElse: () => state.services.first,
                  );

                  // Set booking in progress
                  setState(() {
                    _isBookingInProgress = true;
                  });

                  // Book the service first
                  context.read<ServiceBloc>().add(BookService(
                        serviceId: widget.serviceId,
                        option: selectedOption,
                        date: formattedDate,
                        notes: note,
                        time: time24,
                      ));

                  // Listen for the booking response
                  context.read<ServiceBloc>().stream.listen((state) async {
                    if (state is ServiceSucees) {
                      print('🔔 Booking successful! Creating notification...');
                      print(
                          '📝 Booking details: ID=${state.bookingId}, Service=${service.title}');

                      // Set booking no longer in progress
                      if (mounted) {
                        setState(() {
                          _isBookingInProgress = false;
                        });
                      }

                      // Show notification after successful booking
                      NotificationHelper.showBookingNotification(
                        context: context,
                        serviceName: service.title,
                        date: formattedDate,
                        time: selectedTime,
                        option: selectedOption,
                        userId: widget.userId,
                        bookingId: state.bookingId,
                      );

                      // Refresh notifications
                      context.read<NotificationBloc>().add(
                            GetNotifications(userId: widget.userId),
                          );

                      // Handle Google Calendar sync after successful booking (only if enabled)
                      if (mounted && _enableCalendarSync) {
                        await _handleCalendarSync(
                            service, formattedDate, time24, state.bookingId);
                      }

                      // Navigate to success screen after calendar sync (or user declined)
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuccessState(
                              bookingId: state.bookingId,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      }
                    } else if (state is ServiceFailure) {
                      // Set booking no longer in progress
                      if (mounted) {
                        setState(() {
                          _isBookingInProgress = false;
                        });
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking failed: ${state.failure}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
                }
              },
        child: _isBookingInProgress
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Booking...',
                    style: GoogleFonts.ubuntu(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Book Appointment Now',
                style: GoogleFonts.ubuntu(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSkeletonScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 20,
          color: Colors.white,
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorPallete.concrete50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 20,
          color: Colors.white,
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorPallete.concrete50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 20,
          color: Colors.white,
        ),
        SizedBox(height: 8),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
