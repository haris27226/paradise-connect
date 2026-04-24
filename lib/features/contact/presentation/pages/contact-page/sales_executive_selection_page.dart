import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/core/utils/widget/custom_header.dart';
import '../../state/sales_executive/sales_executive_bloc.dart';
import '../../state/sales_executive/sales_executive_event.dart';
import '../../state/sales_executive/sales_executive_state.dart';

class SalesExecutiveSelectionPage extends StatefulWidget {
  final int? selectedSalesExecutiveId;

  const SalesExecutiveSelectionPage({super.key, this.selectedSalesExecutiveId});

  @override
  State<SalesExecutiveSelectionPage> createState() => _SalesExecutiveSelectionPageState();
}

class _SalesExecutiveSelectionPageState extends State<SalesExecutiveSelectionPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial fetch if not loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<SalesExecutiveBloc>();
      if (bloc.state.status == SalesExecutiveStatus.initial) {
        bloc.add(const FetchSalesExecutivesEvent());
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
      context.read<SalesExecutiveBloc>().add(const FetchSalesExecutivesEvent(isLoadMore: true));
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
            customHeader(context, 'Select Sales Executive'),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<SalesExecutiveBloc>().add(SearchSalesExecutivesEvent(value));
                },
                decoration: InputDecoration(
                  hintText: 'Search Sales Executive...',
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
              child: BlocBuilder<SalesExecutiveBloc, SalesExecutiveState>(
                builder: (context, state) {
                  if (state.status == SalesExecutiveStatus.loading && state.salesExecutives.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state.status == SalesExecutiveStatus.error && state.salesExecutives.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.errorMessage ?? 'Error loading sales executives'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              context.read<SalesExecutiveBloc>().add(const FetchSalesExecutivesEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final executives = state.salesExecutives;

                  if (executives.isEmpty && state.status == SalesExecutiveStatus.loaded) {
                    return const Center(child: Text('No sales executives found.'));
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.hasReachedMax ? executives.length : executives.length + 1,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      if (index >= executives.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final executive = executives[index];
                      final isSelected = executive.salesPersonId == widget.selectedSalesExecutiveId;

                      return ListTile(
                        title: Text(executive.fullName),
                        subtitle: executive.salesPersonCode != null ? Text(executive.salesPersonCode!) : null,
                        trailing: isSelected
                            ? Icon(Icons.check, color: Color(primaryColor))
                            : null,
                        onTap: () => context.pop(executive),
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
