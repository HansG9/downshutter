import 'package:flutter/material.dart';
import 'package:hold_down_button/hold_down_button.dart';
import 'package:system_theme/system_theme.dart';

class ShutdownTimerChangeBtn extends StatefulWidget {
  final Function(int, int) shutdownTimerChange;
  final int hnm;
  final int value;
  final Color fgColor;

  const ShutdownTimerChangeBtn({
    required this.shutdownTimerChange,
    required this.hnm,
    required this.value,
    required this.fgColor,
    super.key,
  });

  @override
  State<ShutdownTimerChangeBtn> createState() => _ShutdownTimerChangeBtnState();
}

class _ShutdownTimerChangeBtnState extends State<ShutdownTimerChangeBtn> {
  @override
  Widget build(BuildContext context) {
    Function(int, int) shutdownTimerChange = widget.shutdownTimerChange;
    int hnm = widget.hnm;
    int value = widget.value;
    Color fgColor = widget.fgColor;

    return SizedBox(
      width: 63,
      child: Tooltip(
        message:
            '${value > 0 ? "Increase" : "Decrease"} ${hnm == 0 ? "Hours" : "Minutes"}',
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: fgColor,
        ),
        preferBelow: value < 0,
        textStyle: TextStyle(
          color: SystemTheme.accentColor.accent,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        waitDuration: const Duration(seconds: 1),
        child: HoldDownButton(
          onHoldDown: () {
            shutdownTimerChange(hnm, value);
          },
          child: ElevatedButton(
            onPressed: () {
              shutdownTimerChange(hnm, value);
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: SystemTheme.accentColor.light,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Icon(
              value > 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: fgColor,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
