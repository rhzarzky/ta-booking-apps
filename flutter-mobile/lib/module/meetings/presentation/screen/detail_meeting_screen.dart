// ignore_for_file: depend_on_referenced_packages

import 'package:Appointly/core/theme/color_pallete.dart';
import 'package:Appointly/module/meetings/presentation/bloc/service_bloc.dart';
import 'package:Appointly/module/meetings/presentation/screen/field_location_offline.dart';
import 'package:Appointly/module/meetings/presentation/widget/custom_calendar.dart';
import 'package:Appointly/module/meetings/presentation/widget/dropdown_time.dart';
import 'package:Appointly/module/meetings/presentation/widget/success_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Appointly/module/meetings/model/service_model.dart';
import '';

class DetailMeetingScreen extends StatefulWidget {
  final int serviceId;

  const DetailMeetingScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<DetailMeetingScreen> createState() => _DetailMeetingScreenState();
}

class _DetailMeetingScreenState extends State<DetailMeetingScreen> {
  DateTime? selectedDate;
  // Menyimpan index waktu yang dipilih alih-alih menyimpan string waktu
  int _selectedTimeIndex = 0;

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
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: CustomCalendar(
                service: service,
                onDateSelected: (DateTime selected) {
                  Navigator.of(context).pop(selected);
                },
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
                    return const Center(
                      child: CircularProgressIndicator(),
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
                  return const Center(
                    child: Text('No Data Available'),
                  );
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
        child: Center(child: Text('Tidak ada gambar')),
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
            _buildLocationSection(),
            SizedBox(height: 16),
            _buildNoteSection(),
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
        Text(
          service.description,
          style: GoogleFonts.ubuntu(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ColorPallete.darkGreySilver,
          ),
        ),
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
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
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
                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
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

  Widget _buildLocationSection() {
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
                  // In-Person Field
                  Expanded(
                    child: Container(
                      height: 54.0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 2, color: ColorPallete.backgroundBody),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/icons/icon-location.svg',
                              height: 24),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FieldLocationOffline(),
                                  ),
                                );
                              },
                              child: Text(
                                'In-Person',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: ColorPallete.darkBlack,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  // Online Field
                  Expanded(
                    child: Container(
                      height: 54.0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 8.0,
                      ),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/icons/icon-video.svg',
                              height: 24),
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
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildNoteSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note',
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

  Widget _buildButtonSend() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: ColorPallete.primaryColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextButton(
        child: Text(
          'Book Appointment Now',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () {
          // Dapatkan waktu dalam format 12 jam dari getter
          final String displayTime = selectedTime;

          // Konversi waktu ke format 24 jam untuk dikirim ke server
          final String timeIn24Format = convert12To24Format(displayTime);

          // Log informasi booking (untuk pengembangan)
          print('Booking appointment:');
          print('Date: $selectedDate');
          print('Time (display): $displayTime');
          print('Time (server): $timeIn24Format');

          // Navigasi ke halaman sukses
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessState(),
            ),
          );
        },
      ),
    );
  }
}
