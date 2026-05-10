import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/core/utils/helpers/image_url.dart';
import 'package:progress_group/core/utils/helpers/initial_name_helper.dart';
import 'package:progress_group/features/attandance/domain/entities/attandance_entity.dart';
import 'package:progress_group/features/attandance/presentation/state/attandance/attendance_bloc.dart';
import 'package:progress_group/features/attandance/presentation/state/attandance/attendance_event.dart';
import 'package:progress_group/features/attandance/presentation/state/attandance/attendance_state.dart';
import 'package:progress_group/features/auth/presentation/state/profile/profile_bloc.dart';
import 'package:progress_group/features/auth/presentation/state/profile/profile_event.dart';
import 'package:progress_group/features/auth/presentation/state/profile/profile_state.dart';
import '../../../../../core/utils/helpers/date_helper.dart';
import '../../../../../core/utils/widget/custom_header.dart';
import '../../../data/arguments/attandance_args.dart';

class AttandancePage extends StatefulWidget {
  const AttandancePage({super.key});

  @override
  State<AttandancePage> createState() => _AttandancePageState();
}

class _AttandancePageState extends State<AttandancePage> {
  late PageController _pageController;
  final double officeLat =  -6.1416575;
  final double officeLng = 106.8659419;
  final double radiusMeter = 1050;

  StreamSubscription<Position>? _positionStream;
  
