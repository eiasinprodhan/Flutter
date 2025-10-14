// lib/services/pdf_service.dart

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction.dart' as model;

class PdfService {
  static Future<Uint8List> generateTransactionReport({
    required List<model.Transaction> transactions,
    required String dateRange,
    required String filterType,
  }) async {
    final doc = pw.Document();

    double totalCredit = 0;
    double totalDebit = 0;
    for (var t in transactions) {
      if (t.isCredit) {
        totalCredit += t.amount ?? 0;
      } else {
        totalDebit += t.amount ?? 0;
      }
    }
    final double netBalance = totalCredit - totalDebit;
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 20.0),
            child: pw.Column(
              children: [
                pw.Text('Transaction Report',
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(fontWeight: pw.FontWeight.bold, fontSize: 20)),
                pw.SizedBox(height: 8),
                pw.Text('Date Range: $dateRange'),
                pw.Text('Filter: $filterType Transactions'),
                pw.Divider(thickness: 1),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)),
          );
        },
        build: (pw.Context context) => [
          _buildTransactionTable(transactions, currencyFormat),
          pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
          pw.SizedBox(height: 20),
          _buildSummary(
            totalCredit,
            totalDebit,
            netBalance,
            transactions.length,
            currencyFormat,
          ),
        ],
      ),
    );

    return doc.save();
  }

  // --- FIX IS HERE: THIS METHOD IS CORRECTED ---
  static pw.Widget _buildTransactionTable(List<model.Transaction> transactions, NumberFormat currencyFormat) {
    const tableHeaders = ['Date', 'Description', 'Type', 'Amount'];

    // Helper to create styled cells
    pw.Widget cell(String text, {pw.Alignment align = pw.Alignment.centerLeft, bool isHeader = false}) {
      return pw.Container(
        alignment: align,
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(
          text,
          style: isHeader
              ? pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)
              : const pw.TextStyle(fontSize: 10),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(4),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(3),
      },
      children: [
        // Header Row with its own decoration
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
          children: tableHeaders.map((header) => cell(header, isHeader: true)).toList(),
        ),
        // Data Rows
        ...transactions.map((transaction) {
          final isCredit = transaction.isCredit;
          // Each data row gets its own decoration
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: isCredit ? PdfColors.green50 : PdfColors.red50),
            children: [
              cell(transaction.date != null ? DateFormat.yMd().format(transaction.date!) : 'N/A'),
              cell(transaction.name ?? 'N/A'),
              cell(isCredit ? 'Credit' : 'Debit'),
              cell(currencyFormat.format(transaction.amount ?? 0), align: pw.Alignment.centerRight),
            ],
          );
        }).toList(),
      ],
    );
  }
  // --- END OF FIX ---

  static pw.Widget _buildSummary(double totalCredit, double totalDebit, double netBalance, int transactionCount, NumberFormat currencyFormat) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 250,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildSummaryRow('Total Transactions:', '$transactionCount'),
            _buildSummaryRow('Total Credit:', currencyFormat.format(totalCredit), color: PdfColors.green),
            _buildSummaryRow('Total Debit:', currencyFormat.format(totalDebit), color: PdfColors.red),
            pw.Divider(),
            _buildSummaryRow('Net Balance:', currencyFormat.format(netBalance), isBold: true),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String title, String value, {PdfColor? color, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(color: color, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}