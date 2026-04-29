import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:progress_group/core/network/dio_client.dart';
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
import 'package:progress_group/features/contact/domain/usecases/delete_contact_usecase.dart';
import 'package:progress_group/features/contact/domain/usecases/update_contact_usecase.dart';
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
import 'features/contact/data/repositories/contact_repository_impl.dart';
import 'features/contact/domain/usecases/get_contacts_usecase.dart';
import 'features/contact/domain/usecases/get_contact_detail_usecase.dart';
import 'features/contact/domain/usecases/create_contact_usecase.dart';
import 'features/contact/presentation/state/contact/contact_bloc.dart';
import 'features/contact/domain/usecases/get_activities_usecase.dart';
import 'features/contact/domain/usecases/create_activity_usecase.dart';
import 'features/contact/presentation/state/activity/activity_bloc.dart';
import 'features/contact/domain/usecases/get_prospect_statuses_usecase.dart';
import 'features/contact/domain/usecases/get_contact_properties_usecase.dart';
import 'features/contact/presentation/state/contact_properties/contact_properties_bloc.dart';
import 'features/contact/presentation/state/prospect_status/prospect_status_bloc.dart';

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

    final inboxRemoteDataSource = InboxContactRemoteDataSourceImpl(
      dioClient.dio,
    );
    final inboxRepository = InboxContactRepositoryImpl(inboxRemoteDataSource);
    final getInboxContactsUsecase = GetInboxContactsUsecase(inboxRepository);
    final getWhatsappDevicesUsecase = GetWhatsappDevicesUsecase(
      inboxRepository,
    );
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
    final getProspectStatusesUseCase = GetProspectStatusesUseCase(
      contactRepository,
    );
    final getActivitiesUseCase = GetActivitiesUseCase(contactRepository);
    final createActivityUseCase = CreateActivityUseCase(contactRepository);
    final createContactUseCase = CreateContactUseCase(contactRepository);
    final updateContactUseCase = UpdateContactUseCase(contactRepository);
    final deleteContactUseCase = DeleteContactUseCase(contactRepository);
    final getContactPropertiesUseCase = GetContactPropertiesUseCase(
      contactRepository,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: loginUseCase,
            forgotPasswordUseCase: forgotPasswordUseCase,
            getRememberMeUseCase: getRememberMeUseCase,
            resetPasswordUsecase: resetPasswordUsecase,
          ),
        ),
        BlocProvider(create: (_) => InboxContactBloc(getInboxContactsUsecase)),
        BlocProvider(
          create: (_) => WhatsappDeviceBloc(getWhatsappDevicesUsecase),
        ),
        BlocProvider(create: (_) => WhatsappQrBloc(getQrSessionUsecase)),
        BlocProvider(
          create: (_) => ProfileBloc(getProfileUseCase: getProfileUseCase),
        ),
        BlocProvider(create: (_) => MessageBloc(getMessagesUseCase)),
        BlocProvider(create: (_) => ReportBloc(getVolumeReportUseCase)),
        BlocProvider(
          create: (_) => ContactBloc(
            getContactsUseCase: getContactsUseCase,
            createContactUseCase: createContactUseCase,
            updateContactUseCase: updateContactUseCase,
            deleteContactUseCase: deleteContactUseCase,
            getContactDetailUseCase: getContactDetailUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => ProspectStatusBloc(
            getProspectStatusesUseCase: getProspectStatusesUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => ContactPropertiesBloc(
            getContactPropertiesUseCase: getContactPropertiesUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => ActivityBloc(
            getActivitiesUseCase: getActivitiesUseCase,
            createActivityUseCase: createActivityUseCase,
          ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
