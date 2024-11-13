import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';

class DailyShutdown extends StatefulWidget {
  final Function(bool?) onCheckChange;
  final Function(RangeValues) onRangeChange;
  final bool shutdownActivated;
  final RangeValues rangeValues;
  final Color fgColor;

  const DailyShutdown({
    required this.onCheckChange,
    required this.onRangeChange,
    required this.shutdownActivated,
    required this.rangeValues,
    required this.fgColor,
    super.key,
  });

  @override
  State<DailyShutdown> createState() => _DailyShutdownState();
}

class _DailyShutdownState extends State<DailyShutdown> {
  @override
  Widget build(BuildContext context) {
    Function(bool?) onCheckChange = widget.onCheckChange;
    Function(RangeValues) onRangeChange = widget.onRangeChange;
    bool shutdownActivated = widget.shutdownActivated;
    RangeValues rangeValues = widget.rangeValues;
    Color fgColor = widget.fgColor;

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
                  "Daily shutdown",
                  style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: SystemTheme.accentColor.light,
                ),
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Active:",
                        style: TextStyle(
                          color: fgColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: shutdownActivated
                          ? 'Deactivate daily shutdown'
                          : 'Activate daily shutdown',
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
                      child: Checkbox(
                        value: shutdownActivated,
                        activeColor: fgColor,
                        side: BorderSide(color: fgColor, width: 2),
                        checkColor: SystemTheme.accentColor.light,
                        onChanged: (value) {
                          onCheckChange(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 12,
                right: 12,
                bottom: 6,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: SystemTheme.accentColor.light,
                ),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 4,
                        left: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Between:",
                          style: TextStyle(
                            color: fgColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Set shutdown time',
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
                      child: Transform.scale(
                        scale: 1.05,
                        alignment: Alignment.center,
                        child: RangeSlider(
                          activeColor: fgColor,
                          overlayColor:
                              const WidgetStatePropertyAll(Colors.transparent),
                          values: rangeValues,
                          min: 0,
                          max: 23,
                          divisions: 23,
                          onChanged: (value) {
                            !shutdownActivated ? null : onRangeChange(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              shutdownActivated
                  ? "${rangeValues.start.toInt().toString().padLeft(2, '0')}:00  -  ${rangeValues.end.toInt().toString().padLeft(2, '0')}:00"
                  : "inactive",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.w700,
                fontSize: 34,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
