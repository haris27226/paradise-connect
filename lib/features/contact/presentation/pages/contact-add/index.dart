import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:progress_group/core/constants/assets.dart';
import 'package:progress_group/core/utils/widget/custom_button.dart';
import 'package:progress_group/features/contact/data/arguments/contact_dropdown_args.dart';
import 'package:progress_group/features/contact/domain/entities/activity/create_activity_params.dart';
import 'package:progress_group/features/contact/domain/entities/prospect/prospect_status.dart';
import 'package:progress_group/features/contact/presentation/pages/contact-detail/index.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_event.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_state.dart';
import 'package:progress_group/features/contact/presentation/state/attachment_type/attachment_type_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/attachment_type/attachment_type_event.dart';
import 'package:progress_group/features/contact/presentation/state/attachment_type/attachment_type_state.dart';
import 'package:progress_group/features/contact/presentation/state/attachment/upload_attachment_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/attachment/upload_attachment_event.dart';
import 'package:progress_group/features/contact/presentation/state/attachment/upload_attachment_state.dart';
import 'package:progress_group/features/contact/domain/entities/attachment/upload_attachment_params.dart';
import 'package:progress_group/features/contact/presentation/state/prospect_status/prospect_status_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/prospect_status/prospect_status_event.dart';
import 'package:progress_group/features/contact/presentation/state/prospect_status/prospect_status_state.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/utils/helpers/date_helper.dart';
import '../../../../../core/utils/widget/custom_header.dart';
import '../../../data/arguments/contact_detail_args.dart';


class ContactAddPage extends StatefulWidget {
  final ContactDetailArgs args;
  const ContactAddPage({super.key, required this.args});

  @override
  State<ContactAddPage> createState() => _ContactAddPageState();
}

class _ContactAddPageState extends State<ContactAddPage> {
  TextEditingController descTC = TextEditingController();
  FocusNode descFN = FocusNode();

  bool isFollowUp = false;
  DateTime? selectedDate;

  File? selectedImage;

  final ImagePicker picker = ImagePicker();
  String? existingImageUrl;
  String selectedTypeName = "Select type";
  String selectedStatusName = "Select status";

  int? selectedTypeId;
  int? selectedStatusId;
  int jmlDatang = 1;

  File? selectedFile;
  String? selectedFileName;
  bool isPdf = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

