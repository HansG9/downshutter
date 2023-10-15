import 'package:downshutter/shutdowntimer/change_btn.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

class Digit extends StatefulWidget {
  final Function(int, int) shutdownTimerChange;
  final Color fgColor;
  final int shutdownTimerDigit;
  final int hnm;

  const Digit({
    required this.shutdownTimerChange,
    required this.fgColor,
    required this.shutdownTimerDigit,
    required this.hnm,
    super.key,
  });

  @override
  State<Digit> createState() => _DigitState();
}

class _DigitState extends State<Digit> {
  @override
  Widget build(BuildContext context) {
    Function(int, int) shutdownTimerChange = widget.shutdownTimerChange;
    Color fgColor = widget.fgColor;
    int shutdownTimerDigit = widget.shutdownTimerDigit;
    int hnm = widget.hnm;

    return SizedBox(
      width: 63,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShutdownTimerChangeBtn(
            shutdownTimerChange: shutdownTimerChange,
            hnm: hnm,
            value: 1,
            fgColor: fgColor,
          ),
          SizedBox(
            height: 62,
            child: Text(
              shutdownTimerDigit.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 54,
                color: fgColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            "${hnm == 0 ? "Hour" : "Minute"}${shutdownTimerDigit != 1 ? "s" : ""}",
            style: TextStyle(
              color: SystemTheme.accentColor.light,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          ShutdownTimerChangeBtn(
            shutdownTimerChange: shutdownTimerChange,
            hnm: hnm,
            value: -1,
            fgColor: fgColor,
          ),
        ],
      ),
    );
  }
}
