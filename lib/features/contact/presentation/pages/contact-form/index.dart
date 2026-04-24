import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_group/features/contact/domain/entities/prospect_status.dart';

import '../../../../../core/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/widget/custom_dropdown_group.dart';
import '../../../data/arguments/contact_detail_args.dart';
import '../../state/contact/contact_bloc.dart';
import '../../state/contact/contact_event.dart';
import '../../state/contact/contact_state.dart';
import '../../../domain/entities/create_contact_params.dart';
import '../../../domain/entities/owner.dart';
import '../../../domain/entities/sales_executive.dart';
import '../../../domain/entities/sales_manager.dart';
import '../../state/owner/owner_bloc.dart';
import '../../state/owner/owner_event.dart';
import '../../state/owner/owner_state.dart';
import '../../state/prospect_status/prospect_status_bloc.dart';
import '../../state/prospect_status/prospect_status_event.dart';
import '../../state/prospect_status/prospect_status_state.dart';
import '../../state/sales_executive/sales_executive_bloc.dart';
import '../../state/sales_executive/sales_executive_event.dart';
import '../../state/sales_executive/sales_executive_state.dart';
import '../../state/sales_manager/sales_manager_bloc.dart';
import '../../state/sales_manager/sales_manager_event.dart';
import '../../state/sales_manager/sales_manager_state.dart';
import '../../../domain/entities/sales_manager.dart';

class ContactFormPage extends StatefulWidget {
  final ContactDetailArgs args;
  const ContactFormPage({super.key, required this.args});

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  TextEditingController fullNameTC = TextEditingController();
  TextEditingController emailTC = TextEditingController();
  TextEditingController phoneTC = TextEditingController();
  TextEditingController waTC = TextEditingController();
  TextEditingController blockNoTC = TextEditingController();
  TextEditingController FPProductTC = TextEditingController();
  TextEditingController FPCategoryTC = TextEditingController();
  TextEditingController salesExecutiveTC = TextEditingController();
  TextEditingController salesManagerTC = TextEditingController();
  TextEditingController generalNotesTC = TextEditingController();

  String? selectedSalutation;
  int? selectedOwnerId;
  String? selectedOwnerName;
  int? selectedStatusId;
  String? selectedStatusName;
  String? selectedProject;
  int? selectedChannelId;
  String? selectedSumberInformasi;
  int? selectedTeamId;
  int? selectedSupervisorId;
  int? selectedSalesExecutiveId;
  String? selectedSalesExecutiveName;
  int? selectedSalesManagerId;
  String? selectedSalesManagerName;

