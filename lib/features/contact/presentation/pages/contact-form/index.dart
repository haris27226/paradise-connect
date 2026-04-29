import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:progress_group/core/utils/helpers/date_helper.dart';
import 'package:intl/intl.dart';
import 'package:progress_group/features/contact/domain/entities/create_contact_params.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_group/core/network/dio_client.dart';
import 'package:progress_group/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:go_router/go_router.dart';
import 'package:progress_group/features/contact/domain/entities/prospect_status.dart';
import 'package:progress_group/features/contact/presentation/state/prospect_status/prospect_status_event.dart';

import '../../../../../core/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/widget/custom_dropdown_group.dart';
import '../../../../auth/domain/entities/user_profile.dart';
import '../../../../auth/presentation/state/profile/profile_bloc.dart';
import '../../../../auth/presentation/state/profile/profile_state.dart';
import '../../../data/arguments/contact_detail_args.dart';
import '../../../data/arguments/contact_dropdown_args.dart';
import '../../state/contact/contact_bloc.dart';
import '../../state/contact/contact_event.dart';
import '../../state/contact/contact_state.dart';
import '../../state/prospect_status/prospect_status_bloc.dart';
import '../../state/prospect_status/prospect_status_state.dart';
import '../../state/contact_properties/contact_properties_bloc.dart';
import '../../state/contact_properties/contact_properties_event.dart';
import '../../state/contact_properties/contact_properties_state.dart';

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
  TextEditingController fBlockNoTC = TextEditingController();
  TextEditingController FPProductTC = TextEditingController();
  TextEditingController FPCategoryTC = TextEditingController();
  TextEditingController salesExecutiveTC = TextEditingController();
  TextEditingController salesManagerTC = TextEditingController();
  TextEditingController generalNotesTC = TextEditingController();
  TextEditingController fProjectTC = TextEditingController();
  TextEditingController lProjectTC = TextEditingController();

  TextEditingController LPProducttTC = TextEditingController();
  TextEditingController LPCategorytTC = TextEditingController();
  TextEditingController lBlockNoTC = TextEditingController();
  TextEditingController noKTPTC = TextEditingController();
  TextEditingController ktpAddressTC = TextEditingController();
  TextEditingController sumberInfoTC = TextEditingController();
  TextEditingController volumePlanTC = TextEditingController();
  TextEditingController vCountTC = TextEditingController();
  TextEditingController firstVisitorDateTC = TextEditingController();
  TextEditingController lastVisitorDateTC = TextEditingController();
  TextEditingController firstApptDateTC = TextEditingController();
  TextEditingController lastApptDateTC = TextEditingController();
  TextEditingController dealValueTC = TextEditingController();
  TextEditingController reserveDateTC = TextEditingController();
  TextEditingController lossReasonNoteTC = TextEditingController();
  TextEditingController fspTC = TextEditingController();
  TextEditingController lspTC = TextEditingController();

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
  List<Map<String, dynamic>> salesInfoFields = [];
  final Map<int, TextEditingController> _propertyControllers = {};

  FocusNode fullNameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode phoneFN = FocusNode();
  FocusNode waFN = FocusNode();
  FocusNode fBlockNoFN = FocusNode();
  FocusNode FPProducttFN = FocusNode();
  FocusNode FPCategorytFN = FocusNode();
  FocusNode salesExecutiveFN = FocusNode();
  FocusNode salesManagerFN = FocusNode();
  FocusNode generalNotesFN = FocusNode();

  FocusNode LPProducttFN = FocusNode();
  FocusNode LPCategorytFN = FocusNode();
  FocusNode lBlockNoFN = FocusNode();
  FocusNode noKTPFN = FocusNode();
  FocusNode ktpAddressFN = FocusNode();
  FocusNode sumberInfoFN = FocusNode();
  FocusNode volumePlanFN = FocusNode();
  FocusNode vCountFN = FocusNode();
  FocusNode firstVisitorDateFN = FocusNode();
  FocusNode lastVisitorDateFN = FocusNode();
  FocusNode firstApptDateFN = FocusNode();
  FocusNode lastApptDateFN = FocusNode();
  FocusNode dealValueFN = FocusNode();
  FocusNode reserveDateFN = FocusNode();
  FocusNode lossReasonNoteFN = FocusNode();
  FocusNode fspFN = FocusNode();
  FocusNode lspFN = FocusNode();
  FocusNode fProjectFN = FocusNode();
  FocusNode lProjectFN = FocusNode();
  FocusNode sumberInformationFN = FocusNode();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    if (widget.args.page == 1 && widget.args.data != null) {
      // Edit mode: fill with data from args
      await _fillForm(widget.args.data!);
    } else if (widget.args.page == 2 && widget.args.data != null) {
      // About mode: fetch latest data from API
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ContactBloc>().add(
          FetchContactDetailEvent(widget.args.data!.contactId),
        );
      });
    }

    context.read<ProspectStatusBloc>().add(FetchProspectStatusesEvent());
    context.read<ContactPropertiesBloc>().add(FetchContactPropertiesEvent());

    // If creating a new contact, prefill first-date fields so UI shows values
    if (widget.args.page == 0 && widget.args.data == null) {
      final today = DateHelper.formatNumericCompact(DateTime.now());

      setState(() {
        if (firstApptDateTC.text.isEmpty) firstApptDateTC.text = today;
        if (firstVisitorDateTC.text.isEmpty) firstVisitorDateTC.text = today;
        if (fspTC.text.isEmpty) fspTC.text = today;
      });
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authLocal = AuthLocalDataSourceImpl(prefs);
      final dioClient = DioClient(authLocal);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: path.basename(file.path),
        ),
      });

      final response = await dioClient.dio.post(
        '/files/upload',
        data: formData,
      );
      if (response.data['status'] == true) {
        final data = response.data['data'];
        if (data is String) return data;
        if (data is Map && data['url'] != null) return data['url'];
        if (data is Map && data['path'] != null) return data['path'];
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> _fillForm(dynamic contact) async {
    fullNameTC.text = contact.fullName ?? '';
    emailTC.text = contact.primaryEmail ?? '';
    phoneTC.text = contact.primaryPhone ?? '';
    waTC.text = contact.whatsappNumber ?? '';
    fBlockNoTC.text = contact.firstBlokNo ?? '';
    FPProductTC.text = contact.firstProduct ?? '';
    FPCategoryTC.text = contact.firstProjectCategory ?? '';
    generalNotesTC.text = contact.generalNotes ?? '';
    LPProducttTC.text = contact.lastProduct ?? '';
    LPCategorytTC.text = contact.lastProjectCategory ?? '';
    lBlockNoTC.text = contact.lastBlokNo ?? '';
    noKTPTC.text = contact.noKtp ?? '';
    ktpAddressTC.text = contact.ktpAddress ?? '';
    sumberInfoTC.text = contact.sumberInformasi2 ?? '';
    volumePlanTC.text = contact.volumePlan?.toString() ?? '';
    vCountTC.text = contact.visitCount?.toString() ?? '';
    firstVisitorDateTC.text = _formatFromContact(contact.firstVisitDate);
    lastVisitorDateTC.text = _formatFromContact(contact.lastVisitDate);
    firstApptDateTC.text = _formatFromContact(contact.firstApptDate);
    lastApptDateTC.text = _formatFromContact(contact.lastApptDate);
    dealValueTC.text = contact.dealValue ?? '';
    reserveDateTC.text = _formatFromContact(contact.apptDate);
    lossReasonNoteTC.text = contact.dealNote ?? '';
    fspTC.text = _formatFromContact(contact.firstSpDate);
    lspTC.text = _formatFromContact(contact.lastSpDate);
    fProjectTC.text = contact.firstProject ?? '';
    lProjectTC.text = contact.lastProject ?? '';

    if ((contact.projectName ?? '').isNotEmpty)
      selectedProject = contact.projectName;
    if ((contact.blokNo ?? '').isNotEmpty) fBlockNoTC.text = contact.blokNo!;

    try {
      print(
        'DEBUG: _fillForm contact.ownerId=${contact.ownerId}, statusProspectId=${contact.statusProspectId}',
      );
    } catch (e) {}

    setState(() {
      selectedSalutation = contact.salutation;
      selectedOwnerId = contact.ownerId;
      selectedProject = contact.firstProject;
      selectedStatusId = contact.statusProspectId;
      selectedSalesExecutiveId = contact.salesExecutiveId;
      selectedSalesManagerId = contact.salesManagerId;

      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        final user = profileState.profile;

        String? findName(int? id) {
          if (id == null) return null;
          if (user.salesPersonId == id) return user.fullName;

          HierarchyNodeEntity? foundSub;
          void searchSub(List<HierarchyNodeEntity> subs) {
            for (var s in subs) {
              if (s.salesPersonId == id) foundSub = s;
              if (foundSub == null && s.subordinates.isNotEmpty)
                searchSub(s.subordinates);
            }
          }

          searchSub(user.subordinates);
          if (foundSub != null) return foundSub!.fullName;

          HierarchyNodeEntity? foundAtasan;
          void searchAtasan(HierarchyNodeEntity? current) {
            while (current != null) {
              if (current.salesPersonId == id) {
                foundAtasan = current;
                break;
              }
              current = current.parent;
            }
          }

          for (var role in user.salesRoles) {
            searchAtasan(role);
            if (foundAtasan != null) break;
          }
          if (foundAtasan != null) return foundAtasan!.fullName;

          return null;
        }

        selectedOwnerName = findName(selectedOwnerId);
        selectedSalesExecutiveName = findName(selectedSalesExecutiveId);
        selectedSalesManagerName = findName(selectedSalesManagerId);
      }

      final statusState = context.read<ProspectStatusBloc>().state;
      if (statusState.status == ProspectStatusEnum.loaded) {
        selectedStatusName = statusState.statuses
            .cast<ProspectStatus?>()
            .firstWhere(
              (e) => e?.statusProspectId == selectedStatusId,
              orElse: () => null,
            )
            ?.statusProspectName;
      }
      // Auto-fill property controllers from property_groups if provided in detail response
      try {
        final groups = contact.propertyGroupsJson as List<dynamic>?;
        if (groups != null) {
          for (final g in groups) {
            final props = (g['contact_properties'] as List<dynamic>?) ?? [];
            for (final p in props) {
              final pid = p['property_id'];
              final val = p['property_value'];
              if (pid != null) {
                _propertyControllers.putIfAbsent(
                  pid,
                  () => TextEditingController(),
                );
                if (val != null)
                  _propertyControllers[pid]!.text = val.toString();
              }
            }
          }
        }
      } catch (e) {
        // ignore parsing errors
      }

      // Fallback: some APIs return properties in `properties_json` instead of `property_groups`.
      // Try parsing that and populate controllers as well.
      try {
        final pj = contact.propertiesJson;
        if (pj != null) {
          dynamic parsed;
          if (pj is String) {
            parsed = jsonDecode(pj);
          } else {
            parsed = pj;
          }

          if (parsed is List) {
            for (final p in parsed) {
              try {
                final pid = p['property_id'] ?? p['id'];
                final val =
                    p['property_value'] ?? p['value'] ?? p['propertyValue'];
                if (pid != null) {
                  final id = int.tryParse(pid.toString()) ?? pid as int;
                  _propertyControllers.putIfAbsent(
                    id,
                    () => TextEditingController(),
                  );
                  if (val != null)
                    _propertyControllers[id]!.text = val.toString();
                }
              } catch (_) {}
            }
          } else if (parsed is Map) {
            // map keyed by property id: {"23": "City"}
            parsed.forEach((k, v) {
              try {
                final id = int.tryParse(k.toString());
                if (id != null) {
                  _propertyControllers.putIfAbsent(
                    id,
                    () => TextEditingController(),
                  );
                  if (v != null) _propertyControllers[id]!.text = v.toString();
                }
              } catch (_) {}
            });
          }
        }
      } catch (e) {
        // ignore
      }

      // Auto-fill sales information based on ownerId
      if (selectedOwnerId != null) {
        final profileState = context.read<ProfileBloc>().state;
        if (profileState is ProfileLoaded) {
          _updateSalesInformation(selectedOwnerId!, profileState.profile);
        } else {
          // If profile not loaded yet, schedule update after profile loads via listener
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ps = context.read<ProfileBloc>().state;
            if (ps is ProfileLoaded)
              _updateSalesInformation(selectedOwnerId!, ps.profile);
          });
        }
      }
    });
  }

  void _autoFillFromProfile() {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      final user = profileState.profile;

      if (widget.args.page == 0) {
        if (user.subordinates.isEmpty) {
          setState(() {
            selectedOwnerId = user.salesPersonId;
            selectedOwnerName = user.fullName;
          });
          _updateSalesInformation(user.salesPersonId!, user);
        }
      }
    }
  }

  void _updateSalesInformation(int ownerId, UserProfileEntity user) {
    List<HierarchyNodeEntity> chain = [];

    // 1. Helper to find path in subordinates
    List<HierarchyNodeEntity>? findPath(
      List<HierarchyNodeEntity> nodes,
      int id,
    ) {
      for (var node in nodes) {
        if (node.salesPersonId == id) return [node];
        var subPath = findPath(node.subordinates, id);
        if (subPath != null) return [node, ...subPath];
      }
      return null;
    }

    // 2. Check if owner is a subordinate
    var subordinatePath = findPath(user.subordinates, ownerId);
    if (subordinatePath != null) {
      // Chain: [User, Sub1, Sub2, ..., Owner]
      // We create a mock node for the current user to include them in the chain
      final userNode = HierarchyNodeEntity(
        salesPersonId: user.salesPersonId!,
        fullName: user.fullName,
        positionName: user.positionName,
      );
      chain = [userNode, ...subordinatePath];
    } else if (user.salesPersonId == ownerId) {
      // 3. Case: Selecting themselves. Chain: [User, Boss, Grandboss...]
      final userNode = HierarchyNodeEntity(
        salesPersonId: user.salesPersonId!,
        fullName: user.fullName,
        positionName: user.positionName,
      );
      chain = [userNode];

      if (user.salesRoles.isNotEmpty) {
        HierarchyNodeEntity? current = user.salesRoles.first.parent;
        while (current != null) {
          chain.add(current);
          current = current.parent;
        }
      }
    } else {
      // 4. Case: Maybe owner is a superior? Search in salesRoles parent chain
      for (var role in user.salesRoles) {
        HierarchyNodeEntity? current = role;
        List<HierarchyNodeEntity> temp = [];
        bool found = false;
        while (current != null) {
          temp.add(current);
          if (current.salesPersonId == ownerId) {
            found = true;
            break;
          }
          current = current.parent;
        }
        if (found) {
          chain = temp;
          break;
        }
      }
    }

    setState(() {
      salesInfoFields.clear();
      if (chain.isNotEmpty) {
        // The user wants Owner first, then bosses?
        // Example: "Devisari (SE) -> Siti (SS) -> Gleydy (SM) -> Radithya (GM)"
        // Our 'chain' is [Root, ..., Owner] if subordinate, or [Owner, ..., Boss] if self/superior.
        // Let's normalize it to [Owner, Boss, Grandboss...]

        List<HierarchyNodeEntity> displayChain;
        if (subordinatePath != null) {
          // It was [User, ..., Owner]. Reverse it.
          displayChain = chain.reversed.toList();
        } else {
          // It was [Owner, Boss, ...]. Keep it.
          displayChain = chain;
        }

        for (var node in displayChain) {
          salesInfoFields.add({
            'label': node.positionName ?? 'Sales',
            'name': node.fullName,
            'id': node.salesPersonId,
          });
        }

        // Map to specific API roles for the form params
        // Owner is always Executive
        selectedSalesExecutiveId = ownerId;
        selectedSalesExecutiveName = displayChain.first.fullName;

        // Find Team from the owner node if possible
        selectedTeamId = displayChain.first.salesTeamId;

        selectedSupervisorId = null;
        selectedSalesManagerId = null;
        selectedSalesManagerName = null;

        if (displayChain.length > 1) {
          // Supervisor is the immediate boss
          selectedSupervisorId = displayChain[1].salesPersonId;

          // Manager is the first person with "Manager" in position
          for (int i = 1; i < displayChain.length; i++) {
            if (displayChain[i].positionName?.toLowerCase().contains(
                  "manager",
                ) ??
                false) {
              selectedSalesManagerId = displayChain[i].salesPersonId;
              selectedSalesManagerName = displayChain[i].fullName;
              break;
            }
          }
          // Fallback manager
          if (selectedSalesManagerId == null) {
            selectedSalesManagerId = displayChain[1].salesPersonId;
            selectedSalesManagerName = displayChain[1].fullName;
          }
        }
      }
    });
  }

  void dispose() {
    fullNameTC.dispose();
    emailTC.dispose();
    phoneTC.dispose();
    waTC.dispose();
    fBlockNoTC.dispose();
    FPProductTC.dispose();
    FPCategoryTC.dispose();
    salesExecutiveTC.dispose();
    salesManagerTC.dispose();
    generalNotesTC.dispose();

    fullNameFN.dispose();
    emailFN.dispose();
    phoneFN.dispose();
    waFN.dispose();
    fBlockNoFN.dispose();
    FPProducttFN.dispose();
    FPCategorytFN.dispose();
    salesExecutiveFN.dispose();
    salesManagerFN.dispose();
    generalNotesFN.dispose();
    fProjectTC.dispose();
    lProjectTC.dispose();
    fspTC.dispose();
    lspTC.dispose();
    sumberInfoTC.dispose();

    LPProducttFN.dispose();
    LPCategorytFN.dispose();
    lBlockNoFN.dispose();
    noKTPFN.dispose();
    ktpAddressFN.dispose();
    sumberInfoFN.dispose();
    volumePlanFN.dispose();
    vCountFN.dispose();
    firstVisitorDateFN.dispose();
    lastVisitorDateFN.dispose();
    firstApptDateFN.dispose();
    lastApptDateFN.dispose();
    dealValueFN.dispose();
    reserveDateFN.dispose();
    lossReasonNoteFN.dispose();
    fspFN.dispose();
    lspFN.dispose();
    fProjectFN.dispose();
    lProjectFN.dispose();
    sumberInformationFN.dispose();
    for (final c in _propertyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    final today = DateHelper.formatNumericCompact(DateTime.now());

    // Auto-fill first-date fields for new contacts
    if (widget.args.page == 0 || widget.args.data == null) {
      if (firstApptDateTC.text.isEmpty) firstApptDateTC.text = today;
      if (firstVisitorDateTC.text.isEmpty) firstVisitorDateTC.text = today;
      if (fspTC.text.isEmpty) fspTC.text = today;
    }

    final List<Map<String, dynamic>> propertiesJson = [];
    _propertyControllers.forEach((propertyId, controller) {
      final val = controller.text;
      if (val.isNotEmpty) {
        propertiesJson.add({'property_id': propertyId, 'property_value': val});
      }
    });

    final params = CreateContactParams(
      salutation: selectedSalutation ?? '',
      salesExecutiveId: selectedSalesExecutiveId,
      salesManagerId: selectedSalesManagerId,
      salesSupervisorId: selectedSupervisorId,
      salesTeamId: selectedTeamId,
      salesChannelId: selectedChannelId,
      statusProspectId: selectedStatusId,
      sumberInformasi2: selectedSumberInformasi,
      generalNotes: generalNotesTC.text.isNotEmpty ? generalNotesTC.text : null,
      propertiesJson: propertiesJson.isNotEmpty ? propertiesJson : null,

      fullName: fullNameTC.text,
      primaryEmail: emailTC.text,
      primaryPhone: phoneTC.text,
      whatsappNumber: waTC.text,
      firstBlokNo: fBlockNoTC.text,
      firstProduct: FPProductTC.text,
      firstProjectCategory: FPCategoryTC.text,
      firstProject: fProjectTC.text,
      lastProject: lProjectTC.text,
      lastProduct: LPProducttTC.text,
      lastProjectCategory: LPCategorytTC.text,
      lastBlokNo: lBlockNoTC.text,
      noKtp: noKTPTC.text,
      ktpAddress: ktpAddressTC.text,
      volumePlan: volumePlanTC.text,
      visitCount: vCountTC.text.isNotEmpty ? int.tryParse(vCountTC.text) : null,
      firstVisitDate: firstVisitorDateTC.text,
      lastVisitDate: lastVisitorDateTC.text,
      firstApptDate: firstApptDateTC.text,
      lastApptDate: lastApptDateTC.text,
      dealValue: dealValueTC.text,
      reserveDate: reserveDateTC.text,
      lossReasonNote: lossReasonNoteTC.text,
      firstSPDate: fspTC.text,
      lastSPDate: lspTC.text,
    );

    if (widget.args.page == 1) {
      context.read<ContactBloc>().add(
        UpdateContactEvent(widget.args.data!.contactId, params),
      );
    } else {
      context.read<ContactBloc>().add(CreateContactEvent(params));
    }
  }

  DateTime _parseDateOrToday(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    // Try ISO parse first
    try {
      return DateTime.parse(value);
    } catch (_) {}
    // Try dd/MM/yyyy
    try {
      return DateFormat('dd/MM/yyyy').parse(value);
    } catch (_) {}
    return DateTime.now();
  }

  String _formatFromContact(dynamic v) {
    if (v == null) return '';
    if (v is DateTime) return DateHelper.formatNumericCompact(v);
    if (v is String) {
      // try ISO
      try {
        final dt = DateTime.parse(v);
        return DateHelper.formatNumericCompact(dt);
      } catch (_) {}
      // try dd/MM/yyyy
      try {
        final dt = DateFormat('dd/MM/yyyy').parse(v);
        return DateHelper.formatNumericCompact(dt);
      } catch (_) {}
      return v;
    }
    try {
      return DateHelper.formatNumericCompact(DateTime.parse(v.toString()));
    } catch (_) {
      return v.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactBloc, ContactState>(
      listener: (context, state) {
        if (state.status == ContactStatus.creating) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        } else if (state.status == ContactStatus.createSuccess) {
          context.pop(); // Close loading
          context.read<ContactBloc>().add(
            const FetchContactsEvent(isRefresh: true),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact created successfully')),
          );
          context.pop(); // Go back
        } else if (state.status == ContactStatus.detailLoaded &&
            state.contactDetail != null) {
          _fillForm(state.contactDetail!);
        } else if (state.status == ContactStatus.error) {
          context.pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error creating contact'),
            ),
          );
        }
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded && widget.args.page == 0) {
                _autoFillFromProfile();
              }
            },
          ),
          BlocListener<ProspectStatusBloc, ProspectStatusState>(
            listener: (context, state) {
              if (state.status == ProspectStatusEnum.loaded &&
                  widget.args.page != 0) {
                final contact =
                    context.read<ContactBloc>().state.contactDetail ??
                    widget.args.data;
                if (contact != null) _fillForm(contact);
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (profileState is ProfileLoaded &&
                widget.args.page == 0 &&
                selectedOwnerId == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _autoFillFromProfile();
              });
            }
            return Scaffold(
              body: SafeArea(child: _createContact(profileState)),
            );
          },
        ),
      ),
    );
  }

  Widget _createContact(ProfileState profileState) {
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
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(primaryColor),
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.args.page == 1 ? "Edit Contact" : "Create Contact",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _handleSave(),
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
                      _buildField(
                        label: "Full Name",
                        controller: fullNameTC,
                        focusNode: fullNameFN,
                      ),
                      _buildFieldDown(
                        label: "Salutation",
                        value: selectedSalutation ?? "Select Salutation",
                        onTap: () async {
                          final items = [
                            OwnerDropdownItem(id: 1, name: 'Mr.'),
                            OwnerDropdownItem(id: 2, name: 'Mrs.'),
                          ];
                          final result = await context.pushNamed(
                            'detailContactDropdown',
                            extra: ContactDropdownArgs(
                              title: 'Pilih Salutation',
                              items: items,
                              selectedId: selectedSalutation == 'Mrs.'
                                  ? 2
                                  : selectedSalutation == 'Mr.'
                                  ? 1
                                  : null,
                            ),
                          );
                          if (result != null) {
                            final sel = result as OwnerDropdownItem;
                            setState(() {
                              selectedSalutation = sel.name;
                            });
                          }
                        },
                      ),
                      _buildFieldDown(
                        label: "Owner",
                        value: selectedOwnerName,
                        onTap: () async {
                          if (profileState is ProfileLoaded) {
                            final user = profileState.profile;
                            // Build list: user + all subordinates flat
                            final List<OwnerDropdownItem> ownerItems = [];
                            ownerItems.add(
                              OwnerDropdownItem(
                                id: user.salesPersonId,
                                name: user.fullName,
                                subtitle: user.positionName,
                              ),
                            );
                            void addSubs(List<HierarchyNodeEntity> subs) {
                              for (var s in subs) {
                                ownerItems.add(
                                  OwnerDropdownItem(
                                    id: s.salesPersonId,
                                    name: s.fullName,
                                    subtitle: s.positionName,
                                  ),
                                );
                                if (s.subordinates.isNotEmpty)
                                  addSubs(s.subordinates);
                              }
                            }

                            addSubs(user.subordinates);

                            if (ownerItems.length == 1) {
                              // Only self, no selection needed
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Anda tidak memiliki bawahan untuk dipilih.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final result = await context.pushNamed(
                              'detailContactDropdown',
                              extra: ContactDropdownArgs(
                                title: 'Pilih Owner',
                                items: ownerItems,
                                selectedId: selectedOwnerId,
                              ),
                            );
                            if (result != null) {
                              final owner = result as OwnerDropdownItem;
                              setState(() {
                                selectedOwnerId = owner.id;
                                selectedOwnerName = owner.name;
                              });
                              _updateSalesInformation(owner.id ?? 0, user);
                            }
                          }
                        },
                      ),

                      _buildField(
                        label: "Email",
                        controller: emailTC,
                        focusNode: emailFN,
                        fieldType: 'text',
                      ),
                      _buildField(
                        label: "Phone",
                        controller: phoneTC,
                        focusNode: phoneFN,
                        fieldType: 'int',
                      ),
                      _buildField(
                        label: "Whatsapp",
                        controller: waTC,
                        focusNode: waFN,
                        fieldType: 'int',
                      ),
                      _buildField(
                        label: "First Project",
                        controller: fProjectTC,
                        focusNode: fProjectFN,
                      ),
                      _buildField(
                        label: "Last Project",
                        controller: lProjectTC,
                        focusNode: lProjectFN,
                      ),
                      _buildFieldDown(
                        label: "Status Prospect",
                        value: selectedStatusName,
                        onTap: () async {
                          final statusState = context
                              .read<ProspectStatusBloc>()
                              .state;
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
                                  selectedStatusName =
                                      picked.statusProspectName;
                                });
                              }
                            }
                          } else {
                            // If statuses not loaded, trigger fetch and show a simple snackbar
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
                      ),

                      _buildField(
                        label: "First Project Product",
                        controller: FPProductTC,
                        focusNode: FPProducttFN,
                      ),
                      _buildField(
                        label: "Las Project Product",
                        controller: LPProducttTC,
                        focusNode: LPProducttFN,
                      ),
                      _buildField(
                        label: "First Project Category",
                        controller: FPCategoryTC,
                        focusNode: FPCategorytFN,
                      ),
                      _buildField(
                        label: "Last Project Category",
                        controller: LPCategorytTC,
                        focusNode: LPCategorytFN,
                      ),
                      _buildField(
                        label: "First Block No",
                        controller: fBlockNoTC,
                        focusNode: fBlockNoFN,
                        fieldType: 'int',
                      ),
                      _buildField(
                        label: "Last Block No",
                        controller: lBlockNoTC,
                        focusNode: lBlockNoFN,
                        fieldType: 'int',
                      ),
                      _buildField(
                        label: "General Notes",
                        controller: generalNotesTC,
                        focusNode: generalNotesFN,
                      ),
                      _buildField(
                        label: "No KTP",
                        controller: noKTPTC,
                        focusNode: noKTPFN,
                        fieldType: 'int',
                      ),
                      _buildField(
                        label: "KTP Address",
                        controller: ktpAddressTC,
                        focusNode: ktpAddressFN,
                      ),

                      _buildField(
                        label: "Sumber Informasi",
                        controller: sumberInfoTC,
                        focusNode: sumberInfoFN,
                      ),

                      _buildField(
                        label: "Volume Plan",
                        controller: volumePlanTC,
                        focusNode: volumePlanFN,
                        fieldType: 'int',
                      ),
                      _buildField(
                        label: "First Appt Date",
                        controller: firstApptDateTC,
                        focusNode: firstApptDateFN,
                        fieldType: 'date',
                      ),
                      _buildField(
                        label: "Last Appt Date",
                        controller: lastApptDateTC,
                        focusNode: lastApptDateFN,
                        fieldType: 'date',
                      ),

                      _buildField(
                        label: "Visitor Count",
                        controller: vCountTC,
                        focusNode: vCountFN,
                        fieldType: 'int',
                      ),

                      _buildField(
                        label: "First Visitor Date",
                        controller: firstVisitorDateTC,
                        focusNode: firstVisitorDateFN,
                        fieldType: 'date',
                      ),
                      _buildField(
                        label: "Last Visitor Date",
                        controller: lastVisitorDateTC,
                        focusNode: lastVisitorDateFN,
                        fieldType: 'date',
                      ),
                      _buildField(
                        label: "First SP Date",
                        controller: fspTC,
                        focusNode: fspFN,
                        fieldType: 'date',
                      ),
                      _buildField(
                        label: "Last SP Date",
                        controller: lspTC,
                        focusNode: lspFN,
                        fieldType: 'date',
                      ),

                      _buildField(
                        label: "Deal Value",
                        controller: dealValueTC,
                        focusNode: dealValueFN,
                        fieldType: 'int',
                      ),
                      _buildField(
                        label: "Reserve Date",
                        controller: reserveDateTC,
                        focusNode: reserveDateFN,
                        fieldType: 'date',
                      ),
                      _buildField(
                        label: "Loss Reason Note",
                        controller: lossReasonNoteTC,
                        focusNode: lossReasonNoteFN,
                      ),

                      // // Dynamic property groups: render each group separately
                      BlocBuilder<
                        ContactPropertiesBloc,
                        ContactPropertiesState
                      >(
                        builder: (context, state) {
                          if (state.status == ContactPropertiesStatus.loading) {
                            return const SizedBox.shrink();
                          }
                          if (state.status == ContactPropertiesStatus.error) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Failed to load properties: ${state.errorMessage}',
                              ),
                            );
                          }

                          final groups = state.groups
                              .where(
                                (g) =>
                                    g.name != 'sales_information' &&
                                    g.name != 'contact_information',
                              )
                              .toList();

                          return Column(
                            children: groups.map((group) {
                              return CustomDropdownGroupContact(
                                hint: group.label,
                                child: Column(
                                  children: group.properties.map((prop) {
                                    _propertyControllers.putIfAbsent(
                                      prop.propertyId,
                                      () => TextEditingController(),
                                    );

                                    if (prop.fieldType == 'date') {
                                      return _buildField(
                                        label: prop.label,
                                        controller:
                                            _propertyControllers[prop
                                                .propertyId]!,
                                        focusNode: FocusNode(),
                                        fieldType: 'date',
                                      );
                                    }

                                    if (prop.fieldType == 'number') {
                                      return _buildField(
                                        label: prop.label,
                                        controller:
                                            _propertyControllers[prop
                                                .propertyId]!,
                                        focusNode: FocusNode(),
                                        fieldType: 'int',
                                      );
                                    }

                                    if (prop.fieldType == 'file') {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _buildFieldDown(
                                                label: prop.label,
                                                value:
                                                    _propertyControllers[prop
                                                            .propertyId]!
                                                        .text
                                                        .isEmpty
                                                    ? null
                                                    : _propertyControllers[prop
                                                              .propertyId]!
                                                          .text,
                                                onTap: () {},
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () async {
                                                // pick image/file and upload
                                                final picker = ImagePicker();
                                                final XFile? file = await picker
                                                    .pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                    );
                                                if (file == null) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Uploading...',
                                                    ),
                                                  ),
                                                );
                                                final url = await _uploadFile(
                                                  File(file.path),
                                                );
                                                if (url != null) {
                                                  _propertyControllers[prop
                                                              .propertyId]!
                                                          .text =
                                                      url;
                                                  setState(() {});
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Upload successful',
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Upload failed',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Upload'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    // default text
                                    return _buildField(
                                      label: prop.label,
                                      controller:
                                          _propertyControllers[prop
                                              .propertyId]!,
                                      focusNode: FocusNode(),
                                    );
                                  }).toList(),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                CustomDropdownGroupContact(
                  hint: "Sales Information",
                  child: Column(
                    children: [
                      if (salesInfoFields.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Pilih owner untuk melihat informasi sales",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ...salesInfoFields
                          .map(
                            (field) => _buildFieldDown(
                              label: field['label'] ?? "Sales",
                              value: field['name'],
                              onTap: null,
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldDown({
    required String label,
    String? value,
    VoidCallback? onTap,
  }) {
    final isEmpty = value == null || value.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: Color(whiteColor),
          border: Border(
            bottom: BorderSide(width: 1, color: Color(grey10Color)),
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
                      color: isEmpty ? Color(grey2Color) : Color(blackColor),
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String fieldType = 'text',
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Color(whiteColor),
        border: Border(bottom: BorderSide(width: 1, color: Color(grey10Color))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    // Date field: open date picker and fill controller
                    if (fieldType == 'date') {
                      return GestureDetector(
                        onTap: () async {
                          focusNode.unfocus();
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _parseDateOrToday(controller.text),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            controller.text = DateHelper.formatNumericCompact(
                              picked,
                            );
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(blackColor),
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              label: Text(
                                label,
                                style: TextStyle(fontSize: 12),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      );
                    }

                    // Integer field: restrict to digits
                    if (fieldType == 'int') {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(blackColor),
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          label: Text(label, style: TextStyle(fontSize: 12)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      );
                    }

                    // Default: text input
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(blackColor),
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        label: Text(label, style: TextStyle(fontSize: 12)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
