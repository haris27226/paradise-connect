import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/core/utils/widget/custom_header.dart';
import '../../state/sales_manager/sales_manager_bloc.dart';
import '../../state/sales_manager/sales_manager_event.dart';
import '../../state/sales_manager/sales_manager_state.dart';

class SalesManagerSelectionPage extends StatefulWidget {
  final int? selectedSalesManagerId;

  const SalesManagerSelectionPage({super.key, this.selectedSalesManagerId});

  @override
  State<SalesManagerSelectionPage> createState() => _SalesManagerSelectionPageState();
}

class _SalesManagerSelectionPageState extends State<SalesManagerSelectionPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<SalesManagerBloc>();
      if (bloc.state.status == SalesManagerStatus.initial) {
        bloc.add(const FetchSalesManagersEvent());
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
      context.read<SalesManagerBloc>().add(const FetchSalesManagersEvent(isLoadMore: true));
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
            customHeader(context, 'Select Sales Manager'),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<SalesManagerBloc>().add(SearchSalesManagersEvent(value));
                },
                decoration: InputDecoration(
                  hintText: 'Search Sales Manager...',
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
              child: BlocBuilder<SalesManagerBloc, SalesManagerState>(
                builder: (context, state) {
                  if (state.status == SalesManagerStatus.loading && state.salesManagers.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state.status == SalesManagerStatus.error && state.salesManagers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.errorMessage ?? 'Error loading sales managers'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              context.read<SalesManagerBloc>().add(const FetchSalesManagersEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final managers = state.salesManagers;

                  if (managers.isEmpty && state.status == SalesManagerStatus.loaded) {
                    return const Center(child: Text('No sales managers found.'));
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.hasReachedMax ? managers.length : managers.length + 1,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      if (index >= managers.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final manager = managers[index];
                      final isSelected = manager.salesPersonId == widget.selectedSalesManagerId;

                      return ListTile(
                        title: Text(manager.fullName),
                        subtitle: manager.salesPersonCode != null ? Text(manager.salesPersonCode!) : null,
                        trailing: isSelected
                            ? Icon(Icons.check, color: Color(primaryColor))
                            : null,
                        onTap: () => context.pop(manager),
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