  int selectedIndex = 0;
  String selectedMenu ='activity';
  String? _address;
  bool _isProcessing = false;
  DateTime? _lastGeocodeTime;


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.microtask(() {
      _initLocation();
      _getLog();
      context.read<ProfileBloc>().add(GetProfileEvent());

    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => selectedIndex = index);

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // cek GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS belum aktif'),
        ),
      );
      return false;
    }

    // cek permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi ditolak'),
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi ditolak permanen, buka settings'),
        ),
      );

      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  Future<void> _initLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) async {

      if (_isProcessing) return;
      _isProcessing = true;

      try {
        Geolocator.distanceBetween(
          officeLat,
          officeLng,
          position.latitude,
          position.longitude,
        );

        if (!mounted) return;

        setState(() {
          // update state seperlunya
        });

        // ⛔ batasi geocoding
        if (_lastGeocodeTime == null ||
            DateTime.now().difference(_lastGeocodeTime!) > const Duration(seconds: 10)) {

          _lastGeocodeTime = DateTime.now();
          await _getAddressFromLatLng(position);
        }

      } catch (e) {
        print('ERROR LOCATION: $e');
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;

      setState(() {
        _address =
            "${place.street}, ${place.subLocality}, ${place.locality}, "
            "${place.subAdministrativeArea}, ${place.administrativeArea}";
      });
    } catch (e) {
      setState(() {
        _address = "Alamat tidak ditemukan";
      });
    }
  }

  Future<Position?> _getCurrentLocationOnce() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleMoveCamera(String title, int flagParam)async{
     final position = await _getCurrentLocationOnce();

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lokasi belum terdeteksi"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final distance = Geolocator.distanceBetween(
      officeLat,
      officeLng,
      position.latitude,
      position.longitude,
    );

    final isInRadius = distance <= radiusMeter;

    if (!isInRadius) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Kamu di luar area kantor\n"
            "Jarak: ${distance.toStringAsFixed(0)} meter\n"
            "Radius: $radiusMeter meter\n"
            "Lokasi: ${_address ?? 'unknown'}",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.pushNamed(
      'camera',
      extra: AttandanceArgs(
        flag: flagParam,
        type: title,
        location:_address,
        time: DateHelper.formatTime(DateTime.now()),
      ),
    );
  }

  Future<void> _getLog() async {
    context.read<AttendanceBloc>().add(GetAttendanceEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            customHeader(context,'Attendance', colorBg: Color(primaryColor),colorBack: Color(whiteColor),colorTitle: Color(whiteColor), iconRight: Icons.arrow_back, iconRightOnTap: (){ context.go('/');}, colorIconRight: Color(whiteColor)),
            SizedBox(
              height: 260,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildHeaderProfile(),
                  _buildFloatingCard(),
                ],
              ),
            ),
            SizedBox(height: 30,),
            _buildButtonLog(),
            if(selectedMenu == 'activity')_buildActivityLog(),
            if(selectedMenu == 'attendance')_buildAttendanceLog(),

          ],
        ),
      ),
    );
  }

  Widget _buildButtonLog(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: 300,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
        // MY ACTIVITY
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMenu = 'activity';
                  });
                },
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: selectedMenu == 'activity'
                        ? Colors.blue
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'My Activity',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selectedMenu == 'activity'
                          ? Colors.white
                          : Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ATTENDANCE LOG
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMenu = 'attendance';
                  });
                },
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: selectedMenu == 'attendance'
                        ? Colors.blue
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Attendance Log',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selectedMenu == 'attendance'
                          ? Colors.white
                          : Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
        
        
            
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceLog() {
    return Expanded(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(whiteColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Attendance Log", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),

            Expanded(
              child: BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, state) {

                  if (state is AttendanceLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (state is AttendanceLoaded) {
                    final data = state.data;

                    return RefreshIndicator(
                      onRefresh: _getLog,
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (_, i) => _buildCardAttendance(data[i]),
                      ),
                    );
                  }

                  if (state is AttendanceError) {
                    return Center(child: Text(state.message));
                  }

                  return SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLog() {
    return Expanded(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(whiteColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),

            Expanded(
              child: BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, state) {

                  if (state is AttendanceLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (state is AttendanceLoaded) {
                      final data = state.data.where((e) =>e.checkInActivity != null &&e.checkInActivity!.toString().trim().isNotEmpty).toList();
                    return RefreshIndicator(
                      onRefresh: _getLog,
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (_, i) => _buildCardAktivity(data[i]),
                      ),
                    );
                  }

                  if (state is AttendanceError) {
                    return Center(child: Text(state.message));
                  }

                  return SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAttendance(AttendanceEntity item) {
    final date = DateTime.parse(item.date);

    String formatTime(String? value) {
      if (value == null) return "-";
      final dt = DateTime.parse(value);
      return DateFormat('hh:mm a').format(dt);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Container(
          color: Colors.transparent,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            
            /// DATE
            Container(
              width: 70,
              height: 40,
              decoration: BoxDecoration(
                color: Color(grey9Color),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${date.day}", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(DateFormat('EEE').format(date)),
                ],
              ),
            ),

            /// CLOCK IN
            GestureDetector(
              onTap: item.clockIn != null? () => _showAttendanceDialog(item, 0): null,
              child: Container(
                width: 100,
                child: Column(
                  children: [
                    Icon(Icons.access_time_filled,size: 17, color: Color(greenPercentColor)),
                    Text(formatTime(item.clockIn)),
                  ],
                ),
              ),
            ),

            Container(width: 2, height: 40, color: Color(grey9Color)),

            /// CLOCK OUT
            GestureDetector(
              onTap: item.clockOut != null? () => _showAttendanceDialog(item, 1): null,
              child: Container(
                width: 100,
                child: Column(
                  children: [
                    Icon(Icons.access_time_filled,size: 17, color: Color(redPeriodColor)),
                    Text(formatTime(item.clockOut)),
                  ],
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }


Widget _buildProfileName(bool img) {
   return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const SizedBox();
        }

        final user = state.profile;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           if(!img)
            Container(
              width: 100,
              child: Text(
                user.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if(img)
            Container(
              width: 30,
              height: 30,
              
              decoration: BoxDecoration(
                color: Color(primaryColor),
                shape: BoxShape.circle
              ),
              child: Center(
                child: Text(
                  getInitials(user.fullName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(whiteColor)
                  ),
                ),
              ),
            ),
           
          ],
        );
      },
    );
  }

Widget _buildCardAktivity(AttendanceEntity item) {
  final images = item.fileAttchment6 ?? [];

  return StatefulBuilder(
    builder: (context, setStateSB) {
      final ScrollController scrollController = ScrollController();

      bool isAtStart = true;
      bool isAtEnd = false;

      void updateScrollState() {
        if (!scrollController.hasClients) return;

        final maxScroll = scrollController.position.maxScrollExtent;
        final offset = scrollController.offset;

        setStateSB(() {
          isAtStart = offset <= 0;
          isAtEnd = offset >= maxScroll;
        });
      }

      scrollController.addListener(updateScrollState);

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(whiteColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Color(purpleColor),
                    width: 5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildProfileName(true),
                      SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileName(false),
                          Text(item.location6 ?? '', style: TextStyle(fontSize: 11),),
                        ],
                      ),
                    ],
                  ),
                  
                 Text(item.checkInActivity != null && item.checkInActivity!.isNotEmpty? DateFormat('dd/MM/yyyy').format(DateTime.parse(item.checkInActivity!)): '-',style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              item.note6 ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            /// ================= IMAGES =================
            if (images.isNotEmpty)
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              convertDriveUrl(images[index]),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    /// ================= LEFT ARROW =================
                    if (images.length > 1 && !isAtStart)
                      Positioned(
                        left: 5,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              final newOffset =
                                  (scrollController.offset - 250).clamp(
                                0.0,
                                scrollController.position.maxScrollExtent,
                              );

                              scrollController.animateTo(
                                newOffset,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    /// ================= RIGHT ARROW =================
                    if (images.length > 1 && !isAtEnd)
                      Positioned(
                        right: 5,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              final newOffset =
                                  (scrollController.offset + 250).clamp(
                                0.0,
                                scrollController.position.maxScrollExtent,
                              );

                              scrollController.animateTo(
                                newOffset,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
           
          ],
        ),
      );
    },
  );
}

  Widget _buildHeaderProfile() {
    return Container(
      height: 160,
      color: Color(primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCard() {
    return Positioned(
      top: 0,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Color(whiteColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            AttendanceEntity? today;
            if (state is AttendanceLoaded && state.data.isNotEmpty) {
              final now = DateTime.now();
              final todayStr = DateFormat('yyyy-MM-dd').format(now);
              try {
                today = state.data.firstWhere((e) => e.date == todayStr);
              } catch (_) {
                // Not found
              }
            }
            return Column(
              children: [
                _buildTabBar(),
                const SizedBox(height: 5),
                _buildPageView(today),
              ],
            );
          },
        ),
      ),
    );
  }



  Widget _buildTabBar() {
    const double height = 45;
    final tabs = ["Clock In", "Check In", "Clock Out"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 2.6;

            final page = _pageController.hasClients? (_pageController.page ?? 0): selectedIndex.toDouble();

            List<int> order = [0, 1, 2];
            order.sort((a, b) {
              return (b - page).abs().compareTo((a - page).abs());
            });

            return Stack(
              children: order.map((index) {
                return _buildStackTab(
                  index: index,
                  left: index * (tabWidth - 25),
                  tabWidth: tabWidth,
                  height: height,
                  tabs: tabs,
                  page: page,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }


  Widget _buildStackTab({required int index,required double left,required double tabWidth,required double height,required List<String> tabs,required double page,}) {
    final isActive = (page - index).abs() < 0.5;

    return Positioned(
      left: left,
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: tabWidth,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive? Color(primaryColor): Colors.transparent,
           borderRadius: BorderRadius.circular(height / 2),
            boxShadow: isActive ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ] : [],
          ),
          child: Text(
            tabs[index],
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildPageView(AttendanceEntity? today) {
    return SizedBox(
      height: 190,
      child: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => selectedIndex = index);
        },
        children: [
          _buildClockIn(today),
          _buildCheckInActivity(today),
          _buildClockOut(today),
        ],
      ),
    );
  }


  Widget _buildCheckInActivity(AttendanceEntity? today) {
    return _buildCheckForm(
      title: "Check In",
      flagParam: 6,
      image: (today?.fileAttchment6 != null && today!.fileAttchment6!.isNotEmpty)? today.fileAttchment6!.first: null,
      attendance: today,
    );
  }

  Widget _buildCheckForm({required String title, required int flagParam, String? image,AttendanceEntity? attendance}) {
  return Expanded(
    child: image != null && flagParam != 6
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal:70, vertical: 5),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(convertDriveUrl(image), width: 200, height: 200, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 200, height: 200, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, size: 40))),
                ),
                Positioned.fill(
                  top: 123,
                  bottom: 0,
                  child: Container(
                    height: 20,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Color(blue2Color).withOpacity(0.5),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_filled, color:flagParam == 0? Color(greenPercentColor): Color(redPeriodColor), size: 10),
                            SizedBox(width: 10),
                            Text("${flagParam == 0? attendance?.clockIn :attendance?.clockOut}" , style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_sharp, color: Color(primaryColor), size: 10),
                            SizedBox(width: 10),
                            Text(DateHelper.formatDayDate(DateTime.now()), style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Color(primaryColor), size: 10),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: Text("${flagParam == 0? attendance?.location0 :attendance?.location1}", style: TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateHelper.formatTime(DateTime.now()), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text(DateHelper.formatDayDate(DateTime.now()), style: TextStyle(fontSize: 11, color: Color(grey6Color))),
              SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () async { _handleMoveCamera(title, flagParam); },
                  child: Container(
                    height: 90,
                    width: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Color(primaryColor).withOpacity(0.1)),
                    child: Container(
                      height: 80,
                      width: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Color(primaryColor).withOpacity(0.2)),
                      child: Container(
                        height: 70,
                        width: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Color(primaryColor)),
                        child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(whiteColor))),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text("Please $title!", style: TextStyle(fontSize: 12, color: Color(grey6Color))),
            ],
          ),
  );
}  

Widget _buildClockOut(AttendanceEntity? today) {
    return _buildCheckForm(
      title: "Clock Out",
      flagParam: 1,
      image: (today?.fileAttchment1 != null && today!.fileAttchment1!.isNotEmpty)
          ? today.fileAttchment1!.last
          : null,
      attendance: today,  
    );
  }

  Widget _buildClockIn(AttendanceEntity? today) {
    return _buildCheckForm(
      title: "Clock In",
      flagParam: 0,
      image: (today?.fileAttchment0 != null && today!.fileAttchment0!.isNotEmpty)
          ? today.fileAttchment0!.first
          : null,
      attendance: today,
    );
  }


    
  void _showAttendanceDialog(AttendanceEntity item, int flag) {
    final String timeValue = flag == 0 ? item.clockIn ?? "-" : item.clockOut ?? "-";
    final List<String>? images =flag == 0 ? item.fileAttchment0 : item.fileAttchment1;
    final String note = flag == 0 ? item.note0 ?? "-" : item.note1 ?? "-";
    final String location =flag == 0 ? item.location0 ?? "-" : item.location1 ?? "-";

    String formatTime(String? value) {
      if (value == null || value == "-") return "-";
      final dt = DateTime.parse(value);
      return DateFormat('hh:mm a').format(dt);
    }

    final String displayTime = formatTime(timeValue);
    final String? displayImage =
        (images != null && images.isNotEmpty) 
            ? (flag == 0 ? images.first : images.last) 
            : null;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: displayImage != null
                        ? Image.network(
                            convertDriveUrl(displayImage),
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 180,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 50),
                            ),
                          )
                        : Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, size: 50),
                          ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.access_time_filled,
                    displayTime,
                    Color(flag == 0 ? greenPercentColor : redPeriodColor),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today,
                    DateHelper.formatDayDate(DateTime.parse(item.date)),
                    Color(primaryColor),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.map,
                    location,
                    Color(primaryColor),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.notes,
                    note,
                    Color(primaryColor),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}