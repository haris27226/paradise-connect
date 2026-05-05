import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:progress_group/core/utils/helpers/date_helper.dart';
import 'package:progress_group/core/utils/widget/custom_button.dart';
import 'package:progress_group/features/attandance/data/arguments/attandance_args.dart';
import 'package:progress_group/features/attandance/presentation/state/attandance/attendance_bloc.dart';
import 'package:progress_group/features/attandance/presentation/state/attandance/attendance_event.dart';
import 'package:progress_group/features/attandance/presentation/state/attandance/attendance_state.dart';
import 'package:progress_group/features/contact/data/arguments/contact_dropdown_args.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/utils/widget/custom_header.dart';

class CameraPage extends StatefulWidget {
  final AttandanceArgs args;

  const CameraPage({super.key, required this.args});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  TextEditingController notesTC = TextEditingController();
  TextEditingController pameranTC = TextEditingController();
  FocusNode notesFN = FocusNode();
  FocusNode pameranFN = FocusNode();
  CameraController? _controller;
  XFile? _imageFile;
  int _cameraIndex = 0;
  bool get _isCameraReady => _controller != null && _controller!.value.isInitialized;
  List<CameraDescription>? _cameras;
  bool _isSwitching = false;
  int? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    _initCamera();
    context.read<AttendanceBloc>().add(GetLocationsEvent());
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Camera not found on this device")),
          );
        }
        return;
      }

      _controller = CameraController(
        _cameras![_cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint("ERROR CAMERA: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to open camera: $e")),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      final file = await _controller!.takePicture();
      setState(() {
        _imageFile = file;
      });
    } catch (e) {
      debugPrint("ERROR TAKE PICTURE: $e");
    }
  }

  // Future<void> _switchCamera() async {
  //   if (_cameras == null || _cameras!.isEmpty) return;

  //   setState(() => _isSwitching = true);

  //   _cameraIndex = (_cameraIndex + 1) % _cameras!.length;

  //   await _controller?.dispose();

  //   _controller = CameraController(
  //     _cameras![_cameraIndex],
  //     ResolutionPreset.medium,
  //     enableAudio: false,
  //   );

  //   await _controller!.initialize();

  //   if (!mounted) return;

  //   setState(() => _isSwitching = false);
  // }

  void _handleSubmit() {
    if (_imageFile == null) return;

    final flag = widget.args.flag;

    final datetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final location = pameranTC.text.isNotEmpty ? pameranTC.text : (widget.args.location ?? "Unknown");

    context.read<AttendanceBloc>().add(SubmitAttendanceEvent(datetime: datetime,flag: flag!,location: location,note: notesTC.text,filePath: _imageFile!.path,));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSubmitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Attendance recorded successfully!")),
          );
          context.pop();
          // Refresh logs on home page
          context.read<AttendanceBloc>().add(GetAttendanceEvent());
        } else if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              customHeader(
                context,
                widget.args.type ?? "-",
                colorBg: Color(primaryColor),
                colorBack: Color(whiteColor),
                colorTitle: Color(whiteColor),
                isBack: true,
                iconLeft: _imageFile != null ? Icons.history : null,
                iconLeftOnTap: () {
                  setState(() {
                    _imageFile = null;
                  });
                },
                colorIconLeft: Color(whiteColor),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isCameraReady || _isSwitching) {
      return Center(child: CircularProgressIndicator());
    }
    if (_imageFile != null) {
      return _buildPreview();
    }
    return _buildCameraView();
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
        ),
        _buildBottomOverlay(),
      ],
    );
  }

  Widget _buildBottomOverlay() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            widget.args.location ?? "",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            widget.args.time ?? "",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          _buildCaptureButton(),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _takePicture,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(primaryColor),
              ),
              child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 330,
                width: double.infinity,
                child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Color(blue2Color).withOpacity(0.5),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_filled, color: Color(greenPercentColor), size: 25),
                          SizedBox(width: 10),
                          Text(widget.args.time ?? "-", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_sharp, color: Color(primaryColor), size: 25),
                          SizedBox(width: 10),
                          Text(
                            DateHelper.formatDayDate(DateTime.now()),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Color(primaryColor), size: 25),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 250,
                            child: Text(
                              widget.args.location ?? "-",
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text("Pameran/ Open Table (optional)", style: TextStyle(fontSize: 14, color: Color(grey2Color))),
                SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(grey4Color), width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final state = context.read<AttendanceBloc>().state;
                      if (state is AttendanceLoaded && state.locations != null) {
                        final items = state.locations!.map((e) => OwnerDropdownItem(
                          id: e.id,
                          name: e.name,
                        )).toList();

                        final result = await context.pushNamed(
                          'detailContactDropdown',
                          extra: ContactDropdownArgs(
                            title: 'Select Pameran',
                            items: items,
                            selectedId: _selectedLocationId,
                            isMultiSelect: false,
                          ),
                        );

                        if (result != null) {
                          final selected = result as OwnerDropdownItem;
                          setState(() {
                            _selectedLocationId = selected.id;
                            pameranTC.text = selected.name;
                          });
                        }
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            enabled: false,
                            maxLines: 1,
                            minLines: 1,
                            controller: pameranTC,
                            decoration: InputDecoration(
                              hintText: "Select Pameran",
                              hintStyle: TextStyle(color: Color(grey2Color), fontSize: 14),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_up),
                        SizedBox(width: 5)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Notes", style: TextStyle(fontSize: 14, color: Color(grey2Color))),
                SizedBox(height: 5),
                Container(
                  height: 80,
                  child: TextFormField(
                    maxLines: null,
                    minLines: 3,
                    controller: notesTC,
                    focusNode: notesFN,
                    onTapOutside: (event) => notesFN.unfocus(),
                    decoration: InputDecoration(
                      hintText: "Enter notes...",
                      hintStyle: TextStyle(fontSize: 14, color: Color(grey3Color)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(grey4Color)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(grey4Color)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(primaryColor)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, state) {
                    if (state is AttendanceSubmitLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return customButton(_handleSubmit, "Submit");
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
