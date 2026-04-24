import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/core/utils/widget/custom_header.dart';
import '../../state/owner/owner_bloc.dart';
import '../../state/owner/owner_event.dart';
import '../../state/owner/owner_state.dart';

class OwnerSelectionPage extends StatefulWidget {
  final int? selectedOwnerId;

  const OwnerSelectionPage({super.key, this.selectedOwnerId});

  @override
  State<OwnerSelectionPage> createState() => _OwnerSelectionPageState();
}

class _OwnerSelectionPageState extends State<OwnerSelectionPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<OwnerBloc>();
      if (bloc.state.status == OwnerStatus.initial) {
        bloc.add(const FetchOwnersEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<OwnerBloc>().add(const FetchOwnersEvent(isLoadMore: true));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            customHeader(context, 'Select Owner'),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<OwnerBloc>().add(SearchOwnersEvent(value));
                },
                decoration: InputDecoration(
                  hintText: 'Search Owner...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(grey10Color)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(grey10Color)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(primaryColor)),
                  ),
                ),
              ),
            ),

            Expanded(
              child: BlocBuilder<OwnerBloc, OwnerState>(
                builder: (context, state) {
                  if (state.status == OwnerStatus.loading && state.owners.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state.status == OwnerStatus.error && state.owners.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.errorMessage ?? 'Error loading owners'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              context.read<OwnerBloc>().add(const FetchOwnersEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final owners = state.owners;

                  if (owners.isEmpty && state.status == OwnerStatus.loaded) {
                    return const Center(child: Text('No owners found.'));
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.hasReachedMax ? owners.length + 1 : owners.length + 2,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          title: const Text('All Owners'),
                          trailing: widget.selectedOwnerId == null
                              ? Icon(Icons.check, color: Color(primaryColor))
                              : null,
                          onTap: () => context.pop(null),
                        );
                      }

                      if (index > owners.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final owner = owners[index - 1];
                      final isSelected = owner.salesPersonId == widget.selectedOwnerId;

                      return ListTile(
                        title: Text(owner.fullName),
                        subtitle: owner.salesPersonCode != null ? Text(owner.salesPersonCode!) : null,
                        trailing: isSelected
                            ? Icon(Icons.check, color: Color(primaryColor))
                            : null,
                        onTap: () => context.pop(owner),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
