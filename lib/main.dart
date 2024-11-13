import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cron/cron.dart';
import 'package:downshutter/daily_shutdown/daily_shutdown.dart';
import 'package:downshutter/shutdowntimer/shutdowntimer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

bool firstStart = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await windowManager.ensureInitialized();
  await WindowsSingleInstance.ensureSingleInstance(
    [""],
    "downshutter",
    onSecondWindow: (p0) {
      if (firstStart) {
        firstStart = false;
        doWhenWindowReady(() {});
      }
      windowManager.show();
      windowManager.focus();
    },
  );

  SystemTheme.fallbackColor = const Color(0xFFFF9800);
  await SystemTheme.accentColor.load();

  runApp(const MyApp());
  /*doWhenWindowReady(() {*/
  const initialSize = Size(300, 480);

  appWindow.size = initialSize;
  appWindow.minSize = initialSize;
  appWindow.maxSize = initialSize;
  //appWindow.alignment = Alignment.center;

  windowManager.setAlignment(Alignment.center);

  /*windowManager.setSize(initialSize);
  windowManager.setMaximumSize(initialSize);
  windowManager.setMinimumSize(initialSize);
  windowManager.setAlignment(Alignment.center);

  windowManager.setResizable(false);
  windowManager.setMinimizable(false);*/

  windowManager.setAlwaysOnTop(true);
  //windowManager.setAsFrameless();
  /*});*/
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'downshutter',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xFF282828,
          <int, Color>{
            50: Color.fromRGBO(90, 90, 90, 1),
            100: Color.fromRGBO(80, 80, 80, 1),
            200: Color.fromRGBO(70, 70, 70, 1),
            300: Color.fromRGBO(60, 60, 60, 1),
            400: Color.fromRGBO(50, 50, 50, 1),
            500: Color.fromRGBO(40, 40, 40, 1),
            600: Color.fromRGBO(30, 30, 30, 1),
            700: Color.fromRGBO(20, 20, 20, 1),
            800: Color.fromRGBO(10, 10, 10, 1),
            900: Color.fromRGBO(0, 0, 0, 1),
          },
        ),
        fontFamily: "NotoSans",
      ),
      home: const MyHomePage(title: 'downshutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  /*bool _toogleTrayIcon = true;
  bool _toogleMenu = true;*/
  bool shutdown = false;
  late Timer shutdownTimFinal;
  RangeValues rangeValues = const RangeValues(1, 8);
  bool shutdownActivated = true;
  Cron cron = Cron();
  Color fgColor = (SystemTheme.accentColor.accent.red +
              SystemTheme.accentColor.accent.blue +
              SystemTheme.accentColor.accent.green) <
          383
      ? const Color(0xffe6e6e6)
      : const Color(0xff191919);

  int shutdownTimerH = 0;
  int shutdownTimerM = 0;
  bool shutdownTimerActivated = false;
  late Timer shutdownTimer;

  //bool firstStart = true;

  @override
  void initState() {
    super.initState();
    initSystemTray();
    windowManager.addListener(this);
    Window.setEffect(
      effect: WindowEffect.transparent,
      //color: SystemTheme.accentColor.accent,
      //effect: WindowEffect.aero,
    );

    init();

    windowManager.blur();
  }

  @override
  void onWindowBlur() {
    if (!shutdown) {
      windowManager.hide();
    }
  }

  @override
  void onWindowFocus() {
    debugPrint("focused");
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();

    rangeValues = RangeValues(
        prefs.getDouble("rangeValuesStart") ?? rangeValues.start,
        prefs.getDouble("rangeValuesEnd") ?? rangeValues.end);

    shutdownActivated = prefs.getBool("shutdownActivated") ?? true;

    shutdownTimerH = prefs.getInt("shutdownTimerH") ?? 0;
    shutdownTimerM = prefs.getInt("shutdownTimerM") ?? 0;

    setState(() {});

    cronReStart();
  }

  void shutdownFinal(int duration) {
    showWindow();

    setState(() {
      shutdown = true;
    });
    debugPrint("shutdownTriggered");
    shutdownTimFinal = Timer(Duration(minutes: duration), () async {
      if (shutdown) {
        await Process.run('shutdown', ["-s"]);
      }
    });
  }

  void cronReStart() {
    cron.close();
    cron = Cron();
    cron.schedule(
        Schedule.parse(
            "*/30 ${rangeValues.start.toInt()}-${rangeValues.end.toInt()} * * *"),
        () async {
      if (shutdownActivated) {
        shutdownFinal(5);
      }
    });
  }

  void showWindow() {
    if (firstStart) {
      firstStart = false;
      doWhenWindowReady(() {});
    }
    windowManager.show();
    windowManager.focus();
    setState(
      () {},
    );
  }

  Future<void> initSystemTray() async {
    String path = Platform.isWindows ? 'assets/g952.ico' : 'assets/g952.png';

    final SystemTray systemTray = SystemTray();

    // We first init the systray menu
    await systemTray.initSystemTray(
      title: "downshutter",
      iconPath: path,
    );

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
      //debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        showWindow();
      } else if (eventName == kSystemTrayEventRightClick) {
        showWindow();
      }
    });
  }

  Future<void> shutdownTimerChange(int hnm, int value) async {
    if (hnm == 0 &&
        (shutdownTimerH < 99 || value < 0) &&
        (shutdownTimerH > 0 || value > 0)) {
      setState(() {
        shutdownTimerH += value;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("shutdownTimerH", shutdownTimerH);
    } else if (hnm == 1 &&
        (shutdownTimerM < 59 || value < 0) &&
        (shutdownTimerM > 0 || value > 0)) {
      setState(() {
        shutdownTimerM += value;
        //save;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("shutdownTimerM", shutdownTimerM);
    }
  }

  void runShutdownTimer() {
    if (shutdownTimerM == 1 && shutdownTimerH == 0) {
      shutdownFinal(1);
    } else {
      setState(() {
        shutdownTimerActivated = true;
      });

      shutdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        setState(() {
          shutdownTimerM = --shutdownTimerM % 60;
        });
        debugPrint("tick");

        if (shutdownTimerH == 0 && shutdownTimerM <= 5) {
          timer.cancel();
          setState(() {
            shutdownTimerActivated = false;
          });

          shutdownFinal(shutdownTimerM);
        } else if (shutdownTimerH != 0 && shutdownTimerM == 59) {
          setState(() {
            shutdownTimerH--;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    fgColor = (SystemTheme.accentColor.accent.red +
                SystemTheme.accentColor.accent.blue +
                SystemTheme.accentColor.accent.green) <
            383
        ? const Color(0xffe6e6e6)
        : const Color(0xff191919);
    /*Window.setEffect(
      effect: WindowEffect.solid,
      color: SystemTheme.accentColor.accent,
      //effect: WindowEffect.aero,
    );*/

    if (shutdown) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            DragToMoveArea(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.red,
                ),
                height: 500,
                width: 300,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DragToMoveArea(
                      child: Text(
                        "Your PC is about to shut down!",
                        style: TextStyle(
                            color: fgColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          shutdownTimFinal.cancel();
                          shutdown = false;
                          debugPrint("shutdownCanceled");
                        });
                        //windowManager.blur();
                        windowManager.hide();

                        final prefs = await SharedPreferences.getInstance();
                        shutdownTimerH = prefs.getInt("shutdownTimerH") ?? 0;
                        shutdownTimerM = prefs.getInt("shutdownTimerM") ?? 0;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fgColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.all(12),
                      ), //Colors.red),
                      child: const Text(
                        "Cancel shutdown!",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            DragToMoveArea(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: SystemTheme.accentColor.accent,
                ),
                height: 500,
                width: 300,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DragToMoveArea(
                      child: Text(
                        "Welcome back!",
                        style: TextStyle(
                          fontSize: 32,
                          color: fgColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    DailyShutdown(
                      onCheckChange: (value) async {
                        setState(() {
                          shutdownActivated = value!;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool(
                            "shutdownActivated", shutdownActivated);
                      },
                      onRangeChange: (value) async {
                        setState(() {
                          rangeValues = RangeValues(value.start.roundToDouble(),
                              value.end.roundToDouble());
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble(
                            "rangeValuesStart", rangeValues.start);
                        await prefs.setDouble(
                            "rangeValuesEnd", rangeValues.end);
                        cronReStart();
                      },
                      shutdownActivated: shutdownActivated,
                      fgColor: fgColor,
                      rangeValues: rangeValues,
                    ),
                    ShutdownTimer(
                      shutdownTimerChange: shutdownTimerChange,
                      onPlayOrPause: () {
                        if (shutdownTimerActivated) {
                          shutdownTimer.cancel();
                          setState(() {
                            shutdownTimerActivated = false;
                          });
                        } else if (shutdownTimerM > 0 || shutdownTimerH > 0) {
                          runShutdownTimer();
                        }
                      },
                      onReset: () async {
                        final prefs = await SharedPreferences.getInstance();
                        int tempShutdownTimerH =
                            prefs.getInt("shutdownTimerH") ?? 0;
                        int tempShutdownTimerM =
                            prefs.getInt("shutdownTimerM") ?? 0;

                        if (tempShutdownTimerH == shutdownTimerH &&
                            tempShutdownTimerM == shutdownTimerM &&
                            !shutdownTimerActivated) {
                          setState(() {
                            shutdownTimerH = 0;
                            shutdownTimerM = 0;
                          });
                        } else {
                          setState(() {
                            shutdownTimerH = tempShutdownTimerH;
                            shutdownTimerM = tempShutdownTimerM;
                          });
                        }

                        await prefs.setInt("shutdownTimerH", shutdownTimerH);
                        await prefs.setInt("shutdownTimerM", shutdownTimerM);

                        if (shutdownTimerActivated) {
                          shutdownTimer.cancel();
                          setState(() {
                            shutdownTimerActivated = false;
                          });
                        }
                      },
                      fgColor: fgColor,
                      shutdownTimerH: shutdownTimerH,
                      shutdownTimerM: shutdownTimerM,
                      shutdownTimerActivated: shutdownTimerActivated,
                    ),
                    Tooltip(
                      message: 'Close',
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: fgColor,
                      ),
                      preferBelow: false,
                      textStyle: TextStyle(
                        color: SystemTheme.accentColor.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      waitDuration: const Duration(seconds: 1),
                      child: ElevatedButton(
                        onPressed: () {
                          windowManager.hide();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 0,
                            minimumSize: const Size(60, 20),
                            maximumSize: const Size(60, 20),
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.zero),
                        child: Icon(
                          Icons.close_rounded,
                          color: fgColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
