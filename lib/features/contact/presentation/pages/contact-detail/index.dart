import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_group/core/constants/assets.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/core/utils/widget/custom_search_field.dart';
import 'package:progress_group/features/contact/data/arguments/contact_detail_args.dart';
import 'package:progress_group/features/contact/domain/entities/activity.dart';
import 'package:progress_group/features/contact/presentation/pages/contact-form/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_event.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_state.dart';
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

class _ContactDetailPageState extends State<ContactDetailPage> {
  TextEditingController searchTC = TextEditingController();

  FocusNode searchFN = FocusNode();

  int selectedIndex = 0;

  final tabs = ["Activity", "About", "Attachment"];

  Future<void> _onRefresh() async {
    final contactId = widget.args.data?.contactId;
    if (contactId != null) {
      context.read<ActivityBloc>().add(
        FetchActivitiesEvent(contactId: contactId, isRefresh: true),
      );
    }
  }

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);

    final contactId = widget.args.data?.contactId;
    if (contactId != null) {
      context.read<ActivityBloc>().add(
        FetchActivitiesEvent(contactId: contactId),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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
                                      widget.args.data?.fullName ?? '-',
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
                                        widget.args.data?.primaryPhone;
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
                                        widget.args.data?.whatsappNumber ??
                                        widget.args.data?.primaryPhone;
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
                child: TabBarView(
                  children: [
                    _buildActivityContent(),
                    ContactFormPage(
                      args: ContactDetailArgs(data: widget.args.data, page: 2),
                    ),
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
            context.pushNamed('addContact', extra: ContactDetailArgs(data: widget.args.data, page: 0, namePage: "Call"));
          }),
          _buildIconLink(icContactDetailWA, "WhatsApp", () {
            context.pushNamed('addContact', extra: ContactDetailArgs(data: widget.args.data, page: 1, namePage: "WhatsApp"));
          }),
          _buildIconLink(icContactDetailMeeting, "Meeting", () {
            context.pushNamed('addContact', extra: ContactDetailArgs(data: widget.args.data, page: 2,namePage: "Meeting"));
          }),
          _buildIconLink(icContactDetailReminder, "Task", () {
            context.pushNamed('addContact', extra: ContactDetailArgs(data: widget.args.data, page: 3,namePage: "Task"));
          }),
          _buildIconLink(icContactDetailVisit, "Visit", () {
            context.pushNamed('addContact', extra: ContactDetailArgs(data: widget.args.data, page: 4,namePage: "Visit"));
          }),
          _buildIconLink(
            icSidebarSalesKit,
            color: Color(primaryColor),
            "Attachment",
            () {
              context.pushNamed(
                'addContact',
                extra: ContactDetailArgs(data: widget.args.data, page: 5,namePage: "Attachment"),
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
        dividerColor: Colors.transparent,
        labelColor: Color(whiteColor),
        unselectedLabelColor: Color(blue2Color),
        indicator: BoxDecoration(
          color: Color(primaryColor),
          borderRadius: BorderRadius.circular(24),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        tabs: tabs.map((e) => Tab(text: e)).toList(),
      ),
    );
  }

  Widget _buildActivityContent() {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state.status == ActivityStatus.loading &&
            state.activities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ActivityStatus.error && state.activities.isEmpty) {
          return Center(
            child: Text(state.errorMessage ?? 'Error loading activities'),
          );
        }

        if (state.activities.isEmpty) {
          return const Center(child: Text('No activities found'));
        }

        // Group activities by month
        final Map<String, List<Activity>> grouped = {};
        for (var activity in state.activities) {
          try {
            final date = DateTime.parse(activity.activityDate);
            final monthYear = DateFormat('MMM yyyy').format(date).toUpperCase();
            if (!grouped.containsKey(monthYear)) {
              grouped[monthYear] = [];
            }
            grouped[monthYear]!.add(activity);
          } catch (e) {
            const monthYear = "UNKNOWN";
            if (!grouped.containsKey(monthYear)) grouped[monthYear] = [];
            grouped[monthYear]!.add(activity);
          }
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              final month = entry.key;
              final activities = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    month,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(blackColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: activities.map((item) {
                      Color activityColor = Colors.blue;
                      if (item.activityType == 'Call')
                        activityColor = Colors.green;
                      if (item.activityType == 'Meeting')
                        activityColor = Colors.purple;
                      if (item.activityType == 'Visit')
                        activityColor = Colors.orange;

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
                                color: activityColor,
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(blackColor),
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy HH:mm',
                                    ).format(DateTime.parse(item.activityDate)),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(grey7Color),
                                    ),
                                  ),
                                  if (item.notes != null)
                                    Text(
                                      item.notes!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(blackColor),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentContent() {
    return Column(
      children: [
        customSearchField(controller: searchTC, focusNode: searchFN),
        SizedBox(height: 9),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(whiteColor),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
            ],
          ),
          child: Row(
            children: [
              BgIcon(
                asset: icUpload,
                onTap: () {
                  context.pushNamed(
                    'addContact',
                    extra: ContactDetailArgs(page: 5),
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
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BgIcon(asset: icAttacment, onTap: () {}),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attachment",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Attachment",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      BgIcon(asset: null, onTap: () {}),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
              'addActivity',
              extra: {'contactId': widget.args.data?.contactId, 'dealId': null},
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
                      if (widget.args.data?.contactId != null) {
                        context.read<ContactBloc>().add(
                          DeleteContactEvent(widget.args.data!.contactId),
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
}
