import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/plugin_management/plugins.dart';
import 'package:netshare/provider/connection_provider.dart';
import 'package:netshare/provider/db_provider.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/ui/navigation_widget.dart';
import 'package:netshare/ui/client/client_widget.dart';
import 'package:netshare/ui/receive/receive_widget.dart';
import 'package:netshare/ui/send/send_widget.dart';
import 'package:netshare/ui/server/server_widget.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:provider/provider.dart';

import 'package:netshare/config/constants.dart';
import 'package:netshare/ui/send/uploading_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPlugins();
  setupDI();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MyApp({super.key});

  final GoRouter _router = GoRouter(
    errorBuilder: (BuildContext context, GoRouterState state) => ErrorWidget(state.error!),
    routes: <GoRoute>[
      GoRoute(
        path: mRootPath,
          redirect: (context, state) {
            if(UtilityFunctions.isMobile) {
              return '/$mClientPath';
            } else {
              return '/$mNavigationPath';
            }
          },
      ),
      GoRoute(
        name: mNavigationPath,
        path: '/$mNavigationPath',
        builder: (context, state) => const NavigationWidget(),
      ),
      GoRoute(
        name: mServerPath,
        path: '/$mServerPath',
        builder: (context, state) => const ServerWidget(),
      ),
      GoRoute(
        name: mClientPath,
        path: '/$mClientPath',
        builder: (context, state) => const ClientWidget(),
          routes: [
            GoRoute(
              name: mSendPath,
              path: mSendPath,
              builder: (BuildContext context, GoRouterState state) => const SendWidget(),
              routes: [
                GoRoute(
                  name: mUploadingPath,
                  path: mUploadingPath,
                  builder: (context, state) => const UploadingWidget(),
                )
              ],
            ),
            GoRoute(
              name: mReceivePath,
              path: mReceivePath,
              builder: (BuildContext context, GoRouterState state) => const ReceiveWidget(),
            ),
          ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FileProvider()),
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),
        ChangeNotifierProvider(create: (context) => ConnectionProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Sharing file in local',
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(color: Colors.blueAccent),
          iconButtonTheme: IconButtonThemeData(style: ButtonStyle(iconColor: MaterialStateProperty.all(Colors.white))),
        ),
        routerConfig: _router,
      ),
    );
  }
}
