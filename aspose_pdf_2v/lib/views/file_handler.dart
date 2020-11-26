import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileHandler extends StatefulWidget {
  @override
  _FileHandlerState createState() => _FileHandlerState();
}

class _FileHandlerState extends State<FileHandler> {
  final _endpoint = 'http://10.0.2.2:6000';
  final _storageName = 'test';
  String _fileName;
  String _path;
  List<PlatformFile> _paths;
  String _extension;
  bool _uploading = false;
  bool _downloading = false;
  bool _isUploaded = false;

  @override
  void initState() {
    super.initState();
  }

  void _showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Message"),
      content: Text("Download completed"),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _uploadFile(file, filename, extension) async {
    final path = "Folder 1/$filename";
    setState(() {
      _path = path;
      _fileName = filename;
      _isUploaded = false;
    });
    var uri = Uri.parse("$_endpoint/upload?path=$path&storageName=$_storageName");
    var request = new http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath('file', file));
    request.send().then((response) {
      if (response.statusCode == 200) {
        setState(() {
          _isUploaded = true;
          _uploading = false;
        });
      }
    });
  }

  Future<void> _downloadFile(context) async {
    setState(() {
      _downloading = true;
    });
    var httpClient = http.Client();
    var request =
        new http.Request('GET', Uri.parse('$_endpoint/download?path=$_path&storageName=$_storageName'));
    var response = httpClient.send(request);
    _getStream(response, context);
  }

  void _getStream(response, context) async {
    final _dir = await getExternalStorageDirectory();
    List<List<int>> chunks = new List();
    response.asStream().listen((http.StreamedResponse r) {
      r.stream.listen((List<int> chunk) {
        chunks.add(chunk);
      }, onDone: () async {
        _saveFile(_dir.path, chunks, r, context);
      });
    });
  }

  void _saveFile(dir, chunks, r, context) async {
    File file = new File('$dir/$_fileName');
    final Uint8List bytes = Uint8List(r.contentLength);
    int offset = 0;
    for (List<int> chunk in chunks) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    await file.writeAsBytes(bytes);
    setState(() {
      _downloading = false;
    });
    _showAlertDialog(context);
    return;
  }

  void _openFilePicker() async {
    String _file = '';
    String _ext = '';
    setState(() => _uploading = true);
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '')?.split(',')
            : null,
      ))
          ?.files;
      _file = _paths.single.path;
      _ext = _paths.map((e) => e.extension).toString();
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
      setState(() => _uploading = false);
    } catch (ex) {
      print(ex);
      setState(() => _uploading = false);
    }
    if (!mounted) return;
    String _filename = _paths.map((e) => e.name).toString();
    _uploadFile(_file, _filename.substring(1, _filename.length - 1), _ext);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Aspose PDF'),
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: Column(
                    children: <Widget>[
                      !_isUploaded
                          ? ButtonTheme(
                              minWidth: 300.0,
                              height: 50.0,
                              child: RaisedButton(
                                  onPressed: () => _openFilePicker(),
                                  child: Text("Upload file"),
                                  padding: EdgeInsets.all(10.0),
                                  textColor: Colors.white,
                                  color: Colors.blue))
                          : Text(''),
                      _isUploaded
                          ? Column(children: <Widget>[
                              ButtonTheme(
                                  minWidth: 300.0,
                                  height: 50.0,
                                  child: RaisedButton(
                                      onPressed: () => _downloadFile(context),
                                      child: Text("Download file"),
                                      padding: EdgeInsets.all(10.0),
                                      textColor: Colors.white,
                                      color: Colors.blue)),
                              !_downloading && _isUploaded
                                  ? Text('')
                                  :
                              Padding(
                                  padding: const EdgeInsets.only(top: 30.0),
                                  child: CircularProgressIndicator()
                              )
                            ])
                          : Text(''),
                    ],
                  ),
                ),
                Builder(
                    builder: (BuildContext context) => _uploading
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: _uploading
                                ? CircularProgressIndicator()
                                : Text('Uploaded'),
                          )
                        : Text('')),
              ],
            ),
          ),
        )),
        floatingActionButton: new FloatingActionButton(
            elevation: 0.0,
            child: new Icon(Icons.arrow_back_rounded),
            backgroundColor: new Color(0xFFE57373),
            onPressed: () {
              setState(() {
                _downloading = false;
                _isUploaded = false;
                _uploading = false;
              });
            }),
      ),
    );
  }
}
