import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/core/utils/widget/custom_header.dart';
import 'package:progress_group/core/utils/widget/custom_search_field.dart';
import 'package:progress_group/core/utils/widget/custom_selectbox.dart';
import 'package:progress_group/features/contact/data/models/selectbox_model.dart';
import 'package:progress_group/features/inbox/data/arguments/inbox_detail_args.dart';
import 'package:progress_group/features/inbox/domain/entities/inbox_contact_entity.dart';
import 'package:progress_group/features/inbox/presentation/state/inbox/inbox_block.dart';
import 'package:progress_group/features/inbox/presentation/state/inbox/inbox_event.dart';
import 'package:progress_group/features/inbox/presentation/state/inbox/inbox_statte.dart';
import 'package:progress_group/features/inbox/presentation/state/whatsapp_device/whatsapp_device_bloc.dart';
import 'package:progress_group/features/inbox/presentation/state/whatsapp_qr/whatsapp_qr_bloc.dart';


import '../../../../../core/constants/assets.dart';
import '../../../../../core/utils/widget/custom_button.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  bool isFilterPhone = false;

  final TextEditingController searchTC = TextEditingController();
  final FocusNode searchFN = FocusNode();
  Timer? _debounce;

  late ScrollController _personalScrollController;
  late ScrollController _groupScrollController;
  int _cPage = 1;
  int _gPage = 1;
  bool _isFetchingMore = false;

  @override
  void dispose() {
    _debounce?.cancel();
    searchTC.dispose();
    searchFN.dispose();
    _personalScrollController.dispose();
    _groupScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _personalScrollController = ScrollController()..addListener(_onScroll);
    _groupScrollController = ScrollController()..addListener(_onScroll);
    _fetchInbox();
  }

  void _onScroll() {
    final pc = _personalScrollController;
    final gc = _groupScrollController;
    
    bool isPersonalAtBottom = pc.hasClients && pc.position.pixels >= pc.position.maxScrollExtent - 200;
    bool isGroupAtBottom = gc.hasClients && gc.position.pixels >= gc.position.maxScrollExtent - 200;

    if ((isPersonalAtBottom || isGroupAtBottom) && !_isFetchingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    _isFetchingMore = true;
    _cPage++;
    _gPage++;
    _fetchInbox(isLoadMore: true);
  }

  Future<void> _fetchInbox({String? search, bool isLoadMore = false}) async {
    if (!isLoadMore) {
      _cPage = 1;
      _gPage = 1;
    }
    context.read<InboxContactBloc>().add(GetInboxContactsEvent(
      search: search ?? searchTC.text,
      cPage: _cPage,
      gPage: _gPage,
      isLoadMore: isLoadMore,
    ));
  }


  final List<SelectBoxModel> selectBoxes = [
    SelectBoxModel(items: ['Owner', 'B', 'C'], hint: "Owner"),
    SelectBoxModel(items: ['1', '2', '3'], hint: "Create Date"),
    SelectBoxModel(items: ['X', 'Y', 'Z'], hint: "Status"),
    SelectBoxModel(items: ['A', 'B', 'C'], hint: "Priority"),
    SelectBoxModel(items: ['Open', 'Close'], hint: "State")];

    

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customHeader(context, 'Whatsapp'),
          SizedBox(height: 16),
          // customButton( () {
          //   context.pushNamed('qrScanner', extra: '2d992f7e-19e6-4e98-bdc8-9ee2edb353c2');
          // }, 'Tambah Device'),
          Expanded(
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: customSearchField(
                          controller: searchTC,
                          focusNode: searchFN,
                          onChanged: (value) {
                            if (_debounce?.isActive ?? false) _debounce?.cancel();
                            _debounce = Timer(const Duration(milliseconds: 500), () {
                              _fetchInbox(search: value);
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isFilterPhone = !isFilterPhone;
                            if (isFilterPhone) {
                              context.read<WhatsappDeviceBloc>().add(GetWhatsappDevicesEvent());
                            }
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Color(whiteColor),
                            border: Border.all(color: Color(greenPercentColor), width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(icContactDetailWA,width: 5,height: 5, color: Color(greenPercentColor),)
                        ),
                      ),
                    ],
                  ),
                  if(isFilterPhone)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(whiteColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: BlocBuilder<WhatsappDeviceBloc, WhatsappDeviceState>(
                        builder: (context, state) {
                          if (state is WhatsappDeviceLoading) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          if (state is WhatsappDeviceError) {
                            return Center(child: Text(state.message));
                          }
                          if (state is WhatsappDeviceLoaded) {
                            if (state.devices.isEmpty) {
                              return const Center(child: Text("Tidak ada device"));
                            }
                            return SizedBox(
                              height: 120,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: state.devices.map((device) {
                                    return Column(
                                      children: [
                                        _buildListPhone(
                                          phone: device.whatsappNumber,
                                          name: device.fullName ?? "-",
                                          image: device.status == "CONNECTED" ? icContactDetailWA : icQR,
                                          colorImg: device.status == "CONNECTED"
                                              ? Color(greenPercentColor)
                                              : Color(primaryColor),
                                          onTap: () {
                                            if (device.status != "CONNECTED") {
                                              context.read<WhatsappQrBloc>().add(
                                                    StartQrSessionEvent(device.sessionCode),
                                                  );
                                              _showInboxQRDialog(device.sessionCode);
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectBoxes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = selectBoxes[index];
                        return CustomSelectBox(
                          items: item.items,
                          hints: item.hint,
                          width: 150,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(whiteColor),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Color(shadowColor).withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildTabBar(),
                            Expanded(child: _buildTabBarView()),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildListPhone({required String phone, required String name, required String image, required Color colorImg, required VoidCallback onTap}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              alignment: Alignment.center,
              child: Row(
                children: [
                  Image.asset(icContactDetailPhone,width: 15,height: 15,color: Color(primaryColor),),
                  SizedBox(width: 5),
                  Text(phone,style: TextStyle(color: Color(blackColor),fontSize: 16, fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            Row(
              children: [
                Image.asset(icPerson,width: 15,height: 15,color: Color(primaryColor),),
                SizedBox(width: 5),
                Text(name,style: TextStyle(color: Color(grey7Color),fontSize: 14),),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(whiteColor),
              border: Border.all(color: colorImg, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(image,width: 15,height: 15,color: colorImg,),
          ),
        )
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 30,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, 
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        dividerColor: Colors.transparent, 
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          color: Color(primaryColor), 
          borderRadius: BorderRadius.circular(30),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          Tab(text: "Personal"),
          Tab(text: "Groups"),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return BlocBuilder<InboxContactBloc, InboxContactState>(
      builder: (context, state) {
        if (state is InboxContactLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is InboxContactError) {
          _isFetchingMore = false;
          return Center(child: Text(state.message));
        }
        if (state is InboxContactLoaded) {
          _isFetchingMore = state.isFetchingMore;
          return TabBarView(
            children: [
              _buildList(state.contacts, Icons.person, _personalScrollController, state.isFetchingMore),
              _buildList(state.groups, Icons.group, _groupScrollController, state.isFetchingMore),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildList(List<InboxContact> items, IconData icon, ScrollController controller, bool isFetchingMore) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchInbox,
        child: ListView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Text(
                  "Tidak ada data",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchInbox,
      child: ListView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Container(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final item = items[index];

              return InkWell(
                onTap: () {
                  context.pushNamed(
                    'detailInbox',
                    extra: InboxDetailArgs(
                      data: item,
                      icon: icon,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.photo != null && item.photo!.isNotEmpty
                            ? Image.network(
                                item.photo!,
                                width: 46,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _avatarPlaceholder(icon, item.initials),
                              )
                            : _avatarPlaceholder(icon, item.initials),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150,
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  item.ownerName ?? item.jid,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (item.lastConversationDate != null)
                                  Text(
                                    item.lastConversationDate!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (isFetchingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    ));
  }

  Widget _avatarPlaceholder(IconData icon, String initials) {
    return Container(
      width: 46,
      height: 40,
      decoration: BoxDecoration(
        color: Color(grey1Color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: initials.isNotEmpty
            ? Text(initials, style: TextStyle(color: Color(blue3Color), fontWeight: FontWeight.bold))
            : Icon(icon, size: 24, color: Color(blue3Color)),
      ),
    );
  }
  
  void _showInboxQRDialog(String sessionId) {
    bool hasPopped = false;
    showDialog(
      context: context,
      barrierColor: Colors.black54, 
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), 
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocConsumer<WhatsappQrBloc, WhatsappQrState>(
                listener: (context, state) {
                  if (state is WhatsappQrStreaming && state.status == 'CONNECTED' && !hasPopped) {
                    hasPopped = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('WhatsApp Terhubung!'), backgroundColor: Colors.green),
                    );
                    Navigator.pop(dialogContext); // Tutup dialog
                    
                    // Refresh data setelah terhubung
                    this.context.read<WhatsappDeviceBloc>().add(GetWhatsappDevicesEvent());
                    _fetchInbox();
                  }
                },
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Scan QR Code for", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(grey1Color)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildQrContent(state),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Buka WhatsApp > Perangkat Tertaut > Tautkan Perangkat",textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 16),
                      if (state is WhatsappQrError)
                         Padding(
                           padding: const EdgeInsets.only(bottom: 8.0),
                           child: Text(state.message, style: TextStyle(color: Colors.red, fontSize: 10), textAlign: TextAlign.center),
                         ),
                      customButton((){ Navigator.pop(context); }, "Tutup", colorBg: Color(primaryColor), colorText: Color(whiteColor)),
                      SizedBox(height: 10),
                      customButton((){ 
                        context.read<WhatsappQrBloc>().add(StartQrSessionEvent(sessionId));
                      }, "Refresh QR", colorBg: Color(primaryColor), colorText: Color(whiteColor)),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQrContent(WhatsappQrState state) {
    if (state is WhatsappQrLoading) {
      return SizedBox(
        width: 180,
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state is WhatsappQrStreaming) {
      if (state.qrBase64 != null) {
        return Image.memory(
          base64Decode(state.qrBase64!),
          width: 180,
          height: 180,
          fit: BoxFit.cover,
        );
      }
    }
    return SizedBox(
      width: 180,
      height: 180,
      child: Center(child: Text("Menunggu QR...", style: TextStyle(fontSize: 12, color: Colors.grey))),
    );
  }
}
