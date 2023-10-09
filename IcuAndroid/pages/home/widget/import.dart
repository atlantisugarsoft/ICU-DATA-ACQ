import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hospital_app/hospitalwidgets/healthinfo.dart';
import 'package:hospital_app/hospitalwidgets/recordeddatalist.dart';
import 'package:hospital_app/hospitalwidgets/recordedgraph.dart';
import 'package:hospital_app/pages/home/widget/space.dart';
import 'package:hospital_app/providers/filesavingprovider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class Import extends StatefulWidget {
  const Import({super.key});

  @override
  State<Import> createState() => _ImportState();
}

class _ImportState extends State<Import> {
  String _filePath = '';
  String fileFormat = 'Invalid file format';
  late DataRepositoryModel _dataRepositoryModel;
  late Timer dataTimer;
  @override
  void initState() {
    super.initState();
    _dataRepositoryModel = DataRepositoryModel();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        pickAndMoveFile();

        // NOTE
        if (_filePath.endsWith('.csv')) {
          _dataRepositoryModel.loadDataFromCsv(_filePath);
          //print(_filePath);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PatientRecordedDataGraph()),
          );
        } else {
          print('Invalid');
        }
      },
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.blue, backgroundColor: Colors.white

          // You can customize other properties like padding, shape, etc. here
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .center, // Aligns children vertically at the center

        children: [
          const Icon(
            Icons.arrow_downward_rounded,
            size: 75,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            "IMPORT",
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ],
      ),
    );
  }

  Future<void> pickAndMoveFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path.toString());
      print(file.path.endsWith('.csv'));

      // Get the application directory
      final appDir = await getExternalStorageDirectory();
      if (file.path.endsWith('.csv')) {
        // Create a new file in the application directory
        File newFile = File('${appDir?.path}/${result.files.single.name}');

        // Copy the selected file to the application directory
        await file.copy(newFile.path);

        setState(() {
          _filePath = newFile.path;
        });
        // print(_filePath);
        //ScaffoldMessenger.of(context).showSnackBar(
        // SnackBar(
        // content: Text('File moved to application directory.'),
        //),
        //);
      } else {
        print('Invalid file format');
      }
    } else {
      // User canceled the file picker
    }
  }
}





/*

class Import extends StatelessWidget {
  const Import({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        //  Navigator.push(
        //  context,
        //MaterialPageRoute(
        //  builder: (context) => const PatientRecordedDataListScreen()),
        // );
      },
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.blue, backgroundColor: Colors.white

          // You can customize other properties like padding, shape, etc. here
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .center, // Aligns children vertically at the center

        children: [
          const Icon(
            Icons.arrow_downward_rounded,
            size: 75,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            "IMPORT",
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ],
      ),
    );
  }
}
*/