  FocusNode fullNameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode phoneFN = FocusNode();
  FocusNode waFN = FocusNode();
  FocusNode blockNoFN = FocusNode();
  FocusNode FPProducttFN = FocusNode();
  FocusNode FPCategorytFN = FocusNode();  
  FocusNode salesExecutiveFN = FocusNode();
  FocusNode salesManagerFN = FocusNode();
  FocusNode generalNotesFN = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.args.page == 1 && widget.args.data != null) {
      // Edit mode: fill with data from args
      _fillForm(widget.args.data!);
    } else if (widget.args.page == 2 && widget.args.data != null) {
      // About mode: fetch latest data from API
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ContactBloc>().add(FetchContactDetailEvent(widget.args.data!.contactId));
      });
    }

    // Always ensure master data is loaded for mapping IDs to names
    context.read<OwnerBloc>().add(FetchOwnersEvent());
    context.read<ProspectStatusBloc>().add(FetchProspectStatusesEvent());
    context.read<SalesExecutiveBloc>().add(const FetchSalesExecutivesEvent());
    context.read<SalesManagerBloc>().add(const FetchSalesManagersEvent());
  }

  void _fillForm(dynamic contact) {
    fullNameTC.text = contact.fullName ?? '';
    emailTC.text = contact.primaryEmail ?? '';
    phoneTC.text = contact.primaryPhone ?? '';
    waTC.text = contact.whatsappNumber ?? '';
    blockNoTC.text = contact.firstBlokNo ?? '';
    FPProductTC.text = contact.firstProduct ?? '';
    FPCategoryTC.text = contact.firstProjectCategory ?? '';
    generalNotesTC.text = contact.generalNotes ?? '';
    
    setState(() {
      selectedSalutation = contact.salutation;
      selectedOwnerId = contact.salesExecutiveId; // In list logic it's often salesExecutiveId
      selectedProject = contact.firstProject;
      selectedStatusId = contact.statusProspectId;
      selectedSalesExecutiveId = contact.salesExecutiveId;
      selectedSalesManagerId = contact.salesManagerId;

      // Map Names from BLoCs
      final ownerState = context.read<OwnerBloc>().state;
      if (ownerState.status == OwnerStatus.loaded) {
        selectedOwnerName = ownerState.owners.cast<Owner?>().firstWhere((e) => e?.salesPersonId == selectedOwnerId, orElse: () => null)?.fullName;
      }

      final statusState = context.read<ProspectStatusBloc>().state;
      if (statusState.status == ProspectStatusEnum.loaded) {
        selectedStatusName = statusState.statuses.cast<ProspectStatus?>().firstWhere((e) => e?.statusProspectId == selectedStatusId, orElse: () => null)?.statusProspectName;
      }

      final executiveState = context.read<SalesExecutiveBloc>().state;
      if (executiveState.status == SalesExecutiveStatus.loaded) {
        selectedSalesExecutiveName = executiveState.salesExecutives.cast<SalesExecutive?>().firstWhere((e) => e?.salesPersonId == selectedSalesExecutiveId, orElse: () => null)?.fullName;
      }

      final managerState = context.read<SalesManagerBloc>().state;
      if (managerState.status == SalesManagerStatus.loaded) {
        selectedSalesManagerName = managerState.salesManagers.cast<SalesManager?>().firstWhere((e) => e?.salesPersonId == selectedSalesManagerId, orElse: () => null)?.fullName;
      }
    });
  }

  
  void dispose() {
    fullNameTC.dispose();
    emailTC.dispose();
    phoneTC.dispose();
    waTC.dispose();
    blockNoTC.dispose();
    FPProductTC.dispose();
    FPCategoryTC.dispose();
    salesExecutiveTC.dispose();
    salesManagerTC.dispose();
    generalNotesTC.dispose();
    
    fullNameFN.dispose();
    emailFN.dispose();
    phoneFN.dispose();
    waFN.dispose();
    blockNoFN.dispose();
    FPProducttFN.dispose();
    FPCategorytFN.dispose();  
    salesExecutiveFN.dispose();
    salesManagerFN.dispose();
    generalNotesFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactBloc, ContactState>(
      listener: (context, state) {
        if (state.status == ContactStatus.creating) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state.status == ContactStatus.createSuccess) {
          context.pop(); // Close loading
          context.read<ContactBloc>().add(const FetchContactsEvent(isRefresh: true));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact created successfully')),
          );
          context.pop(); // Go back
        } else if (state.status == ContactStatus.detailLoaded && state.contactDetail != null) {
          _fillForm(state.contactDetail!);
        } else if (state.status == ContactStatus.error) {
          context.pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error creating contact')),
          );
        }
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<OwnerBloc, OwnerState>(
            listener: (context, state) {
              if (state.status == OwnerStatus.loaded && widget.args.page != 0) {
                final contact = context.read<ContactBloc>().state.contactDetail ?? widget.args.data;
                if (contact != null) _fillForm(contact);
              }
            },
          ),
          BlocListener<ProspectStatusBloc, ProspectStatusState>(
            listener: (context, state) {
              if (state.status == ProspectStatusEnum.loaded && widget.args.page != 0) {
                final contact = context.read<ContactBloc>().state.contactDetail ?? widget.args.data;
                if (contact != null) _fillForm(contact);
              }
            },
          ),
          BlocListener<SalesExecutiveBloc, SalesExecutiveState>(
            listener: (context, state) {
              if (state.status == SalesExecutiveStatus.loaded && widget.args.page != 0) {
                final contact = context.read<ContactBloc>().state.contactDetail ?? widget.args.data;
                if (contact != null) _fillForm(contact);
              }
            },
          ),
          BlocListener<SalesManagerBloc, SalesManagerState>(
            listener: (context, state) {
              if (state.status == SalesManagerStatus.loaded && widget.args.page != 0) {
                final contact = context.read<ContactBloc>().state.contactDetail ?? widget.args.data;
                if (contact != null) _fillForm(contact);
              }
            },
          ),
        ],
        child: Scaffold(
          body: SafeArea(
            child: _createContact(),
          ),
        ),
      ),
    );
  }

  
  Widget _createContact() {
    return Column(
      children: [
        /// 🔹 HEADER
        if (widget.args.page != 2)
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Color(whiteColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(Icons.arrow_back,
                          color: Color(primaryColor), size: 27),
                    ),
                    const SizedBox(width: 10),
                    Text(
                     widget.args.page == 1 ? "Edit Contact" : "Create Contact",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    final params = CreateContactParams(
                      fullName: fullNameTC.text,
                      salutation: selectedSalutation ?? "Mr.", // Default or from state
                      primaryPhone: phoneTC.text,
                      primaryEmail: emailTC.text.isNotEmpty ? emailTC.text : null,
                      whatsappNumber: waTC.text.isNotEmpty ? waTC.text : null,
                      firstProject: selectedProject,
                      firstProduct: FPProductTC.text.isNotEmpty ? FPProductTC.text : null,
                      firstProjectCategory: FPCategoryTC.text.isNotEmpty ? FPCategoryTC.text : null,
                      firstBlokNo: blockNoTC.text.isNotEmpty ? blockNoTC.text : null,
                      salesExecutiveId: selectedSalesExecutiveId,
                      salesManagerId: selectedSalesManagerId ?? 6, // Use selected or default
                      salesSupervisorId: 73, // Hardcoded in example?
                      salesTeamId: 1, // Hardcoded in example?
                      salesChannelId: selectedChannelId ?? 1,
                      statusProspectId: selectedStatusId ?? 1,
                      sumberInformasi2: selectedSumberInformasi ?? "Instagram Ads",
                      generalNotes: generalNotesTC.text.isNotEmpty ? generalNotesTC.text : null,
                      properties: const {"23": "City"},
                    );
                    context.read<ContactBloc>().add(CreateContactEvent(params));
                  },
                  child: Container(
                    height: 36,
                    width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Color(blue3Color),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Color(whiteColor),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        /// 🔥 CONTENT (SCROLLABLE)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                CustomDropdownGroupContact(
                  hint: "Contact Information",
                  child: Column(
                    children: [
                      _buildField(label: "Full Name", controller: fullNameTC, focusNode: fullNameFN),
                      _buildFieldDown(label: "Owner", value: selectedOwnerName, onTap: () async {
                        // Assuming OwnerSelectionPage returns an Owner object
                        final result = await context.pushNamed('selectOwner', extra: selectedOwnerId);
                        if (result != null) {
                          final owner = result as Owner;
                          setState(() {
                            selectedOwnerId = owner.salesPersonId;
                            selectedOwnerName = owner.fullName;
                          });
                        }
                      }),
                      _buildFieldDown(label: "Salutation", value: selectedSalutation, onTap: () {
                        // For now simple selection logic or another page
                        setState(() {
                          selectedSalutation = "Mr."; // Mock selection
                        });
                      }),
                      _buildField(label: "Email", controller: emailTC, focusNode: emailFN),
                      _buildField(label: "Phone", controller: phoneTC, focusNode: phoneFN),
                      _buildField(label: "Whatsapp", controller: waTC, focusNode: waFN),
                      _buildFieldDown(label: "Status Prospect", value: selectedStatusName, onTap: () async {
                         final result = await context.pushNamed('selectStatus', extra: selectedStatusId);
                         if (result != null) {
                           final status = result as ProspectStatus;
                           setState(() {
                             selectedStatusId = status.statusProspectId;
                             selectedStatusName = status.statusProspectName;
                           });
                         }
                      }),
                      _buildFieldDown(label: "First Project Website", value: selectedProject, onTap: () {
                         setState(() {
                           selectedProject = "Paradise Serpong City"; // Mock
                         });
                      }),
                      _buildField(label: "First Project Product", controller: FPProductTC, focusNode: FPProducttFN),
                      _buildField(label: "First Project Category", controller: FPCategoryTC, focusNode: FPCategorytFN),
                      _buildField(label: "Block No", controller: blockNoTC, focusNode: blockNoFN),
                      _buildField(label: "General Notes", controller: generalNotesTC, focusNode: generalNotesFN),
                    ],
                  ),
                ),
                CustomDropdownGroupContact(
                  hint: "Sales Information",
                  child: Column(
                    children: [
                      _buildFieldDown(label: "Sales Executive", value: selectedSalesExecutiveName, onTap: () async {
                        final result = await context.pushNamed('selectSalesExecutive', extra: selectedSalesExecutiveId);
                        if (result != null) {
                          final executive = result as SalesExecutive;
                          setState(() {
                            selectedSalesExecutiveId = executive.salesPersonId;
                            selectedSalesExecutiveName = executive.fullName;
                          });
                        }
                      }),
                      _buildFieldDown(label: "Sales Manager", value: selectedSalesManagerName, onTap: () async {
                        final result = await context.pushNamed('selectSalesManager', extra: selectedSalesManagerId);
                        if (result != null) {
                          final manager = result as SalesManager;
                          setState(() {
                            selectedSalesManagerId = manager.salesPersonId;
                            selectedSalesManagerName = manager.fullName;
                          });
                        }
                      }),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldDown({  required String label,  String? value,  VoidCallback? onTap,}) {
  final isEmpty = value == null || value.isEmpty;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Color(whiteColor),
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color(grey10Color),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isEmpty)
                  Text(
                    label,
                    style: TextStyle(
                      color: Color(grey2Color),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                Text(
                  isEmpty ? label : value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isEmpty? Color(grey2Color) : Color(blackColor),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: 28),
        ],
      ),
    ),
  );
}

  Widget _buildField({  required String label,  required TextEditingController controller,  required FocusNode focusNode,}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical:  5, horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Color(whiteColor),
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color(grey10Color),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onTapOutside: (_) => focusNode.unfocus(),
                  style:  TextStyle(fontSize: 12, color: Color(blackColor),fontWeight: FontWeight.w700),
                  decoration:  InputDecoration(
                    isDense: true,
                    label: Text(label, style: TextStyle(fontSize: 12),),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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