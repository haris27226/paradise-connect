import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_group/core/network/dio_client.dart';
import 'package:progress_group/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:go_router/go_router.dart';
import 'package:progress_group/features/contact/domain/entities/create_contact_params.dart';
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
  List<Map<String, dynamic>> salesInfoFields = [];
  final Map<int, TextEditingController> _propertyControllers = {};

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
        context.read<ContactBloc>().add(
          FetchContactDetailEvent(widget.args.data!.contactId),
        );
      });
    }

    // Always ensure master data is loaded for mapping IDs to names
    // Always ensure master data is loaded for mapping IDs to names
    context.read<ProspectStatusBloc>().add(FetchProspectStatusesEvent());
    context.read<ContactPropertiesBloc>().add(FetchContactPropertiesEvent());
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
      selectedOwnerId =
          contact.salesExecutiveId; // In list logic it's often salesExecutiveId
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
    for (final c in _propertyControllers.values) {
      c.dispose();
    }
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
                  onTap: () {
                    // build properties_json from filled property controllers
                    final List<Map<String, dynamic>> propertiesJson = [];
                    _propertyControllers.forEach((propertyId, controller) {
                      final val = controller.text;
                      if (val.isNotEmpty) {
                        propertiesJson.add({
                          'property_id': propertyId,
                          'property_value': val,
                        });
                      }
                    });

                    final params = CreateContactParams(
                      fullName: fullNameTC.text,
                      salutation:
                          selectedSalutation ?? "Mr.", // Default or from state
                      primaryPhone: phoneTC.text,
                      primaryEmail: emailTC.text.isNotEmpty
                          ? emailTC.text
                          : null,
                      whatsappNumber: waTC.text.isNotEmpty ? waTC.text : null,
                      firstProject: selectedProject,
                      firstProduct: FPProductTC.text.isNotEmpty
                          ? FPProductTC.text
                          : null,
                      firstProjectCategory: FPCategoryTC.text.isNotEmpty
                          ? FPCategoryTC.text
                          : null,
                      firstBlokNo: blockNoTC.text.isNotEmpty
                          ? blockNoTC.text
                          : null,
                      salesExecutiveId: selectedSalesExecutiveId,
                      salesManagerId:
                          selectedSalesManagerId ??
                          6, // Use selected or default
                      salesSupervisorId: selectedSupervisorId ?? 73,
                      salesTeamId: selectedTeamId ?? 1,
                      salesChannelId: selectedChannelId ?? 1,
                      statusProspectId: selectedStatusId ?? 1,
                      sumberInformasi2:
                          selectedSumberInformasi ?? "Instagram Ads",
                      generalNotes: generalNotesTC.text.isNotEmpty
                          ? generalNotesTC.text
                          : null,
                      properties: const {"23": "City"},
                      propertiesJson: propertiesJson.isNotEmpty
                          ? propertiesJson
                          : null,
                    );
                    if (widget.args.page == 1 && widget.args.data != null) {
                      // Edit mode: update
                      context.read<ContactBloc>().add(
                        UpdateContactEvent(widget.args.data!.contactId, params),
                      );
                    } else {
                      context.read<ContactBloc>().add(
                        CreateContactEvent(params),
                      );
                    }
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

                      // Render properties from contact_information group (if any)
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

                          final contactGroups = state.groups
                              .where((g) => g.name == 'contact_information')
                              .toList();
                          if (contactGroups.isEmpty)
                            return const SizedBox.shrink();
                          final group = contactGroups.first;

                          return Column(
                            children: group.properties.map((prop) {
                              _propertyControllers.putIfAbsent(
                                prop.propertyId,
                                () => TextEditingController(),
                              );

                              if (prop.fieldType == 'date') {
                                return _buildField(
                                  label: prop.label,
                                  controller:
                                      _propertyControllers[prop.propertyId]!,
                                  focusNode: FocusNode(),
                                  fieldType: 'date',
                                );
                              }

                              if (prop.fieldType == 'number') {
                                return _buildField(
                                  label: prop.label,
                                  controller:
                                      _propertyControllers[prop.propertyId]!,
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
                                          final picker = ImagePicker();
                                          final XFile? file = await picker
                                              .pickImage(
                                                source: ImageSource.gallery,
                                              );
                                          if (file == null) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Uploading...'),
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
                                                content: Text('Upload failed'),
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

                              return _buildField(
                                label: prop.label,
                                controller:
                                    _propertyControllers[prop.propertyId]!,
                                focusNode: FocusNode(),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      // Dynamic property groups: render each group separately
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
                            initialDate:
                                DateTime.tryParse(controller.text) ??
                                DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            controller.text = picked
                                .toIso8601String()
                                .split('T')
                                .first;
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
