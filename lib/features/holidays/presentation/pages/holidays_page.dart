import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizagrana/features/holidays/data/holidays_service.dart';
import 'package:organizagrana/features/holidays/domain/calendar_day.dart';
import 'package:organizagrana/features/holidays/domain/calendar_month.dart';
import 'package:organizagrana/features/holidays/domain/holidays_failure.dart';
import 'package:organizagrana/features/holidays/presentation/widgets/holiday_edit_dialog.dart';
import 'package:organizagrana/shared/layout/page_content_constraint.dart';

class HolidaysPage extends StatefulWidget {
  const HolidaysPage({super.key, required this.service});

  final HolidaysService service;

  @override
  State<HolidaysPage> createState() => _HolidaysPageState();
}

class _HolidaysPageState extends State<HolidaysPage> {
  late DateTime _currentMonth;
  CalendarMonth? _calendarMonth;
  bool _isLoading = false;
  HolidaysFailure? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final calendar = await widget.service.getCalendar(_currentMonth.year, _currentMonth.month);
      if (mounted) setState(() => _calendarMonth = calendar);
    } on HolidaysFailure catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _calendarMonth = null;
    });
    _loadCalendar();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _calendarMonth = null;
    });
    _loadCalendar();
  }

  int get _startOffset {
    final wd = DateTime(_currentMonth.year, _currentMonth.month).weekday;
    return wd % 7;
  }

  Future<void> _onDayTap(CalendarDay day) async {
    if (day.holiday) {
      await _onHolidayTap(day);
      return;
    }

    final result = await showHolidayEditDialog(context, day, day.override);
    if (result == null || !mounted) return;

    try {
      if (result is HolidayEditDelete) {
        await widget.service.deleteOverride(day.overrideId!);
      } else if (result is HolidayEditSave) {
        if (day.hasOverride) {
          await widget.service.updateOverride(day.overrideId!, result.holiday, result.name);
        } else {
          await widget.service.createOverride(day.date, result.holiday, result.name);
        }
      }
      _loadCalendar();
    } on HolidaysFailure catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  Future<void> _onHolidayTap(CalendarDay day) async {
    final label = DateFormat("d 'de' MMMM", 'pt_BR').format(day.date);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: Text(
          day.hasOverride
              ? 'Remover override e voltar ao comportamento padrão?'
              : 'Marcar este feriado como dia útil?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(day.hasOverride ? 'Remover' : 'Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      if (day.hasOverride) {
        await widget.service.deleteOverride(day.overrideId!);
      } else {
        await widget.service.createOverride(day.date, false, null);
      }
      _loadCalendar();
    } on HolidaysFailure catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'pt_BR').format(_currentMonth);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: PageContentConstraint(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MonthHeader(
              label: monthLabel,
              onPrev: _prevMonth,
              onNext: _nextMonth,
            ),
            const SizedBox(height: 16),
            _WeekdayHeader(),
            const SizedBox(height: 4),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _ErrorPanel(
                message: _error!.message,
                onRetry: _loadCalendar,
              )
            else if (_calendarMonth != null)
              _CalendarGrid(
                calendarMonth: _calendarMonth!,
                startOffset: _startOffset,
                onDayTap: _onDayTap,
              ),
            const SizedBox(height: 24),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
          tooltip: 'Mês anterior',
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
          tooltip: 'Próximo mês',
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  static const _labels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Row(
      children: _labels
          .map(
            (l) => Expanded(
              child: Center(child: Text(l, style: style)),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.calendarMonth,
    required this.startOffset,
    required this.onDayTap,
  });

  final CalendarMonth calendarMonth;
  final int startOffset;
  final void Function(CalendarDay) onDayTap;

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[
      for (int i = 0; i < startOffset; i++) const SizedBox.shrink(),
      for (final day in calendarMonth.days) _DayCell(day: day, onTap: onDayTap),
    ];

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final rowCells = cells.sublist(i, (i + 7).clamp(0, cells.length));
      while (rowCells.length < 7) {
        rowCells.add(const SizedBox.shrink());
      }
      rows.add(
        Row(
          children: rowCells.map((c) => Expanded(child: c)).toList(),
        ),
      );
      if (i + 7 < cells.length) rows.add(const SizedBox(height: 4));
    }

    return Column(children: rows);
  }
}

class _CalendarColors {
  static const weekend = Color(0xFFDDE6FF);
  static const holiday = Color(0xFFFFDDD4);
  static const businessDay = Colors.white;
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.onTap});

  final CalendarDay day;
  final void Function(CalendarDay) onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;

    if (day.holiday) {
      bg = _CalendarColors.holiday;
      fg = Colors.black87;
    } else if (day.weekend) {
      bg = _CalendarColors.weekend;
      fg = Colors.black87;
    } else {
      bg = _CalendarColors.businessDay;
      fg = Colors.black87;
    }

    Widget cell = Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onTap(day),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${day.date.day}',
              style: TextStyle(
                color: fg,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );

    if (day.holiday && day.holidayName != null) {
      cell = Tooltip(message: day.holidayName!, child: cell);
    }

    return cell;
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(color: _CalendarColors.businessDay, label: 'Dias Úteis', bordered: true),
        _LegendItem(color: _CalendarColors.weekend, label: 'Finais de Semana'),
        _LegendItem(color: _CalendarColors.holiday, label: 'Feriados'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.bordered = false,
  });

  final Color color;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: bordered ? Border.all(color: cs.outlineVariant) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
