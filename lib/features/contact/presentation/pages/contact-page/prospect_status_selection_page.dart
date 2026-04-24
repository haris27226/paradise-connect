import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/core/utils/widget/custom_header.dart';
import '../../state/prospect_status/prospect_status_bloc.dart';
import '../../state/prospect_status/prospect_status_state.dart';

class ProspectStatusSelectionPage extends StatelessWidget {
  final int? selectedStatusId;

  const ProspectStatusSelectionPage({super.key, this.selectedStatusId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            customHeader(context, 'Select Status'),
            Expanded(
              child: BlocBuilder<ProspectStatusBloc, ProspectStatusState>(
                builder: (context, state) {
                  if (state.status == ProspectStatusEnum.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == ProspectStatusEnum.error) {
                    return Center(child: Text(state.errorMessage ?? 'Error loading statuses'));
                  }

                  final statuses = state.statuses;

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: statuses.length + 1,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          title: const Text('All Statuses'),
                          trailing: selectedStatusId == null
                              ? Icon(Icons.check, color: Color(primaryColor))
                              : null,
                          onTap: () => context.pop(null),
                        );
                      }

                      final prospectStatus = statuses[index - 1];
                      final isSelected = prospectStatus.statusProspectId == selectedStatusId;

                      return ListTile(
                        title: Text(prospectStatus.statusProspectName),
                        trailing: isSelected
                            ? Icon(Icons.check, color: Color(primaryColor))
                            : null,
                        onTap: () => context.pop(prospectStatus),
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
