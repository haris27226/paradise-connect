import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:progress_group/core/constants/assets.dart';
import 'package:progress_group/core/utils/helpers/image_url.dart';
import 'package:progress_group/core/utils/widget/custom_button.dart';
import 'package:progress_group/features/attandance/data/arguments/attandance_args.dart';
import 'package:progress_group/features/contact/data/arguments/contact_dropdown_args.dart';
import 'package:progress_group/features/contact/domain/entities/activity/create_activity_params.dart';
import 'package:progress_group/features/contact/domain/entities/activity/create_activity_visit_params.dart';
import 'package:progress_group/features/contact/domain/entities/contact/create_contact_params.dart';
import 'package:progress_group/features/contact/domain/entities/prospect/prospect_status.dart';
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
import 'package:progress_group/features/contact/presentation/state/contact/contact_state.dart';
import 'package:progress_group/features/contact/presentation/state/prospect_status/prospect_status_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/prospect_status/prospect_status_event.dart';
import 'package:progress_group/features/contact/presentation/state/prospect_status/prospect_status_state.dart';
import 'package:progress_group/features/contact/presentation/state/contact/contact_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/contact/contact_event.dart';
import 'package:progress_group/features/contact/presentation/state/attachment/attachment_cubit.dart';


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
  TextEditingController lBlockNoTC = TextEditingController();
  FocusNode descFN = FocusNode();
  FocusNode lBlockNoFN = FocusNode();

  bool isFollowUp = false;
  DateTime? selectedDate;

  File? selectedImage;

  final ImagePicker picker = ImagePicker();
  String? existingImageUrl;
  String selectedTypeName = "Select type";
  String selectedStatusName = "Select status";

  int? selectedTypeId;
  int? selectedStatusId;
  String? selectedProject;
  String? selectedProduct;
  String jmlDatang = "1";
  String? selectedBlockNo;
  String? selectedProjectCategory;

  File? selectedFile;
  String? selectedFileName;
  bool isPdf = false;
  List<File> selectedImages = [];

  List<OwnerDropdownItem> itemsJmlDatang = [
    OwnerDropdownItem(name: "1"),
    OwnerDropdownItem(name: "2"),
    OwnerDropdownItem(name: "3"),
    OwnerDropdownItem(name: "4"),
    OwnerDropdownItem(name: ">5"),
  ];



  List<OwnerDropdownItem> itemsProject = [
    OwnerDropdownItem(id: 1, name: "Paradise Serpong City 1"),
    OwnerDropdownItem(id: 2, name: "Paradise Serpong City 2"),
    OwnerDropdownItem(id: 3, name: "Paradise Resort City")
  ];

  List<OwnerDropdownItem> itemsProjectCategory = [
    OwnerDropdownItem(id: 1, name: "Residential"),
    OwnerDropdownItem(id: 2, name: "Commercial")
  ];

  List<OwnerDropdownItem> itemsProduct = [
    OwnerDropdownItem(id: 1, name: "Evanto"),
    OwnerDropdownItem(id: 2, name: "Aris"),
    OwnerDropdownItem(id: 3, name: "Vireo"),
    OwnerDropdownItem(id: 4, name: "The Althea"),
  ];
  

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _init();
  }

  void _init() async {
    if (widget.args.dataActivity != null) {
      final activity = widget.args.dataActivity!;
      setState(() {
        descTC.text = activity.notes ?? "";
        if (activity.nextFollowUpDate != null && activity.nextFollowUpDate!.isNotEmpty) {
          try {
            isFollowUp = true;
            selectedDate = DateTime.parse(activity.nextFollowUpDate!);
          } catch (_) {}
        } else if (activity.activityDate.isNotEmpty) {
          try {
            selectedDate = DateTime.parse(activity.activityDate);
          } catch (_) {}
        }
      });
    }

    if (widget.args.page == 6 && widget.args.dataContact != null) {
      final data = widget.args.dataContact!;

      setState(() {
        selectedProject = data.lastProject ?? data.firstProject;
        selectedProduct = data.lastProduct;
        selectedStatusId = data.statusProspectId;
        selectedStatusName = "Update Status Prospect";
        selectedBlockNo = data.lastBlokNo;
        selectedProjectCategory = data.lastProjectCategory;
        lBlockNoTC.text = data.lastBlokNo ?? '';
        jmlDatang = data.visitCount?.toString() ?? "1";
        descTC.text = data.generalNotes ?? "";
        if (data.lastApptDate != null) {
          try {
            selectedDate = DateTime.parse(data.lastApptDate!);
          } catch (_) {}
        }
      });

      // Fetch latest detail to ensure data is fresh
      context.read<ContactBloc>().add(FetchContactDetailEvent(data.contactId),);
    }

    if (widget.args.page == 5 && widget.args.dataAttachment != null) {
      final data = widget.args.dataAttachment!;

      setState(() {
        selectedTypeId = data.attachmentTypeId;
        selectedTypeName = data.attachmentTypeName;
        descTC.text = data.attachmentNote;
        existingImageUrl = data.attachmentUrl;
      });
    }

    context.read<AttachmentTypeBloc>().add(FetchAttachmentTypesEvent());
    context.read<ProspectStatusBloc>().add(const FetchProspectStatusesEvent(type: 'plan'));
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

  Future<void> _openCamera() async {
    final result = await context.pushNamed(
      'camera',
      extra: AttandanceArgs(
        type: widget.args.page == 4 ? "Visit" : "Attachment",
        location: "-", // or fetch location if needed
        time: DateFormat('HH:mm').format(DateTime.now()),
        isReturnImage: true,
        skipPreview: widget.args.page == 4,
      ),
    );


    if (result != null) {
      final file = File(result as String);
      setState(() {
        if (widget.args.page == 4) {
          selectedImages.add(file);
        } else {
          selectedImage = file;
          selectedFile = file; // reset file
        }
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

  void _submitActivity({  required String activityType,  required DateTime activityDate,  required TextEditingController notesTC,  required bool isFollowUp,  required DateTime? followUpDate,}) {
    final contactId = widget.args.dataContact?.contactId;
    if (contactId == null) return;

    String mappedType = activityType;
    String finalNotes = notesTC.text.trim();

    if (!['Call','WhatsApp','Visit','Meeting','Note','Email','Task','Other'].contains(activityType)) {
      mappedType = 'Other';
      finalNotes = '[$activityType] $finalNotes'.trim();
    }

    final params = CreateActivityParams(
      contactId: contactId,
      dealId: null,
      activityType: mappedType,
      activityDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(activityDate),
      notes: finalNotes.isEmpty ? null : finalNotes,
      nextFollowUpDate: isFollowUp && followUpDate != null? DateFormat('yyyy-MM-dd HH:mm:ss').format(followUpDate): null,
    );

    context.read<ActivityBloc>().add(CreateActivityEvent(params));
  }

  void _submitAttachment() {
    final contactId = widget.args.dataContact?.contactId;
    if (contactId == null) return;

    final isEdit = widget.args.page == 6;

    if (selectedTypeId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih tipe attachment')));
      return;
    }

    if (!isEdit && selectedImage == null && selectedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih file')));
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
        attachmentId: isEdit
            ? widget.args.dataAttachment?.contactAttachmentId
            : null,
      ),
    );
  }

  void _submitUpdateStatus(BuildContext context) {
    final contact = widget.args.dataContact;
    if (contact == null) return;

    final params = CreateContactParams(
      statusProspectId: selectedStatusId,
      visitCount: int.tryParse(jmlDatang),
      lastApptDate: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null,
      lastBlokNo: lBlockNoTC.text,
      lastProject: selectedProject,
      lastProduct: selectedProduct,
      lastProjectCategory: selectedProjectCategory,
      generalNotes: descTC.text,
    );


    print("data update: ${params.toString()}");

    context.read<ContactBloc>().add(UpdateContactEvent(contact.contactId, params));
  }

  void _submitVisit(BuildContext context) {
    if (selectedStatusId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status wajib dipilih')));
      return;
    }


    final params = CreateVisitParams(
      contactId: widget.args.dataContact!.contactId,
      statusProspectId: selectedStatusId!,
      visitCount: int.parse(jmlDatang),
      activityDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate!),
      notes: descTC.text,
      files: selectedImages,
    );

    context.read<ActivityVisitBloc>().add(CreateVisitEvent(params));
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
                context.read<ActivityBloc>().add(FetchActivitiesEvent(contactId: contactId, isRefresh: true));
                context.read<ActivityProspectStatusBloc>().add(FetchActivityProspectStatusEvent(contactId));
                context.read<ContactBloc>().add(FetchContactDetailEvent(contactId));
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
                  content: Text(
                    state.errorMessage ?? 'Gagal menambahkan activity',
                  ),
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
        BlocListener<ContactBloc, ContactState>(
          listener: (context, state) {
            if (state.status == ContactStatus.createSuccess) {
              final contactId = widget.args.dataContact?.contactId;
              if (contactId != null) {
                context.read<ActivityBloc>().add(FetchActivitiesEvent(contactId: contactId, isRefresh: true));
                context.read<ActivityProspectStatusBloc>().add(FetchActivityProspectStatusEvent(contactId));
                context.read<ContactBloc>().add(FetchContactDetailEvent(contactId));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Status Prospect berhasil diperbarui'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state.status == ContactStatus.detailLoaded && state.contactDetail != null) {
              final data = state.contactDetail!;
              setState(() {
                selectedProject = data.projectName ?? data.firstProject;
                selectedStatusId = data.statusProspectId;
                // Try to find the status name from current ProspectStatusBloc state if possible
                final statusState = context.read<ProspectStatusBloc>().state;
                if (statusState.status == ProspectStatusEnum.loaded) {
                  final matched = statusState.statuses.cast<ProspectStatus?>().firstWhere(
                    (e) => e?.statusProspectId == data.statusProspectId,
                    orElse: () => null,
                  );
                  if (matched != null) {
                    selectedStatusName = matched.statusProspectName;
                  }
                }
                
                selectedBlockNo = data.lastBlokNo;
                selectedProject = data.lastProject ?? data.firstProject;
                selectedProduct = data.lastProduct;
                selectedProjectCategory = data.lastProjectCategory;
                lBlockNoTC.text = data.lastBlokNo ?? '';
                jmlDatang = data.visitCount?.toString() ?? "1";
                descTC.text = data.generalNotes ?? "";
                if (data.lastApptDate != null) {
                  try {
                    selectedDate = DateTime.parse(data.lastApptDate!);
                  } catch (_) {}
                }
              });
            } else if (state.status == ContactStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<ActivityVisitBloc, VisitState>(
          listener: (context, state) {
            if (state is VisitSuccess) {
              final contactId = widget.args.dataContact?.contactId;
              final dealId = widget.args.dataContact?.dealId;

              if (contactId != null) {
                // Refresh Activities
                context.read<ActivityBloc>().add(FetchActivitiesEvent(contactId: contactId, isRefresh: true));
                
                // Refresh Attachments
                context.read<AttachmentCubit>().fetch(contactId, dealId);
                
                // Refresh Prospect Status & Detail
                context.read<ActivityProspectStatusBloc>().add(FetchActivityProspectStatusEvent(contactId));
                context.read<ContactBloc>().add(FetchContactDetailEvent(contactId));
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visit berhasil ditambahkan'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state is VisitError) {
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
          child: BlocBuilder<UploadAttachmentBloc, UploadAttachmentState>(
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
                            : widget.args.page == 5
                            ? "Attachment"
                            : selectedStatusName,
                        isBack: true,
                        colorBack: Color(primaryColor),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (widget.args.page == 5)
                                  _buildAttachment()
                                else if (widget.args.page == 4)
                                  _buildVisit()
                                else if (widget.args.page == 6)
                                  _buildUpdateStatusProspect()
                                else
                                  _buildForm(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateStatusProspect() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Color(whiteColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(selectedStatusId == 53)_fieldProject(),
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
              onTap: () async {
                final statusState = context.read<ProspectStatusBloc>().state;
                if (statusState.status == ProspectStatusEnum.loaded) {
                  final statusItems = statusState.statuses
                      .map(
                        (e) => OwnerDropdownItem(
                          id: e.statusProspectId,
                          name: e.statusProspectName,
                        ),
                      )
                      .toList();

                  final result = await context.pushNamed(
                    'detailContactDropdown',
                    extra: ContactDropdownArgs(
                      title: 'Pilih Status',
                      items: statusItems,
                      selectedId: selectedStatusId,
                    ),
                  );

                  if (result != null) {
                    final selected = result as OwnerDropdownItem;
                    final picked = statusState.statuses
                        .cast<ProspectStatus?>()
                        .firstWhere(
                          (e) => e?.statusProspectId == selected.id,
                          orElse: () => null,
                        );
                    if (picked != null) {
                      setState(() {
                        selectedStatusId = picked.statusProspectId;
                        selectedStatusName = picked.statusProspectName;
                      });
                    }
                  }
                } else {
                  context.read<ProspectStatusBloc>().add(
                        const FetchProspectStatusesEvent(type: 'plan'),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Memuat daftar status...')),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(grey8Color)),
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
                            : Colors.black,
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
              "Tanggal ${selectedStatusId == 53? "Appointment" :selectedStatusId == 63? "Visit" : selectedStatusId == 70? "Reserved" : "SP"}",
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
                  border: Border.all(color: Color(grey7Color)),
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
            if (selectedStatusId == 53) _fieldAppointmentVolume(),
            if (selectedStatusId == 70 || selectedStatusId == 74) _fieldBlockSelected(),
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
                hintText: "Note...",
                hintStyle: TextStyle(
                  color: Color(grey2Color),
                  fontSize: 14,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(grey7Color)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(grey7Color)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(primaryColor)),
                ),
              ),
            ),
            SizedBox(height: 20),
            BlocConsumer<ContactBloc, ContactState>(
              listener: (context, state) {},
              builder: (context, state) {
                final isLoading = state.status == ContactStatus.creating;

                return customButton(
                  isLoading
                      ? null
                      : () {
                          _submitUpdateStatus(context);
                        },
                  isLoading ? 'Saving...' : 'Save',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldProject(){
   return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           "Project",
           style: TextStyle(
             fontSize: 12,
             fontWeight: FontWeight.bold,
             color: Color(grey2Color),
           ),
         ),
         SizedBox(height: 6),
         GestureDetector(
           onTap: () async {
             final selectedItem = itemsProject.firstWhere(
                (e) => e.name == selectedProject,
                orElse: () => OwnerDropdownItem(id: 0, name: ''),
              );
             final result = await context.pushNamed(
                'detailContactDropdown',
                extra: ContactDropdownArgs(
                  title: 'Project',
                  items: itemsProject,
                  selectedId: selectedItem.id,
                ),
              );
               if (result != null) {
                  final selected = result as OwnerDropdownItem;
                 setState(() {
                   selectedProject = selected.name;
                 });
               }
           },
           child: Container(
             width: double.infinity,
             height: 40,
             decoration: BoxDecoration(
               border: Border.all(color: Color(grey8Color)),
               borderRadius: BorderRadius.circular(8),
             ),
             padding: EdgeInsets.symmetric(horizontal: 16),
             alignment: Alignment.centerLeft,
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   selectedProject ?? "Select project",
                   style: TextStyle(
                     fontSize: 14,
                     color: selectedProject == null ? Color(grey2Color) : Colors.black,
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
       ],
     );
  }

  Widget _fieldAppointmentVolume(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Appointment Volume",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(grey2Color),
          ),
        ),
        SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final result = await context.pushNamed(
              'detailContactDropdown',
              extra: ContactDropdownArgs(
                title: 'Appointment Volume',
                items: itemsJmlDatang,
                selectedId: null,
              ),
            );
            if (result != null) {
              final selected = result as OwnerDropdownItem;
              setState(() {
                jmlDatang = selected.name;
              });
            }
          },
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Color(grey8Color)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${jmlDatang}",
                  style: TextStyle(fontSize: 14, color: Colors.black),
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
      ],
    );
  }

  Widget _fieldBlockSelected() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Last Project Category",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(grey2Color),
          ),
        ),
        SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final selectedItem = itemsProjectCategory.firstWhere(
              (e) => e.name == selectedProjectCategory,
              orElse: () => OwnerDropdownItem(id: 0, name: ''),
            );
            final result = await context.pushNamed(
              'detailContactDropdown',
              extra: ContactDropdownArgs(
                title: 'Project Category',
                items: itemsProjectCategory,
                selectedId: selectedItem.id,
              ),
            );
            if (result != null) {
              final selected = result as OwnerDropdownItem;

              setState(() {
                selectedProjectCategory = selected.name;
              });
            }
          },
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Color(grey8Color)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedProjectCategory ?? "Select category",
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedProjectCategory == null
                        ? Color(grey2Color)
                        : Colors.black,
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
          "Last Project",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(grey2Color),
          ),
        ),
        SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final selectedItem = itemsProject.firstWhere(
              (e) => e.name == selectedProject,
              orElse: () => OwnerDropdownItem(id: 0, name: ''),
            );
            final result = await context.pushNamed(
              'detailContactDropdown',
              extra: ContactDropdownArgs(
                title: 'Last Project',
                items: itemsProject,
                selectedId: selectedItem.id,
              ),
            );
            if (result != null) {
              final selected = result as OwnerDropdownItem;

              setState(() {
                selectedProject = selected.name;
              });
            }
          },
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Color(grey8Color)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedProject ?? "Select project",
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedProject == null
                        ? Color(grey2Color)
                        : Colors.black,
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
          "Last Product",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(grey2Color),
          ),
        ),
        SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final selectedItem = itemsProduct.firstWhere(
              (e) => e.name == selectedProduct,
              orElse: () => OwnerDropdownItem(id: 0, name: ''),
            );
            final result = await context.pushNamed(
              'detailContactDropdown',
              extra: ContactDropdownArgs(
                title: 'Last Product',
                items: itemsProduct,
                selectedId: selectedItem.id,
              ),
            );
            if (result != null) {
              final selected = result as OwnerDropdownItem;

              setState(() {
                selectedProduct = selected.name;
              });
            }
          },
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Color(grey8Color)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedProduct ?? "Select product",
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedProduct == null
                        ? Color(grey2Color)
                        : Colors.black,
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
          "Last Block No",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(grey2Color),
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: lBlockNoTC,
          focusNode: lBlockNoFN,
          onTapOutside: (event) => lBlockNoFN.unfocus(),
          decoration: InputDecoration(
            hintText: "Enter block no",
            hintStyle: TextStyle(
              color: Color(grey2Color),
              fontSize: 12,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(grey8Color)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(grey8Color)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(primaryColor)),
            ),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }




  Widget _buildVisit() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Color(whiteColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVisitPhotos(),
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
              onTap: () async {
                final statusState = context.read<ProspectStatusBloc>().state;
                if (statusState.status == ProspectStatusEnum.loaded) {
                  final statusItems = statusState.statuses
                      .map(
                        (e) => OwnerDropdownItem(
                          id: e.statusProspectId,
                          name: e.statusProspectName,
                        ),
                      )
                      .toList();

                  final result = await context.pushNamed(
                    'detailContactDropdown',
                    extra: ContactDropdownArgs(
                      title: 'Pilih Status',
                      items: statusItems,
                      selectedId: selectedStatusId,
                    ),
                  );

                  if (result != null) {
                    final selected = result as OwnerDropdownItem;
                    final picked = statusState.statuses
                        .cast<ProspectStatus?>()
                        .firstWhere(
                          (e) => e?.statusProspectId == selected.id,
                          orElse: () => null,
                        );
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
                    const SnackBar(content: Text('Memuat daftar status...')),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(grey8Color)),
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
                            : Colors.black,
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
                  border: Border.all(color: Color(grey7Color)),
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
            GestureDetector(
              onTap: () async {
                final result = await context.pushNamed(
                  'detailContactDropdown',
                  extra: ContactDropdownArgs(
                    title: 'Project',
                    items: itemsJmlDatang,
                    selectedId: selectedStatusId,
                  ),
                );
                if (result != null) {
                  final selected = result as OwnerDropdownItem;
                  setState(() {
                    jmlDatang = selected.name;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(grey8Color)),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${jmlDatang}",
                      style: TextStyle(fontSize: 14, color: Colors.black),
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
                hintStyle: TextStyle(
                  color: Color(grey2Color).withOpacity(0.0),
                  fontSize: 14,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(grey7Color)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(grey7Color)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(primaryColor)),
                ),
              ),
            ),
            SizedBox(height: 20),
            BlocConsumer<ActivityVisitBloc, VisitState>(
              listener: (context, state) {
                if (state is VisitSuccess) {
                  final contactId = widget.args.dataContact?.contactId;
                  if (contactId != null) {
                    context.read<ActivityBloc>().add(
                          FetchActivitiesEvent(
                              contactId: contactId, isRefresh: true),
                        );
                    context.read<ActivityProspectStatusBloc>().add(
                          FetchActivityProspectStatusEvent(contactId),
                        );
                    context.read<ContactBloc>().add(
                          FetchContactDetailEvent(contactId),
                        );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Visit berhasil dibuat')),
                  );
                  Navigator.pop(context);
                }

                if (state is VisitError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                final isLoading = state is VisitLoading;

                return customButton(
                  isLoading
                      ? null
                      : () {
                          print(
                            "Submit Visit with statusId: $selectedStatusId, visitCount: $jmlDatang, date: $selectedDate, notes: ${descTC.text}",
                          );
                          _submitVisit(context);
                        },
                  isLoading ? 'Saving...' : 'Save',
                );
              },
            ),
          ],
        ),
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
      child: Container(
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
                  color: Color(grey9Color),
                  border: Border.all(color: Color(grey7Color)),
                ),
                child:
                    (selectedFile != null ||
                        selectedImage != null ||
                        existingImageUrl != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (selectedFile != null && isPdf)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 60,
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    selectedFileName ?? "PDF File",
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : (selectedFile != null || selectedImage != null)
                            ? Image.file(
                                selectedFile ?? selectedImage!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                convertDriveUrl(existingImageUrl!),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.broken_image),
                                  );
                                },
                              ),
                      )
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
              ),
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
                      final items = state.data
                          .map((e) => OwnerDropdownItem(id: e.id, name: e.name))
                          .toList();

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
                        const SnackBar(
                          content: Text('Memuat attachment types...'),
                        ),
                      );
                      context.read<AttachmentTypeBloc>().add(
                        FetchAttachmentTypesEvent(),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(grey8Color)),
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
                                : Colors.black,
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
                  borderSide: BorderSide(color: Color(grey7Color)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(grey7Color)),
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
                return customButton(
                  isLoading
                      ? null
                      : () {
                          _submitAttachment();
                        },
                  isLoading ? 'Uploading...' : 'Save',
                );
              },
            ),
          ],
        ),
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
                : widget.args.page == 5
                ? "Attachment"
                : "Update Status Prospect",
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
              hintText:
                  "Describe the ${widget.args.page == 0
                      ? "call"
                      : widget.args.page == 1
                      ? "whatsapp"
                      : widget.args.page == 2
                      ? "meeting"
                      : widget.args.page == 3
                      ? "task"
                      : widget.args.page == 4
                      ? "visit"
                      : widget.args.page == 5
                      ? "attachment"
                      : "update status prospect"}...",
              hintStyle: TextStyle(color: Color(grey2Color), fontSize: 14),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(grey7Color)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(grey7Color)),
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
              border: Border.all(color: Color(grey7Color)),
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
                      border: Border.all(color: Color(grey7Color)),
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
                    isLoading
                        ? null
                        : () {
                            _submitActivity(
                              activityType: widget.args.namePage ?? '',
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

  // Widget _buildCameraFile() {
  //   // 1. Kondisi ketika SEMUA kosong (Tampilkan tombol upload)
  //   if (selectedFile == null &&
  //       selectedImage == null &&
  //       existingImageUrl == null) {
  //     return Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Container(
  //              padding: EdgeInsets.all(18),
  //               decoration: BoxDecoration(
  //                 color: Color(whiteColor),
  //                 borderRadius: BorderRadius.circular(14),
  //                 border: Border.all(color: Color(primaryColor)),
  //               ),
  //               child: Icon(Icons.camera_alt_rounded, color: Color(primaryColor), size: 40),
  //             ),
  //             SizedBox(height: 8),
  //             Text(
  //               "Open Camera",
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.bold,
  //                 color: Color(blue2Color),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     );
  //   }

  //   // 2. Jika ada file/gambar yang dipilih, tampilkan konten
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(8),
  //     child: _buildInsideContent(),
  //   );
  // }

  // Widget _buildInsideContent() {
  //   // PDF Logic
  //   if (selectedFile != null && isPdf) {
  //     return Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
  //         SizedBox(height: 8),
  //         Text(selectedFileName ?? "PDF File", textAlign: TextAlign.center),
  //       ],
  //     );
  //   }

  //   // Local Image Logic (Mobile/Web)
  //   if (selectedFile != null || selectedImage != null) {
  //     return Center(
  //       child: SizedBox(
  //         height: 120,
  //         child: _buildPreviewWidget(selectedFile ?? selectedImage!),
  //       ),
  //     );
  //   }

  //   // Network Image Logic
  //   return Image.network(
  //     convertDriveUrl(existingImageUrl!),
  //     width: double.infinity,
  //     fit: BoxFit.cover,
  //     errorBuilder: (context, error, stackTrace) {
  //       return Center(child: Icon(Icons.broken_image));
  //     },
  //   );
  // }

  Widget _buildVisitPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Visit Photos",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(grey2Color),
              ),
            ),
            if (selectedImages.isNotEmpty)
            Row(
              children: [
                IconButton(
                  onPressed: _openCamera,
                  icon: Icon(Icons.camera_alt, color: Color(primaryColor)),
                  tooltip: 'Take Photo',
                ),
                
              ],
            ),
          ],
        ),
        if (selectedImages.isNotEmpty)
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        else
          GestureDetector(
            onTap: () {
              _openCamera();
            },
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Color(grey9Color),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(grey7Color)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Color(primaryColor)),
                  SizedBox(height: 4),
                  Text(
                    "Add Photos",
                    style: TextStyle(color: Color(grey2Color), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

}
