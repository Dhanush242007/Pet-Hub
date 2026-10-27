import 'package:intl/intl.dart';

/// Shown to the user, e.g. 05 Mar 2026
String fmtDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

/// Sent to the database, e.g. 2026-03-05
String dbDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);