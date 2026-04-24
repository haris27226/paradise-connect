import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:progress_group/features/contact/domain/entities/create_activity_params.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/utils/widget/custom_header.dart';
import '../../state/activity/activity_bloc.dart';
import '../../state/activity/activity_event.dart';
import '../../state/activity/activity_state.dart';

class ActivityFormPage extends StatefulWidget {
  final int contactId;
  final int? dealId;

  const ActivityFormPage({super.key, required this.contactId, this.dealId});

  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  final TextEditingController notesTC = TextEditingController();
  String selectedActivityType = 'Call';
  DateTime selectedDate = DateTime.now();
  DateTime? nextFollowUpDate;

  final List<String> activityTypes = ['Call', 'Meeting', 'Visit', 'Email', 'Other'];

  @override
  void dispose() {
    notesTC.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isNextFollowUp) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isNextFollowUp ? (nextFollowUpDate ?? DateTime.now()) : selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isNextFollowUp ? (nextFollowUpDate ?? DateTime.now()) : selectedDate),
      );
      if (time != null) {
        setState(() {
          final fullDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
          if (isNextFollowUp) {
            nextFollowUpDate = fullDate;
          } else {
            selectedDate = fullDate;
          }
        });
      }
    }
  }

  void _submit() {
    final params = CreateActivityParams(
      contactId: widget.contactId,
      dealId: widget.dealId,
      activityType: selectedActivityType,
      activityDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate),
      notes: notesTC.text,
      nextFollowUpDate: nextFollowUpDate != null 
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(nextFollowUpDate!) 
          : null,
    );

    context.read<ActivityBloc>().add(CreateActivityEvent(params));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityBloc, ActivityState>(
      listener: (context, state) {
        if (state.status == ActivityStatus.creating) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state.status == ActivityStatus.createSuccess) {
          context.pop(); // Close loading
          context.read<ActivityBloc>().add(FetchActivitiesEvent(contactId: widget.contactId, isRefresh: true));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity created successfully')),
          );
          context.pop(); // Go back
        } else if (state.status == ActivityStatus.error) {
          context.pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error creating activity')),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              customHeader(context, 'Add Activity'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildLabel('Activity Type'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(grey10Color)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedActivityType,
                          isExpanded: true,
                          items: activityTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedActivityType = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Activity Date'),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(grey10Color)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 10),
                            Text(DateFormat('dd MMM yyyy HH:mm').format(selectedDate)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Notes'),
                    TextField(
                      controller: notesTC,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter notes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(grey10Color)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Next Follow Up Date (Optional)'),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(grey10Color)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 10),
                            Text(nextFollowUpDate != null 
                                ? DateFormat('dd MMM yyyy HH:mm').format(nextFollowUpDate!) 
                                : 'Select date...'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Save Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