 void _init() async {
    if (widget.args.page == 6 && widget.args.dataAttachment != null) {
      final data = widget.args.dataAttachment!;

      setState(() {
        selectedTypeId = data.attachmentTypeId;
        selectedTypeName = data.attachmentTypeName; 
        descTC.text = data.attachmentNote; 
        existingImageUrl = data.attachmentUrl; 
      });
    }

    context.read<AttachmentTypeBloc>().add(FetchAttachmentTypesEvent());
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      setState(() {
        selectedFile = file;
        selectedFileName = result.files.single.name;
        isPdf = selectedFileName!.toLowerCase().endsWith('.pdf');
      });
    }
  }

  Future<void> pickDateTime(BuildContext context) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate ?? now),
    );

    if (time == null) return;

    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submitActivity({
    required String activityType,
    required DateTime activityDate,
    required TextEditingController notesTC,
    required bool isFollowUp,
    required DateTime? followUpDate,
  }) {
    final contactId = widget.args.dataContact?.contactId;
    if (contactId == null) return;

    String mappedType = activityType;
    String finalNotes = notesTC.text.trim();
    
    // Map unsupported types to 'Other' to avoid DB truncation error
    if (!['Call', 'Meeting', 'Visit', 'Email', 'Other'].contains(activityType)) {
      mappedType = 'Other';
      finalNotes = '[$activityType] $finalNotes'.trim();
    }

    final params = CreateActivityParams(
      contactId: contactId,
      dealId: null,
      activityType: mappedType,
      activityDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(activityDate),
      notes: finalNotes.isEmpty ? null : finalNotes,
      nextFollowUpDate: isFollowUp && followUpDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(followUpDate)
          : null,
    );

    context.read<ActivityBloc>().add(CreateActivityEvent(params));
  }

  void _submitAttachment() {
    final contactId = widget.args.dataContact?.contactId;
    if (contactId == null) return;

    final isEdit = widget.args.page == 6;

    if (selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tipe attachment')),
      );
      return;
    }

    if (!isEdit && selectedImage == null && selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih file')),
      );
      return;
    }
    final fileToUpload = selectedFile ?? selectedImage;
    final params = UploadAttachmentParams(
      contactId: contactId,
      attachmentTypeId: selectedTypeId!,
      attachmentNote: descTC.text.isEmpty ? null : descTC.text,
      file: fileToUpload, 
    );

    context.read<UploadAttachmentBloc>().add(
      SubmitAttachmentEvent(
        params: params,
        attachmentId: isEdit? widget.args.dataAttachment?.contactAttachmentId: null,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ActivityBloc, ActivityState>(
          listener: (context, state) {
            if (state.status == ActivityStatus.createSuccess) {
              final contactId = widget.args.dataContact?.contactId;
              if (contactId != null) {
                context.read<ActivityBloc>().add(
                  FetchActivitiesEvent(contactId: contactId, isRefresh: true),
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Activity berhasil ditambahkan'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state.status == ActivityStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Gagal menambahkan activity'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<UploadAttachmentBloc, UploadAttachmentState>(
          listener: (context, state) {
            if (state is UploadAttachmentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attachment berhasil diupload'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state is UploadAttachmentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child:BlocBuilder<UploadAttachmentBloc, UploadAttachmentState>(
            builder: (context, state) {
              final isLoading = state is UploadAttachmentLoading;
              return Stack(
                children: [
                  Column(
                    children: [
                      customHeader(
                        context,
                        widget.args.page == 0
                            ? "Call"
                            : widget.args.page == 1
                            ? "WhatsApp"
                            : widget.args.page == 2
                            ? "Meeting"
                            : widget.args.page == 3
                            ? "Task"
                            : widget.args.page == 4
                            ? "Visit"
                            : "Attachment",
                        isBack: true,
                        colorBack: Color(primaryColor),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              widget.args.page == 5 || widget.args.page == 6 ? _buildAttachment() :widget.args.page == 4 ? _buildVisit(): _buildForm(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildVisit(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Color(whiteColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: pickFile,
            child: Container(
              width: double.infinity,
              height: 130,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(grey10Color),
                border: Border.all(color: Color(grey11Color)),
              ),
              child:
              selectedFile != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isPdf
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
                          SizedBox(height: 8),
                          Text(
                            selectedFileName ?? "PDF File",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                      : selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            selectedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )

                        // 🔥 PRIORITAS 2: IMAGE DARI API
                        : existingImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  convertDriveUrl(existingImageUrl!),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(child: Icon(Icons.broken_image));
                                  },
                                ),
                              )

                    // 🔥 DEFAULT (UPLOAD)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(whiteColor),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(primaryColor)),
                  ),
                  child: Image.asset(icUpload, height: 24, width: 24),
                ),
                SizedBox(height: 8),
                Text(
                  "Upload Files",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(blue2Color),
                  ),
                ),
              ],
            ),
            ): Container())
          ),
          SizedBox(height: 12),
          Text(
            "Status Prospect",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(grey2Color),
            ),
          ),
          SizedBox(height: 6),
          GestureDetector(
            onTap: ()async {
              final statusState = context.read<ProspectStatusBloc>().state;
              if (statusState.status == ProspectStatusEnum.loaded) {
                final statusItems = statusState.statuses .map((e) => OwnerDropdownItem(id: e.statusProspectId,name: e.statusProspectName)).toList();

                final result = await context.pushNamed('detailContactDropdown',extra: ContactDropdownArgs(title: 'Pilih Status',items: statusItems,selectedId: selectedStatusId,),);

                if (result != null) {
                  final selected = result as OwnerDropdownItem;
                  final picked = statusState.statuses.cast<ProspectStatus?>().firstWhere((e) => e?.statusProspectId == selected.id,orElse: () => null,);
                  if (picked != null) {
                    setState(() {
                      selectedStatusId = picked.statusProspectId;
                      selectedStatusName = picked.statusProspectName;
                    });
                  }
                }
              } else {
                context.read<ProspectStatusBloc>().add(
                  FetchProspectStatusesEvent(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Memuat daftar status...'),
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Color(grey4Color)),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedStatusName,
                    style: TextStyle(
                      fontSize: 14, 
                      color: selectedStatusName == "Select status" 
                          ? Color(grey2Color) 
                          : Colors.black
                    ),
                  ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(grey2Color),
                      size: 30,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Tanggal Visit",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(grey2Color),
            ),
          ),
          SizedBox(height: 6),
          GestureDetector(
            onTap: () => pickDateTime(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(grey11Color)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? DateHelper.formatFull(selectedDate!)
                        : DateHelper.nowFull(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(blackColor),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Color(primaryColor),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Jumlah Kedatangan",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(grey2Color),
            ),
          ),
          SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Color(grey4Color)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${jmlDatang}",
                  style: TextStyle(
                    fontSize: 14, 
                    color:  Colors.black
                  ),
                ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(grey2Color),
                    size: 30,
                  ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Note",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(grey2Color),
            ),
          ),
          SizedBox(height: 6),
          TextField(
            maxLines: 4,
            minLines: 3,
            controller: descTC,
            focusNode: descFN,
            onTapOutside: (event) => descFN.unfocus(),
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: "Note the attachment...",
              hintStyle: TextStyle(color: Color(grey2Color).withOpacity(0.0), fontSize: 14),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(grey11Color)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(grey11Color)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(primaryColor)),
              ),
            ),
          ),
          SizedBox(height: 20),
          BlocBuilder<UploadAttachmentBloc, UploadAttachmentState>(
            builder: (context, state) {
              final isLoading = state is UploadAttachmentLoading;
              return customButton(isLoading ? null : () {
                _submitAttachment();
              }, isLoading ? 'Uploading...' : 'Save');
            },
          ),
        ],
      ),
    );
  }



  Widget _buildAttachment() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Color(whiteColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: pickFile,
            child: Container(
              width: double.infinity,
              height: 130,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(grey10Color),
                border: Border.all(color: Color(grey11Color)),
              ),
              child:
              selectedFile != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isPdf
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
                          SizedBox(height: 8),
                          Text(
                            selectedFileName ?? "PDF File",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                      : selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            selectedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )

                        // 🔥 PRIORITAS 2: IMAGE DARI API
                        : existingImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  convertDriveUrl(existingImageUrl!),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(child: Icon(Icons.broken_image));
                                  },
                                ),
                              )

                    // 🔥 DEFAULT (UPLOAD)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(whiteColor),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(primaryColor)),
                  ),
                  child: Image.asset(icUpload, height: 24, width: 24),
                ),
                SizedBox(height: 8),
                Text(
                  "Upload Files",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(blue2Color),
                  ),
                ),
              ],
            ),
            ):Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(whiteColor),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(primaryColor)),
                  ),
                  child: Image.asset(icUpload, height: 24, width: 24),
                ),
                SizedBox(height: 8),
                Text(
                  "Upload Files",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(blue2Color),
                  ),
                ),
              ],
            ),
            )
          ),
          
          SizedBox(height: 12),
          Text(
            "Attachment Type",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(grey2Color),
            ),
          ),
          SizedBox(height: 6),
          BlocBuilder<AttachmentTypeBloc, AttachmentTypeState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () async {
                  if (state is AttachmentTypeLoaded) {
                    final items = state.data.map((e) => OwnerDropdownItem(
                      id: e.id,
                      name: e.name,
                    )).toList();

                    final result = await context.pushNamed(
                      'detailContactDropdown', 
                      extra: ContactDropdownArgs(
                        title: 'Attachment Type',
                        items: items,
                        selectedId: selectedTypeId,
                      ),
                    );

                    if (result != null) {
                      final sel = result as OwnerDropdownItem;
                      setState(() {
                        selectedTypeId = sel.id;
                        selectedTypeName = sel.name;
                      });
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Memuat attachment types...')),
                    );
                    context.read<AttachmentTypeBloc>().add(FetchAttachmentTypesEvent());
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(grey4Color)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTypeName,
                        style: TextStyle(
                          fontSize: 14, 
                          color: selectedTypeName == "Select type" 
                              ? Color(grey2Color) 
                              : Colors.black
                        ),
                      ),
                      if (state is AttachmentTypeLoading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(grey2Color),
                          size: 30,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 12),
          Text(
            "Description",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(grey2Color),
            ),
          ),
          SizedBox(height: 6),
          TextField(
            maxLines: 4,
            minLines: 3,
            controller: descTC,
            focusNode: descFN,
            onTapOutside: (event) => descFN.unfocus(),
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: "Describe the attachment...",
              hintStyle: TextStyle(color: Color(grey2Color), fontSize: 14),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(grey11Color)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(grey11Color)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(primaryColor)),
              ),
            ),
          ),
          SizedBox(height: 20),
          BlocBuilder<UploadAttachmentBloc, UploadAttachmentState>(
            builder: (context, state) {
              final isLoading = state is UploadAttachmentLoading;
              return customButton(isLoading ? null : () {
                _submitAttachment();
              }, isLoading ? 'Uploading...' : 'Save');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Color(whiteColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
             widget.args.page == 0
                    ? "Call"
                    : widget.args.page == 1
                    ? "WhatsApp"
                    : widget.args.page == 2
                    ? "Meeting"
                    : widget.args.page == 3
                    ? "Task"
                    : widget.args.page == 4
                    ? "Visit"
                    : "Attachment",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(grey2Color),
            ),
          ),
          SizedBox(height: 6),
          TextField(
            maxLines: 4,
            minLines: 3,
            controller: descTC,
            focusNode: descFN,
            onTapOutside: (event) => descFN.unfocus(),
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: "Describe the ${ widget.args.page == 0
                    ? "Call"
                    : widget.args.page == 1
                    ? "WhatsApp"
                    : widget.args.page == 2
                    ? "Meeting"
                    : widget.args.page == 3
                    ? "Task"
                    : widget.args.page == 4
                    ? "Visit"
                    : "Attachment"}...",
              hintStyle: TextStyle(color: Color(grey2Color), fontSize: 14),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(grey11Color)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(grey11Color)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(primaryColor)),
              ),
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(grey11Color)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateHelper.nowFull(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(grey2Color),
                  ),
                ),
                Icon(Icons.calendar_today, color: Color(grey2Color), size: 16),
              ],
            ),
          ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Follow Up Task",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(grey2Color),
                    ),
                  ),
                  SizedBox(width: 12),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: isFollowUp,
                      activeTrackColor: Color(primaryColor),
                      onChanged: (value) {
                        setState(() {
                          isFollowUp = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (isFollowUp) ...[
                SizedBox(height: 5),
                Text(
                  "Follow Up In",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(grey2Color),
                  ),
                ),
                SizedBox(height: 6),
                GestureDetector(
                  onTap: () => pickDateTime(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(grey11Color)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate != null
                              ? DateHelper.formatFull(selectedDate!)
                              : DateHelper.nowFull(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(blackColor),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: Color(primaryColor),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 32),
              BlocBuilder<ActivityBloc, ActivityState>(
                builder: (context, state) {
                  final isLoading = state.status == ActivityStatus.creating;
                  
                  return customButton(
                    isLoading ? null : () {
                      _submitActivity(
                        activityType: widget.args.namePage??'',
                        activityDate: DateTime.now(),
                        notesTC: descTC,
                        isFollowUp: isFollowUp,
                        followUpDate: selectedDate,
                      );
                    },
                    isLoading ? 'Menyimpan...' : 'Save',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
