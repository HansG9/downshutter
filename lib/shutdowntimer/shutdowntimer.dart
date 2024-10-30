import 'package:downshutter/shutdowntimer/digit.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

class ShutdownTimer extends StatefulWidget {
  final Function(int, int) shutdownTimerChange;
  final Function() onPlayOrPause;
  final Function() onReset;
  final Color fgColor;
  final int shutdownTimerH;
  final int shutdownTimerM;
  final bool shutdownTimerActivated;

  const ShutdownTimer({
    required this.shutdownTimerChange,
    required this.onPlayOrPause,
    required this.onReset,
    required this.fgColor,
    required this.shutdownTimerH,
    required this.shutdownTimerM,
    required this.shutdownTimerActivated,
    super.key,
  });

  @override
  State<ShutdownTimer> createState() => _ShutdownTimerState();
}

class _ShutdownTimerState extends State<ShutdownTimer> {
  @override
  Widget build(BuildContext context) {
    Function(int, int) shutdownTimerChange = widget.shutdownTimerChange;
    Function() onPlayOrPause = widget.onPlayOrPause;
    Function() onReset = widget.onReset;
    Color fgColor = widget.fgColor;
    int shutdownTimerH = widget.shutdownTimerH;
    int shutdownTimerM = widget.shutdownTimerM;
    bool shutdownTimerActivated = widget.shutdownTimerActivated;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: SystemTheme.accentColor.dark,
        ),
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 5,
                left: 12,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Shutdowntimer",
                  style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Digit(
                  fgColor: fgColor,
                  shutdownTimerChange: shutdownTimerChange,
                  shutdownTimerDigit: shutdownTimerH,
                  hnm: 0,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(3, 0, 3, 32),
                  child: SizedBox(
                    height: 70,
                    child: Text(
                      ":",
                      style: TextStyle(
                        fontSize: 54,
                        color: fgColor,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Digit(
                  fgColor: fgColor,
                  shutdownTimerChange: shutdownTimerChange,
                  shutdownTimerDigit: shutdownTimerM,
                  hnm: 1,
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 22,
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 63,
                      width: 63,
                      child: Tooltip(
                        message: shutdownTimerActivated
                            ? 'Stop timer'
                            : 'Start timer',
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
                          onPressed: onPlayOrPause,
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: SystemTheme.accentColor.light,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.zero),
                          child: Icon(
                            shutdownTimerActivated
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 32,
                            color: fgColor,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 8,
                      ),
                    ),
                    SizedBox(
                      height: 63,
                      width: 63,
                      child: Tooltip(
                        message: 'Reset timer',
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: fgColor,
                        ),
                        preferBelow: true,
                        textStyle: TextStyle(
                          color: SystemTheme.accentColor.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        waitDuration: const Duration(seconds: 1),
                        child: ElevatedButton(
                          onPressed: onReset,
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: SystemTheme.accentColor.light,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.zero),
                          child: Icon(
                            Icons.replay_rounded,
                            size: 32,
                            color: fgColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
