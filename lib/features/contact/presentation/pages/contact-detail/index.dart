import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_group/core/constants/assets.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/core/utils/widget/custom_search_field.dart';
import 'package:progress_group/features/contact/data/arguments/contact_detail_args.dart';
import 'package:progress_group/features/contact/data/models/activity/activity_dashboard.dart';
import 'package:progress_group/features/contact/domain/entities/activity/activity_entity.dart';
import 'package:progress_group/features/contact/presentation/pages/contact-form/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_event.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_state.dart';
import 'package:progress_group/features/contact/presentation/state/attachment/attachment_cubit.dart';
import 'package:progress_group/features/contact/presentation/state/attachment/attachment_state.dart';
import 'package:progress_group/features/contact/presentation/state/attachment/upload_attachment_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/attachment/upload_attachment_state.dart';
import 'package:progress_group/features/contact/presentation/state/contact/contact_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/contact/contact_event.dart';

import '../../../../../core/utils/widget/custom_bg_icon.dart';
import '../../../../../core/utils/widget/custom_buttomsheet.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailPage extends StatefulWidget {
  final ContactDetailArgs args;

  const ContactDetailPage({super.key, required this.args});

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage>
    with TickerProviderStateMixin {
  TextEditingController searchTC = TextEditingController();

  FocusNode searchFN = FocusNode();

  int selectedIndex = 0;

  final tabs = ["Activity", "About", "Attachment"];
  late TabController _tabController;
  int currentTab = 0;
  

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != currentTab) {
        setState(() {
          currentTab = _tabController.index;
        });
      }
    });
    _init();
  }

  void _init() async {
    await _getActivity();
    await _getAttachment();
  }

  Future<void> _getActivity() async {
    final contactId = widget.args.dataContact?.contactId;
    if (contactId != null) {
      context.read<ActivityBloc>().add(
        FetchActivitiesEvent(contactId: contactId, isRefresh: true),
      );
    }
    context.read<ActivityProspectStatusBloc>().add(
      FetchActivityProspectStatusEvent(contactId!),
    );
  }

  Future<void> _getAttachment() async {
    final contactId = widget.args.dataContact?.contactId;
    if (contactId != null) {
      context.read<AttachmentCubit>().fetch(contactId, null);
    }
  }

  Future<void> _deleteAttachment({
    required int contactId,
    required int attachmentId,
  }) async {
    context.read<AttachmentCubit>().delete(
      contactId: contactId,
      attachmentId: attachmentId,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _selectContact()));
  }

  Widget _selectContact() {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () {
            showCustomBottomSheet(
              context: context,
              child: _buildContentBSAdd(),
            );
          },
          backgroundColor: Color(primaryColor),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              SizedBox(
                height: 210,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        color: Color(whiteColor),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Color(primaryColor),
                                    size: 27,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Contacts",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(blue2Color),
                                      ),
                                    ),
                                    Text(
                                      widget.args.dataContact?.fullName ?? '-',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BgIcon(
                                  asset: icContactDetailPhone,
                                  onTap: () async {
                                    final phone =
                                        widget.args.dataContact?.primaryPhone;
                                    if (phone != null && phone.isNotEmpty) {
                                      final Uri launchUri = Uri(
                                        scheme: 'tel',
                                        path: phone,
                                      );
                                      await launchUrl(launchUri);
                                    }
                                  },
                                ),
                                BgIcon(
                                  asset: icContactDetailWA,
                                  onTap: () async {
                                    var phone =
                                        widget
                                            .args
                                            .dataContact
                                            ?.whatsappNumber ??
                                        widget.args.dataContact?.primaryPhone;
                                    if (phone != null && phone.isNotEmpty) {
                                      phone = phone.replaceAll(
                                        RegExp(r'[^0-9]'),
                                        '',
                                      );
                                      if (phone.startsWith('0')) {
                                        phone = '62${phone.substring(1)}';
                                      }
                                      final Uri whatsappUri = Uri.parse(
                                        "https://wa.me/$phone",
                                      );
                                      await launchUrl(
                                        whatsappUri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                ),
                                BgIcon(
                                  asset: null,
                                  onTap: () {
                                    showCustomBottomSheet(
                                      context: context,
                                      child: _buildEditBottomSheetContent(
                                        context,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 50,
                      left: 16,
                      right: 16,
                      child: Transform.translate(
                        offset: const Offset(0, 25),
                        child: _buildTabBar(),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: IndexedStack(
                  index: currentTab,
                  children: [
                    _buildActivityContent(),
                    currentTab == 1? ContactFormPage(args: ContactDetailArgs(dataContact: widget.args.dataContact,page: 2),): const CircularProgressIndicator(),
                    _buildAttachmentContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentBSAdd() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Add...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 5),
          _buildIconLink(icContactDetailPhone, "Phone", () {
            context.pushNamed(
              'addContact',
              extra: ContactDetailArgs(
                dataContact: widget.args.dataContact,
                page: 0,
                namePage: "Call",
              ),
            );
          }),
          _buildIconLink(icContactDetailWA, "WhatsApp", () {
            context.pushNamed(
              'addContact',
              extra: ContactDetailArgs(
                dataContact: widget.args.dataContact,
                page: 1,
                namePage: "WhatsApp",
              ),
            );
          }),
          _buildIconLink(icContactDetailMeeting, "Meeting", () {
            context.pushNamed(
              'addContact',
              extra: ContactDetailArgs(
                dataContact: widget.args.dataContact,
                page: 2,
                namePage: "Meeting",
              ),
            );
          }),
          _buildIconLink(icContactDetailReminder, "Task", () {
            context.pushNamed(
              'addContact',
              extra: ContactDetailArgs(
                dataContact: widget.args.dataContact,
                page: 3,
                namePage: "Task",
              ),
            );
          }),
          _buildIconLink(icContactDetailVisit, "Visit", () {
            context.pushNamed(
              'addContact',
              extra: ContactDetailArgs(
                dataContact: widget.args.dataContact,
                page: 4,
                namePage: "Visit",
              ),
            );
          }),
          _buildIconLink(
            icSidebarSalesKit,
            color: Color(primaryColor),
            "Update Status Prospect",
            () {
              context.pushNamed(
                'addContact',
                extra: ContactDetailArgs(
                  dataContact: widget.args.dataContact,
                  page: 6,
                  namePage: "Update Status Prospect",
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(grey1Color),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TabBar(
        onTap: (index) {
          setState(() {
            currentTab = index;
          });
        },
        indicator: BoxDecoration(
          color: Color(primaryColor),
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Color(whiteColor),
        unselectedLabelColor: Color(blue2Color),
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),

        // 🔥 INI KUNCINYA
        tabs: tabs.map((e) => Tab(text: e)).toList(),
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        controller: TabController(
          length: tabs.length,
          vsync: this,
          initialIndex: currentTab,
        ),
      ),
    );
  }


Widget _buildActivityContent() {
  return BlocBuilder<ActivityBloc, ActivityState>(
    builder: (context, activityState) {
      return BlocBuilder<ActivityProspectStatusBloc,
          ActivityProspectStatusState>(
        builder: (context, prospectState) {
          // 🔥 LOADING
          if (activityState.status == ActivityStatus.loading &&
              activityState.activities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔥 MERGE DATA
          List<ActivityTimelineItem> timeline = [];

          // activity
          for (var item in activityState.activities) {
            final date = DateTime.tryParse(item.activityDate);
            if (date != null) {
              timeline.add(ActivityTimelineItem(
                date: date,
                type: 'activity',
                data: item,
              ));
            }
          }

          // prospect
          for (var item in prospectState.data) {
            final date = DateTime.tryParse(item.createdAt);
            if (date != null) {
              timeline.add(ActivityTimelineItem(
                date: date,
                type: 'prospect',
                data: item,
              ));
            }
          }

          // 🔥 SORT
          timeline.sort((a, b) => b.date.compareTo(a.date));

          // 🔥 GROUP BY TANGGAL
          final Map<String, List<ActivityTimelineItem>> grouped = {};

          for (var item in timeline) {
            final key = DateFormat('dd MMM yyyy').format(item.date);
            grouped.putIfAbsent(key, () => []);
            grouped[key]!.add(item);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal:  16),
            children: grouped.entries.map((entry) {
              final date = entry.key;
              final items = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Column(
                    children: items.map((item) {

                      if (item.type == 'activity') {
                        return ActivityItem(item: item.data,  activityColor: Color(purpleColor));
                      } else {
                        return _prospectItem(item.data);
                      }
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          );
        },
      );
    },
  );
}

  Widget _prospectItem(dynamic item) {
    final bool isUpdate = item.previousStatusName != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(whiteColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 5,
            decoration: BoxDecoration(
              color: Color(purpleColor),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
                children: isUpdate
                    ? [
                        TextSpan(
                            text: "${item.projectName} — Status berubah dari "),
                        TextSpan(
                          text: item.previousStatusName,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const TextSpan(text: " ke "),
                        TextSpan(
                          text: item.statusName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const TextSpan(text: "."),
                      ]
                    : [
                        TextSpan(
                            text: "${item.projectName} — Status awal "),
                        TextSpan(
                          text: item.statusName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const TextSpan(text: "."),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          customSearchField(controller: searchTC, focusNode: searchFN),
          SizedBox(height: 9),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(whiteColor),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                BgIcon(
                  asset: icUpload,
                  onTap: () {
                    context.pushNamed(
                      'addContact',
                      extra: ContactDetailArgs(
                        dataContact: widget.args.dataContact,
                        page: 5,
                        namePage: "Attachment",
                      ),
                    );
                  },
                  color: Color(primaryColor),
                ),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      "Add New File",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(primaryColor),
                      ),
                    ),
                    Text(
                      "upload new file",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(grey7Color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocListener<UploadAttachmentBloc, UploadAttachmentState>(
              listener: (context, state) {
                if (state is UploadAttachmentSuccess) {
                  context.read<AttachmentCubit>().fetch(
                    widget.args.dataContact!.contactId,
                    widget.args.dataContact!.dealId,
                  );
                }

                if (state is UploadAttachmentError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              child: RefreshIndicator(
                onRefresh: _getAttachment,
                child: BlocBuilder<AttachmentCubit, AttachmentState>(
                  builder: (context, state) {
                    if (state is AttachmentLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (state is AttachmentLoaded) {
                      final list = state.data;

                      if (list.isEmpty) {
                        return Center(child: Text("No attachment"));
                      }

                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Color(whiteColor),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    context.pushNamed(
                                      'attachmentWebView',
                                      extra: item.attachmentUrl,
                                    );
                                  },
                                  child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      convertDriveUrl(item.attachmentUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 58,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Color(whiteColor),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: Color(primaryColor),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.picture_as_pdf,
                                                color: Color(primaryColor),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                )),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.attachmentTypeName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      item.createDatetime.toString(),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      item.attachmentNote,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),

                                Spacer(),
                                PopupMenuButton<String>(
                                  icon: Container(
                                    height: 44,
                                    width: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Color(grey8Color),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(Icons.more_vert, size: 30),
                                  ),

                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      context.pushNamed(
                                        'addContact',
                                        extra: ContactDetailArgs(
                                          dataContact: widget.args.dataContact,
                                          dataAttachment: item,
                                          page: 6,
                                          namePage: "Attachment",
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(context, item);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    if (state is AttachmentError) {
                      return Center(child: Text(state.message));
                    }
                    return SizedBox();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditBottomSheetContent(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconLink(icEdit, "Edit Contact", () {
            context.pushNamed('formContact', extra: ContactDetailArgs(page: 1));
          }),
          _buildIconLink(icCalendar, "Add Activity", () {
            context.pushNamed(
              'addContact',
              extra: ContactDetailArgs(
                dataContact: widget.args.dataContact,
                page: 5,
                namePage: "Attachment",
              ),
            );
          }),
          _buildIconLink(icDelete, "Delete Contact", () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Confirm'),
                content: Text('Delete this contact?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (widget.args.dataContact?.contactId != null) {
                        context.read<ContactBloc>().add(
                          DeleteContactEvent(
                            widget.args.dataContact!.contactId,
                          ),
                        );
                      }
                    },
                    child: Text('Delete'),
                  ),
                ],
              ),
            );
          }),
          _buildIconLink(icShare, "Share Contact", () {}),
        ],
      ),
    );
  }

  Widget _buildIconLink(
    String asset,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            BgIcon(asset: asset, onTap: null, color: color),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Color(blue2Color),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Attachment"),
        content: Text("Are you sure want to delete this file?"),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              context.pop();
              _deleteAttachment(
                contactId: item.contactId,
                attachmentId: item.contactAttachmentId,
              );
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}


String convertDriveUrl(String url) {
  final uri = Uri.parse(url);
  final id = uri.pathSegments[2];
  return 'https://drive.google.com/uc?export=view&id=$id';
}


class ActivityItem extends StatefulWidget {
  final ActivityEntity item;
  final Color activityColor;

  const ActivityItem({
    super.key,
    required this.item,
    required this.activityColor,
  });

  @override
  State<ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<ActivityItem> {
  bool imageError = false;

  final ScrollController _scrollController = ScrollController();

  bool isAtStart = true;
  bool isAtEnd = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final offset = _scrollController.offset;

      setState(() {
        isAtStart = offset <= 0;
        isAtEnd = offset >= maxScroll;
      });
    });

    // delay biar posisi awal kebaca
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;

      setState(() {
        isAtStart = true;
        isAtEnd = maxScroll == 0;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    final newOffset = (_scrollController.offset - 250).clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    final newOffset = (_scrollController.offset + 250)
        .clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _arrowButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(whiteColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= HEADER =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 5,
                decoration: BoxDecoration(
                  color: widget.activityColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.activityType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('HH:mm')
                          .format(DateTime.parse(item.activityDate)),
                    ),
                    if (item.notes != null) Text(item.notes!),
                  ],
                ),
              ),
            ],
          ),

          /// ================= IMAGES =================
          if (item.imagePaths != null && item.imagePaths!.isNotEmpty)
            Container(
              height: 200,
              margin: const EdgeInsets.only(top: 10),
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: item.imagePaths!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          child: Image.network(
                            convertDriveUrl(item.imagePaths![index]),
                            fit: BoxFit.fill,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  /// 🔥 LEFT ARROW
                  if (!isAtStart)
                    Positioned(
                      left: 5,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _scrollLeft,
                          child: _arrowButton(Icons.arrow_back_ios),
                        ),
                      ),
                    ),

                  /// 🔥 RIGHT ARROW
                  if (!isAtEnd)
                    Positioned(
                      right: 5,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _scrollRight,
                          child: _arrowButton(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}