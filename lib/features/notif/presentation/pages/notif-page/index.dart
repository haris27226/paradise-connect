import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:progress_group/core/constants/assets.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/core/utils/helpers/date_helper.dart';
import 'package:progress_group/core/utils/widget/custom_header.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_event.dart';
import 'package:progress_group/features/contact/presentation/state/activity/activity_state.dart';
import 'package:progress_group/features/inbox/data/arguments/inbox_detail_args.dart';
import 'package:progress_group/features/inbox/domain/entities/inbox_contact_entity.dart';

class NotifPage extends StatefulWidget {
  const NotifPage({super.key});

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  final Set<int> _completedActivityIds = {};

  @override
  void initState() {
    super.initState();
    // Memanggil semua aktivitas tanpa filter tanggal
    context.read<ActivityBloc>().add(const FetchActivitiesEvent(isRefresh: true));
  }

  Future<void> _onRefresh() async {
    context.read<ActivityBloc>().add(const FetchActivitiesEvent(isRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            customHeader(context, "Notifikasi", isBack: true, colorBack: Color(primaryColor)),
            SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildListNotif(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListNotif() {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state.status == ActivityStatus.loading && state.activities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final activities = state.activities;

        if (activities.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("Tidak ada notifikasi aktivitas")),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              final bool isCompleted = _completedActivityIds.contains(activity.activityId);
              final bool isWhatsApp = activity.activityType.toLowerCase().contains('whatsapp');
              final bool isCall = activity.activityType.toLowerCase().contains('call');

              return GestureDetector(
                onTap: () async {
                  if (isWhatsApp) {
                    if (activity.waId != null && activity.jid != null && activity.sessionCode != null) {
                      context.pushNamed(
                        'detailInbox',
                        extra: InboxDetailArgs(
                          data: InboxContact(
                            id: activity.waId!,
                            name: activity.contactName ?? 'Unknown',
                            jid: activity.jid!,
                            isGroup: activity.isGroup ?? false,
                            initials: activity.initials ?? '?',
                            sessionCode: activity.sessionCode!,
                          ),
                          icon: Icons.person,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Missing message history'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else if (isCall) {
                    if (activity.phoneNumber != null) {
                      final Uri telLaunchUri = Uri(
                        scheme: 'tel',
                        path: activity.phoneNumber,
                      );
                      if (await canLaunchUrl(telLaunchUri)) {
                        await launchUrl(telLaunchUri);
                      }
                    }
                  }

                  setState(() {
                    if (isCompleted) {
                      _completedActivityIds.remove(activity.activityId);
                    } else {
                      _completedActivityIds.add(activity.activityId);
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.check_circle_outline_rounded,
                            color: isCompleted ? Colors.green : Color(primaryColor),
                            size: 40,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.activityType,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(blackColor),
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              Text(
                                activity.nextFollowUpDate != null
                                    ? DateHelper.formatToIndonesian(DateTime.parse(activity.nextFollowUpDate!))
                                    : "No follow-up date",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(grey2Color)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        child: isWhatsApp
                            ? Image.asset(icContactDetailWA)
                            : Icon(
                                isCall ? Icons.phone_outlined : Icons.event_note_outlined,
                                color: Color(primaryColor),
                                size: 30,
                              ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}