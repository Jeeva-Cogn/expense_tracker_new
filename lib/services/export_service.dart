import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

/// Service for exporting expense data to various formats
class ExportService {
  static final _dateFormat = DateFormat('dd-MMM-yyyy');
  static final _currencyFormat = NumberFormat.currency(symbol: '₹');

  /// Export expenses to PDF format
  static Future<void> exportToPDF(List<Expense> expenses, {
    String? title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Calculate totals
      final totalAmount = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      final categoryTotals = <String, double>{};
      for (var expense in expenses) {
        categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
      }
      
      // Sort expenses by date (newest first)
      expenses.sort((a, b) => b.date.compareTo(a.date));
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 2, color: PdfColors.grey300)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      title ?? 'Expense Report',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Generated on ${_dateFormat.format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                    ),
                    if (startDate != null && endDate != null) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Period: ${_dateFormat.format(startDate)} to ${_dateFormat.format(endDate)}',
                        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                      ),
                    ],
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Summary Section
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Summary',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Transactions:', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('${expenses.length}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Amount:', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text(
                          _currencyFormat.format(totalAmount),
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Category Breakdown
              if (categoryTotals.isNotEmpty) ...[
                pw.Text(
                  'Category Breakdown',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Percentage', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Data rows
                    ...categoryTotals.entries.map((entry) => pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(entry.key),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_currencyFormat.format(entry.value)),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${(entry.value / totalAmount * 100).toStringAsFixed(1)}%'),
                        ),
                      ],
                    )).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
              
              // Transaction Details
              pw.Text(
                'Transaction Details',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              // Transactions table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.5),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Title', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                  // Data rows
                  ...expenses.map((expense) => pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(_dateFormat.format(expense.date), style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(_currencyFormat.format(expense.amount), style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(expense.category, style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          expense.title.length > 40 
                              ? '${expense.title.substring(0, 40)}...' 
                              : expense.title,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    ],
                  )).toList(),
                ],
              ),
            ];
          },
        ),
      );
      
      // Save and share the PDF
      final output = await getTemporaryDirectory();
      final fileName = 'expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'Expense Report - ${expenses.length} transactions, Total: ${_currencyFormat.format(totalAmount)}',
        subject: title ?? 'Expense Report',
      );
      
    } catch (e) {
      print('Error exporting to PDF: $e');
      throw Exception('Failed to export PDF: ${e.toString()}');
    }
  }
  
  /// Export expenses to Excel format
  static Future<void> exportToExcel(List<Expense> expenses, {
    String? title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Expense Report'];
      
      // Remove default sheet
      excel.delete('Sheet1');
      
      // Sort expenses by date
      expenses.sort((a, b) => b.date.compareTo(a.date));
      
      // Headers
      final headers = ['Date', 'Amount (₹)', 'Category', 'Title', 'Note', 'SMS Source', 'Wallet ID', 'Type'];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          horizontalAlign: HorizontalAlign.Center,
        );
      }
      
      // Data rows
      for (int i = 0; i < expenses.length; i++) {
        final expense = expenses[i];
        final rowIndex = i + 1;
        
        final data = [
          _dateFormat.format(expense.date),
          expense.amount,
          expense.category,
          expense.title,
          expense.note ?? '',
          expense.smsSource ?? '',
          expense.walletId ?? '',
          expense.type == ExpenseType.income ? 'Income' : expense.type == ExpenseType.expense ? 'Expense' : 'Transfer',
        ];
        
        for (int j = 0; j < data.length; j++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex));
          
          if (j == 1) {
            // Amount column
            cell.value = DoubleCellValue(data[j] as double);
            cell.cellStyle = CellStyle(
              numberFormat: NumFormat.standard_2,
            );
          } else {
            cell.value = TextCellValue(data[j].toString());
          }
        }
      }
      
      // Add summary at the bottom
      final summaryRow = expenses.length + 2;
      final totalAmount = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRow)).value = TextCellValue('TOTAL');
      final totalCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: summaryRow));
      totalCell.value = DoubleCellValue(totalAmount);
      totalCell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.yellow,
        numberFormat: NumFormat.standard_2,
      );
      
      // Auto-fit columns
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 15);
      }
      
      // Save and share the Excel file
      final output = await getTemporaryDirectory();
      final fileName = 'expense_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${output.path}/$fileName');
      final bytes = excel.save();
      await file.writeAsBytes(bytes!);
      
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'Expense Report - ${expenses.length} transactions, Total: ${_currencyFormat.format(totalAmount)}',
        subject: title ?? 'Expense Report',
      );
      
    } catch (e) {
      print('Error exporting to Excel: $e');
      throw Exception('Failed to export Excel: ${e.toString()}');
    }
  }
  
  /// Export expenses to CSV format (lightweight alternative)
  static Future<void> exportToCSV(List<Expense> expenses) async {
    try {
      final output = await getTemporaryDirectory();
      final fileName = 'expense_report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${output.path}/$fileName');
      
      // Sort expenses by date
      expenses.sort((a, b) => b.date.compareTo(a.date));
      
      // Create CSV content
      final csvContent = StringBuffer();
      
      // Headers
      csvContent.writeln('Date,Amount,Category,Title,Note,SMS Source,Wallet ID,Type');
      
      // Data rows
      for (var expense in expenses) {
        final row = [
          _dateFormat.format(expense.date),
          expense.amount.toString(),
          expense.category,
          '"${expense.title.replaceAll('"', '""')}"', // Escape quotes
          '"${(expense.note ?? '').replaceAll('"', '""')}"', // Escape quotes
          expense.smsSource ?? '',
          expense.walletId ?? '',
          expense.type == ExpenseType.income ? 'Income' : expense.type == ExpenseType.expense ? 'Expense' : 'Transfer',
        ];
        csvContent.writeln(row.join(','));
      }
      
      await file.writeAsString(csvContent.toString());
      
      final totalAmount = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'Expense Report (CSV) - ${expenses.length} transactions, Total: ${_currencyFormat.format(totalAmount)}',
        subject: 'Expense Report CSV',
      );
      
    } catch (e) {
      print('Error exporting to CSV: $e');
      throw Exception('Failed to export CSV: ${e.toString()}');
    }
  }
  
  /// Get export statistics
  static Map<String, dynamic> getExportStats(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return {
        'totalTransactions': 0,
        'totalAmount': 0.0,
        'categoryBreakdown': <String, double>{},
        'dateRange': null,
      };
    }
    
    final totalAmount = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final categoryTotals = <String, double>{};
    
    for (var expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    expenses.sort((a, b) => a.date.compareTo(b.date));
    final dateRange = {
      'start': expenses.first.date,
      'end': expenses.last.date,
    };
    
    return {
      'totalTransactions': expenses.length,
      'totalAmount': totalAmount,
      'categoryBreakdown': categoryTotals,
      'dateRange': dateRange,
      'formattedTotal': _currencyFormat.format(totalAmount),
    };
  }
}
