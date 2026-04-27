import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_group/core/constants/assets.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/core/utils/widget/custom_bg_icon.dart';
import 'package:progress_group/core/utils/widget/custom_header.dart';
import 'package:progress_group/core/utils/widget/custom_search_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_group/features/contact/data/arguments/contact_detail_args.dart';
import 'package:progress_group/features/contact/data/models/selectbox_model.dart';
import 'package:progress_group/features/contact/domain/entities/contact.dart';
import 'package:progress_group/features/contact/presentation/state/owner/owner_bloc.dart';
import 'package:progress_group/features/contact/presentation/state/owner/owner_event.dart';
import '../../../../../core/utils/widget/custom_buttomsheet.dart';
import '../../state/contact/contact_bloc.dart';
import '../../state/contact/contact_event.dart';
import '../../state/contact/contact_state.dart';
import '../../state/owner/owner_state.dart';
import '../../state/prospect_status/prospect_status_bloc.dart';
import '../../state/prospect_status/prospect_status_event.dart';
import '../../state/prospect_status/prospect_status_state.dart';
import '../../../../../core/utils/widget/custom_filter_button.dart';
import '../../../domain/entities/owner.dart';
import '../../../domain/entities/prospect_status.dart';
import '../contact-detail/index.dart';


class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late ScrollController _scrollController;
  Timer? _debounce;

  final List<SelectBoxModel> selectBoxes = [
    SelectBoxModel(items: ['Owner', 'B', 'C'], hint: "Owner"),
    SelectBoxModel(items: ['1', '2', '3'], hint: "Create Date"),
    SelectBoxModel(items: ['X', 'Y', 'Z'], hint: "Status"),
    ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    context.read<ContactBloc>().add(const FetchContactsEvent());
    context.read<OwnerBloc>().add(FetchOwnersEvent());
    context.read<ProspectStatusBloc>().add(FetchProspectStatusesEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ContactBloc>().add(const FetchContactsEvent());
    }
  }

  Future<void> _onRefresh() async {
    context.read<ContactBloc>().add(const FetchContactsEvent(isRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customHeader(context, 'Contacts'),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  customSearchField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        context.read<ContactBloc>().add(FetchContactsEvent(
                          search: value,
                          isRefresh: true,
                        ));
                      });
                    },
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectBoxes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = selectBoxes[index];
                        if (item.hint == "Owner") {
                          return BlocBuilder<ContactBloc, ContactState>(
                            builder: (context, contactState) {
                              String label = item.hint;
                              bool isSelected = contactState.ownerId != null;
                              
                              if (isSelected) {
                                // We need the owner name. We can get it from OwnerBloc state if available
                                final ownerState = context.read<OwnerBloc>().state;
                                if (ownerState.status == OwnerStatus.loaded) {
                                  final owner = ownerState.owners.cast<Owner?>().firstWhere(
                                    (e) => e?.salesPersonId == contactState.ownerId,
                                    orElse: () => null,
                                  );
                                  if (owner != null) {
                                    label = owner.fullName;
                                  }
                                }
                              }

                              return CustomFilterButton(
                                label: label,
                                isSelected: isSelected,
                                onTap: () async {
                                  final result = await context.pushNamed(
                                    'selectOwner',
                                    extra: contactState.ownerId,
                                  );
                                  if (result != null || contactState.ownerId != null) {
                                    final owner = result as Owner?;
                                    context.read<ContactBloc>().add(FetchContactsEvent(
                                      ownerId: owner?.salesPersonId,
                                      isRefresh: true,
                                    ));
                                  }
                                },
                              );
                            },
                          );
                        }
                        if (item.hint == "Status") {
                          return BlocBuilder<ContactBloc, ContactState>(
                            builder: (context, contactState) {
                              String label = item.hint;
                              bool isSelected = contactState.statusProspectId != null;

                              if (isSelected) {
                                final statusState = context.read<ProspectStatusBloc>().state;
                                if (statusState.status == ProspectStatusEnum.loaded) {
                                  final status = statusState.statuses.cast<ProspectStatus?>().firstWhere(
                                    (e) => e?.statusProspectId == contactState.statusProspectId,
                                    orElse: () => null,
                                  );
                                  if (status != null) {
                                    label = status.statusProspectName;
                                  }
                                }
                              }

                              return CustomFilterButton(
                                label: label,
                                isSelected: isSelected,
                                onTap: () async {
                                  final result = await context.pushNamed(
                                    'selectStatus',
                                    extra: contactState.statusProspectId,
                                  );
                                  if (result != null || contactState.statusProspectId != null) {
                                    final status = result as ProspectStatus?;
                                    context.read<ContactBloc>().add(FetchContactsEvent(
                                      statusProspectId: status?.statusProspectId,
                                      isRefresh: true,
                                    ));
                                  }
                                },
                              );
                            },
                          );
                        }
                        if (item.hint == "Create Date") {
                          return BlocBuilder<ContactBloc, ContactState>(
                            builder: (context, contactState) {
                              String label = item.hint;
                              bool isSelected = contactState.startDate != null && contactState.endDate != null;

                              if (isSelected) {
                                label = "${contactState.startDate} - ${contactState.endDate}";
                              }

                              return CustomFilterButton(
                                label: label,
                                isSelected: isSelected,
                                onTap: () async {
                                  final DateTimeRange? picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                    initialDateRange: isSelected 
                                      ? DateTimeRange(
                                          start: DateTime.parse(contactState.startDate!),
                                          end: DateTime.parse(contactState.endDate!),
                                        )
                                      : null,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Color(primaryColor),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (picked != null) {
                                    final startDate = DateFormat('yyyy-MM-dd').format(picked.start);
                                    final endDate = DateFormat('yyyy-MM-dd').format(picked.end);
                                    context.read<ContactBloc>().add(FetchContactsEvent(
                                      startDate: startDate,
                                      endDate: endDate,
                                      isRefresh: true,
                                    ));
                                  }
                                },
                              );
                            },
                          );
                        }
                        return CustomFilterButton(
                          label: item.hint,
                          onTap: () {
                            // TODO: Implement other filters
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: BlocBuilder<ContactBloc, ContactState>(
                      builder: (context, state) {
                        if (state.status == ContactStatus.loading && state.contacts.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state.status == ContactStatus.error && state.contacts.isEmpty) {
                          return Center(child: Text(state.errorMessage ?? 'Error loading contacts'));
                        }
                        if (state.contacts.isEmpty) {
                          return const Center(child: Text('No contacts found'));
                        }
                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.hasReachedMax ? state.contacts.length : state.contacts.length + 1,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              if (index >= state.contacts.length) {
                                return const Center(child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: CircularProgressIndicator(),
                                ));
                              }
                              final contact = state.contacts[index];
                              return _buildListContacts(context, contact);
                            },
                          ),
                        );
                      },
                    ),
                  )     
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10), 
        child: FloatingActionButton(
          onPressed: () {
            context.pushNamed('formContact', extra: ContactDetailArgs(page: 0));
          },
          backgroundColor: Color(primaryColor),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

Widget _buildListContacts(BuildContext context, Contact contact) {
  return GestureDetector(
    onTap: () {
      context.pushNamed('detailContact', extra: ContactDetailArgs(data: contact, page: 2));
    },
    child: Container(
      height: 70,
      decoration: BoxDecoration(
        color: Color(whiteColor),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        boxShadow: [
          BoxShadow(
            color: Color(shadowColor).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(primaryColor).withOpacity(0.1),
                  child: Icon(Icons.person, color: Color(primaryColor)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        contact.fullName ?? 'No Name',
                        style: TextStyle(fontSize: 16, color: Color(blue2Color), fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        contact.primaryPhone ?? 'No Phone',
                        style: TextStyle(fontSize: 14, color: Color(grey7Color)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showCustomBottomSheet(context: context, child: _buildContactOptions(context, contact));
            },
            child: Icon(Icons.more_vert, size: 27, color: Color(blackColor)),
          ),
        ],
      ),
    ),
  );
}

Widget _buildContactOptions(BuildContext context, Contact contact) {
  return Container(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconLink(context, icEdit, "Edit Contact", () {
          context.pushNamed('formContact', extra: ContactDetailArgs(data: contact, page: 1));
        }),
        _buildIconLink(context, icCalendar, "Add Activity", () {
          context.pushNamed('addActivity', extra: {
            'contactId': contact.contactId,
            'dealId': null,
          });
        }),
        _buildIconLink(context, icDelete, "Delete Contact", () {
          // TODO: Implement delete
        }),
        _buildIconLink(context, icShare, "Share Contact", () {
          // TODO: Implement share
        }),
      ],
    ),
  );
}

Widget _buildIconLink(BuildContext context, String asset, String label, VoidCallback onTap, {Color? color}) {
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
          const SizedBox(width: 10),
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
