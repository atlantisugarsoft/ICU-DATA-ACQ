import 'package:flutter/material.dart';
import 'package:hospital_app/providers/dataprovider.dart';
import 'package:hospital_app/providers/directoryprovider.dart';
import 'package:hospital_app/providers/filesavingprovider.dart';
import 'package:hospital_app/hospitalwidgets/recordedgraph.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class PatientRecordedDataListScreen extends StatefulWidget {
  const PatientRecordedDataListScreen({super.key});

  @override
  State<PatientRecordedDataListScreen> createState() =>
      _PatientRecordedDataListScreenState();
}

class _PatientRecordedDataListScreenState
    extends State<PatientRecordedDataListScreen> {
  // Step 1: Create a list of boolean values to track item selection.
  List<bool> selectedItems = [];
  List<String> fileData = [];
  late DirectoryProviderModel _directoryProviderModel;
  late DataRepositoryModel _dataRepositoryModel;
  List<String> listOfFileNames = [];
  bool selectedItem = false;
  int lengthForGeneratedCheckBox = 0;
  @override
  void initState() {
    super.initState();
    context.read<DirectoryProviderModel>().getDir();
    // fileData = context.watch<DirectoryProviderModel>().listOfFilesNames2;
    _directoryProviderModel = DirectoryProviderModel();
    _dataRepositoryModel = DataRepositoryModel();

    //generateCheckBox();
  }

  void generateCheckBox() {
    _directoryProviderModel =
        Provider.of<DirectoryProviderModel>(context, listen: false);
    //  selectedItems = List.generate(
    //  _directoryProviderModel.listOfFilesNames2.length,
    // (index) => false,
    //);
    //  print(_directoryProviderModel.listOfFilesNames2.length);

    if (_directoryProviderModel.listOfFilesNames2.isNotEmpty) {
      selectedItems = List.generate(
        _directoryProviderModel.listOfFilesNames2.length,
        (index) => false,
      );
      print(selectedItems);
    } else {
      // Handle the case where data is not available or length is invalid
      print("Data not available or length is invalid.");
    }
    // print(selectedItems);
  }

  void deleteSelectedItems() {
    // Create a copy of the selectedItems list to avoid modifying it while iterating.
    List<bool> copySelectedItems = List.from(selectedItems);

    // Iterate through the selectedItems list and delete the selected items.
    for (int i = copySelectedItems.length - 1; i >= 0; i--) {
      if (copySelectedItems[i]) {
        context.read<DirectoryProviderModel>().deleteFiles(i);
        selectedItems.removeAt(i);
      }
    }

    // Rebuild the widget to reflect the changes.
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    // _dataRepositoryModel.dispose();
    //_directoryProviderModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //generateCheckBox();
    setState(() {
      lengthForGeneratedCheckBox =
          context.watch<DirectoryProviderModel>().listOfFilesNames2.length;
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlantis-UgarSoft'),
        actions: [
          // Step 3: Add a delete button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              //deleteSelectedItems();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: context
                    .watch<DirectoryProviderModel>()
                    .listOfFilesNames2
                    .length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      // Add a border to the ListTile
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Colors.grey, // Border color based on selection
                        width: 5.0,
                      ),
                    ),
                    leading: const Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 60,
                    ),
                    // Step 2: Add a Checkbox to select items for deletion
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Step 2: Add a Share button for WhatsApp
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            // Get the file or data you want to share
                            String filePath = context
                                .read<DirectoryProviderModel>()
                                .listOfFilesNames2[index];

                            // Share to WhatsApp
                            Share.shareFiles([filePath],
                                text:
                                    'Check out this file from Atlantis-UgarSoft:');
                          },
                        ),
                        // Step 3: Add a Share button for Email
                        IconButton(
                          icon: Icon(Icons.email),
                          onPressed: () {
                            // Get the file or data you want to share
                            String filePath = context
                                .read<DirectoryProviderModel>()
                                .listOfFilesNames2[index];

                            // Share via Email
                            Share.shareFiles([filePath],
                                subject: 'Subject of the Email',
                                text: 'Body of the Email');
                          },
                        ),
                        /* Checkbox(
                          value: selectedItems[index],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedItems[index] = value ?? false;

                              print(selectedItems);
                            });
                          },
                        )*/
                      ],
                    ),
                    title: Text(context
                        .watch<DirectoryProviderModel>()
                        .listOfFilesNames2[index]
                        .substring(69, 74)),
                    subtitle: Text(
                        "${context.watch<DirectoryProviderModel>().listOfFilesNames2[index].substring(74, 84)} ${context.watch<DirectoryProviderModel>().listOfFilesNames2[index].substring(84, 86)}${':'}${context.watch<DirectoryProviderModel>().listOfFilesNames2[index].substring(86, 90)} "),
                    onTap: () {
                      // Use providerOf for better content from the provider

                      _directoryProviderModel =
                          Provider.of<DirectoryProviderModel>(context,
                              listen: false);
                      // print(_directoryProviderModel.listOfFilesNames2[index]);
                      _dataRepositoryModel = Provider.of<DataRepositoryModel>(
                          context,
                          listen: false);

                      //FOR CSV
                      _dataRepositoryModel.loadDataFromCsv(
                          _directoryProviderModel.listOfFilesNames2[index]);
                      // print(_dataRepositoryModel.dataToSend);
                      _dataRepositoryModel = Provider.of<DataRepositoryModel>(
                          context,
                          listen: false);
                      print(_directoryProviderModel.listOfFilesNames2[index]);
                      _dataRepositoryModel.getIndexSelected(index);
                      context
                          .read<DataRepositoryModel>()
                          .getIndexSelected(index);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PatientRecordedDataGraph()),
                      );
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
