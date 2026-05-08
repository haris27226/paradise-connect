import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:progress_group/core/network/dio_client.dart';
import 'package:progress_group/features/attandance/data/datasource/attendance_remote_datasource.dart';
import 'package:progress_group/features/attandance/domain/repositories/attandance_repository.dart';
import 'package:progress_group/features/attandance/domain/usecase/get_attendance.dart';
import 'package:progress_group/features/attandance/domain/usecase/get_locations.dart';
import 'package:progress_group/features/attandance/domain/usecase/submit_attendance.dart';
import 'package:progress_group/features/attandance/domain/usecase/submit_attendance_activity.dart';
import 'package:progress_group/features/attandance/presentation/state/attandance/attendance_bloc.dart';
import 'package:progress_group/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:progress_group/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:progress_group/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:progress_group/features/auth/domain/usecase/forgot_password_usecase.dart';
import 'package:progress_group/features/auth/domain/usecase/get_remember_me_usecase.dart';
import 'package:progress_group/features/auth/domain/usecase/login_usecase.dart';
import 'package:progress_group/features/auth/domain/usecase/get_profile_usecase.dart';
import 'package:progress_group/features/auth/domain/usecase/reset_password_usecase.dart';
import 'package:progress_group/features/auth/presentation/state/auth/auth_bloc.dart';
import 'package:progress_group/features/auth/presentation/state/profile/profile_bloc.dart';
import 'package:progress_group/features/contact/domain/usecases/activity/create_activity_visit_usecase.dart';
import 'package:progress_group/features/contact/domain/usecases/activity/get_activity_prospect_status_usecase.dart';
import 'package:progress_group/features/contact/domain/usecases/activity/get_whatsapp_activity_usecase.dart';
import 'package:progress_group/features/contact/domain/usecases/attachment/delete_attachment_usecase.dart';
import 'package:progress_group/features/contact/domain/usecases/attachment/get_attachments.dart';
import 'package:progress_group/features/contact/domain/usecases/attachment/update_attachment_usecase.dart';
import 'package:progress_group/features/contact/domain/usecases/contact/delete_contact_usecase.dart';
import 'package:progress_group/features/contact/domain/usecases/contact/update_contact_usecase.dart';
import 'package:progress_group/features/contact/presentation/state/attachment/attachment_cubit.dart';
import 'package:progress_group/features/contact/presentation/state/whatsapp_activity/whatsapp_unread_summary_bloc.dart';
import 'package:progress_group/features/home/domain/usecases/get_report_whatsapp_usecase.dart';
import 'package:progress_group/features/home/presentation/state/report-whatsapp/report_bloc.dart';
import 'package:progress_group/features/inbox/data/datasources/inbox_remote_datasource.dart';
import 'package:progress_group/features/inbox/data/datasources/message_remote_datasource.dart';
import 'package:progress_group/features/inbox/domain/repositories/inbox_contact_repo_impl.dart';
import 'package:progress_group/features/inbox/domain/repositories/message_repository.dart';
import 'package:progress_group/features/inbox/domain/usecases/get_messages_usecase.dart';
import 'package:progress_group/features/inbox/domain/usecases/get_qr_session_usecase.dart';
import 'package:progress_group/features/inbox/domain/usecases/get_whatsapp_devices_usecase.dart';
import 'package:progress_group/features/inbox/domain/usecases/inbox_contact_usecase.dart';
import 'package:progress_group/features/inbox/presentation/state/inbox/inbox_block.dart';
import 'package:progress_group/features/inbox/presentation/state/whatsapp_device/whatsapp_device_bloc.dart';
import 'package:progress_group/features/inbox/presentation/state/whatsapp_qr/whatsapp_qr_bloc.dart';
import 'package:progress_group/features/inbox/presentation/state/message/message_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'core/utils/theme.dart';
import 'features/home/data/datasources/report_remote_datasource.dart';
import 'features/home/domain/repositories/report_whatsapp_repository.dart';
import 'features/contact/data/datasources/contact_remote_datasource.dart';
import 'features/contact/domain/repositories/contact_repository_impl.dart';
import 'features/contact/domain/usecases/contact/get_contacts_usecase.dart';
import 'features/contact/domain/usecases/contact/get_contact_detail_usecase.dart';
import 'features/contact/domain/usecases/contact/create_contact_usecase.dart';
import 'features/contact/presentation/state/contact/contact_bloc.dart';
import 'features/contact/domain/usecases/activity/get_activities_usecase.dart';
import 'features/contact/domain/usecases/activity/create_activity_usecase.dart';
import 'features/contact/presentation/state/activity/activity_bloc.dart';
import 'features/contact/domain/usecases/prospect/get_prospect_statuses_usecase.dart';
import 'features/contact/domain/usecases/contact/get_contact_properties_usecase.dart';
import 'features/contact/presentation/state/contact_properties/contact_properties_bloc.dart';
import 'features/contact/presentation/state/prospect_status/prospect_status_bloc.dart';
import 'features/contact/domain/usecases/attachment/get_attachment_types_usecase.dart';
import 'features/contact/presentation/state/attachment_type/attachment_type_bloc.dart';
import 'features/contact/domain/usecases/attachment/upload_attachment_usecase.dart';
import 'features/contact/presentation/state/attachment/upload_attachment_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  final prefs = await SharedPreferences.getInstance();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final localDataSource = AuthLocalDataSourceImpl(prefs);
    final dioClient = DioClient(localDataSource);
    final remoteDataSource = AuthRemoteDataSourceImpl(dioClient.dio);
    final repository = AuthRepositoryImpl(remoteDataSource, localDataSource);

    final loginUseCase = LoginUseCase(repository);
    final forgotPasswordUseCase = ForgotPasswordUseCase(repository);
    final getRememberMeUseCase = GetRememberMeUseCase(repository);
    final resetPasswordUsecase = ResetPasswordUsecase(repository);
    final getProfileUseCase = GetProfileUseCase(repository);

    final inboxRemoteDataSource = InboxContactRemoteDataSourceImpl(dioClient.dio);
    final inboxRepository = InboxContactRepositoryImpl(inboxRemoteDataSource);
    final getInboxContactsUsecase = GetInboxContactsUsecase(inboxRepository);
    final getWhatsappDevicesUsecase = GetWhatsappDevicesUsecase(inboxRepository);
    final getQrSessionUsecase = GetQrSessionUsecase(inboxRepository);

    final messageRemoteDataSource = MessageRemoteDataSourceImpl(dioClient.dio);
    final messageRepository = MessageRepositoryImpl(messageRemoteDataSource);
    final getMessagesUseCase = GetMessagesUseCase(messageRepository);

    final reportRemoteDataSource = ReportRemoteDataSourceImpl(dioClient.dio);
    final reportRepository = ReportRepositoryImpl(reportRemoteDataSource);
    final getVolumeReportUseCase = GetVolumeReportUseCase(reportRepository);

    final contactRemoteDataSource = ContactRemoteDataSourceImpl(dioClient.dio);
    final contactRepository = ContactRepositoryImpl(contactRemoteDataSource);
    final getContactsUseCase = GetContactsUseCase(contactRepository);
    final getContactDetailUseCase = GetContactDetailUseCase(contactRepository);
    final getProspectStatusesUseCase = GetProspectStatusesUseCase(contactRepository);
    final getActivitiesUseCase = GetActivitiesUseCase(contactRepository);
    final createActivityUseCase = CreateActivityUseCase(contactRepository);
    final createContactUseCase = CreateContactUseCase(contactRepository);
    final updateContactUseCase = UpdateContactUseCase(contactRepository);
    final deleteContactUseCase = DeleteContactUseCase(contactRepository);
    final getContactPropertiesUseCase = GetContactPropertiesUseCase(contactRepository);

    final getAttachmentTypesUseCase = GetAttachmentTypesUseCase(contactRepository);
    final uploadAttachmentUseCase = UploadAttachmentUseCase(contactRepository);
    final getAttachmentsUseCase = GetAttachments(contactRepository);
    final deleteAttachmentUseCase = DeleteAttachmentUseCase(contactRepository);
    final updateAttachmentUseCase = UpdateAttachmentUseCase(contactRepository);
    final createActivityVisitUseCase = CreateActivityVisitUseCase(contactRepository);
    final getActivityProspectStatusUseCase = GetActivityProspectStatusUseCase(contactRepository);
    final getWhatsappActivityUseCase =  GetWhatsappUnreadSummaryUseCase(contactRepository);

    final attendanceRemoteDataSource = AttendanceRemoteDataSourceImpl(dioClient.dio);
    final attendanceRepository = AttendanceRepositoryImpl(attendanceRemoteDataSource);
    final getAttendanceUseCase = GetAttendanceUseCase(attendanceRepository);
    final getLocationsUseCase = GetLocationsUseCase(attendanceRepository);
    final submitAttendanceUseCase = SubmitAttendanceUseCase(attendanceRepository);
    final submitAttendanceActivityUseCase = SubmitAttendanceActivityUseCase(attendanceRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(loginUseCase: loginUseCase,forgotPasswordUseCase: forgotPasswordUseCase,getRememberMeUseCase: getRememberMeUseCase,resetPasswordUsecase: resetPasswordUsecase)),
        BlocProvider(create: (_) => InboxContactBloc(getInboxContactsUsecase)),
        BlocProvider(create: (_) => WhatsappDeviceBloc(getWhatsappDevicesUsecase)),
        BlocProvider(create: (_) => WhatsappQrBloc(getQrSessionUsecase)),
        BlocProvider(create: (_) => ProfileBloc(getProfileUseCase: getProfileUseCase)),
        BlocProvider(create: (_) => MessageBloc(getMessagesUseCase)),
        BlocProvider(create: (_) => ReportBloc(getVolumeReportUseCase)),
        BlocProvider(create: (_) => ContactBloc(getContactsUseCase: getContactsUseCase,createContactUseCase: createContactUseCase,updateContactUseCase: updateContactUseCase,deleteContactUseCase: deleteContactUseCase,getContactDetailUseCase: getContactDetailUseCase)),
        BlocProvider(create: (_) => ProspectStatusBloc(getProspectStatusesUseCase: getProspectStatusesUseCase)),
        BlocProvider(create: (_) => ContactPropertiesBloc(getContactPropertiesUseCase: getContactPropertiesUseCase)),
        BlocProvider(create: (_) => ActivityBloc(getActivitiesUseCase: getActivitiesUseCase,createActivityUseCase: createActivityUseCase)),
        BlocProvider(create: (_) => NotifActivityBloc(getActivitiesUseCase: getActivitiesUseCase,createActivityUseCase: createActivityUseCase)),
        BlocProvider(create: (_) => ActivityVisitBloc(createActivityVisitUseCase)),
        BlocProvider(create: (_) => AttachmentTypeBloc(getAttachmentTypesUseCase)),
        BlocProvider(create: (_) => UploadAttachmentBloc(uploadAttachmentUseCase,updateAttachmentUseCase )),
        BlocProvider(create: (_) => AttachmentCubit(getAttachmentsUseCase, deleteAttachmentUseCase)),
        BlocProvider(create: (_) => ActivityProspectStatusBloc(getActivityProspectStatusUseCase)),
        BlocProvider(create: (_) => AttendanceBloc(getAttendanceUseCase: getAttendanceUseCase,getLocationsUseCase: getLocationsUseCase,submitAttendanceUseCase: submitAttendanceUseCase,submitAttendanceActivityUseCase: submitAttendanceActivityUseCase,)),
        BlocProvider(create: (_) => WhatsappActivityBloc(getWhatsappActivityUseCase)),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
