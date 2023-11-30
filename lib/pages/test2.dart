import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExcelImportScreen(),
    );
  }
}

class ExcelImportScreen extends StatefulWidget {
  @override
  _ExcelImportScreenState createState() => _ExcelImportScreenState();
}

class _ExcelImportScreenState extends State<ExcelImportScreen> {
  List<List<String>> excelData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel Import'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                /// Use FilePicker to pick files in Flutter Web

                FilePickerResult? pickedFile =
                    await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['xlsx'],
                  allowMultiple: false,
                );

                if (pickedFile != null) {
                  var bytes = pickedFile.files.single.bytes;
                  var excel = Excel.decodeBytes(bytes!);
                  for (var table in excel.tables.keys) {
                    print(table);
                    print(excel.tables[table]!.maxColumns);
                    print(excel.tables[table]!.maxRows);
                    for (var row in excel.tables[table]!.rows) {
                      print("${row.map((e) => e?.value)}");
                    }
                  }
                }
              },
              child: Text('Pick and Import Excel'),
            ),
            if (excelData.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: List.generate(
                      excelData[0].length,
                      (index) => DataColumn(label: Text('Column ${index + 1}')),
                    ),
                    rows: List.generate(
                      excelData.length - 1,
                      (rowIndex) => DataRow(
                        cells: List.generate(
                          excelData[rowIndex + 1].length,
                          (cellIndex) => DataCell(
                              Text(excelData[rowIndex + 1][cellIndex])),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
