import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ImagesPicker extends StatefulWidget {
  final Function setImages;
  final List<ByteData> initImage;
  const ImagesPicker(this.setImages, this.initImage);

  @override
  _ImagesPickerState createState() => _ImagesPickerState();
}

class _ImagesPickerState extends State<ImagesPicker> {
  List<ByteData> _images = [];
  bool _isUpdate = false;

  String _error;

  @override
  void initState() {
    super.initState();
    _images = widget.initImage;
  }

  Widget _buildGridView() {
    if (_images.length != 0) {
      widget.setImages(_images, isUpdate: _isUpdate);
      _isUpdate = false;
      return GridView.count(
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        crossAxisCount: 3,
        children: List.generate(_images.length, (index) {
          ByteData assetData = _images[index];
          return Stack(
            children: <Widget>[
              Image.memory(assetData.buffer.asUint8List(),
                  height: 120, width: 120, fit: BoxFit.cover),
              Row(
                children: <Widget>[
                  Expanded(child: Text('')),
                  IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _images.removeAt(index);
                        widget.setImages(
                          _images,
                          indexDelete: index,
                          isUpdate: true,
                        );
                      });
                    },
                  ),
                ],
              )
            ],
          );
        }),
      );
    } else
      return Container(color: Colors.white);
  }

  Future<void> loadAssets() async {
    _isUpdate = true;
    List<Asset> resultAssetList;
    String error;
    // TODO: gerer erreur qd on revient sans rien selectionner
    try {
      resultAssetList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        materialOptions: MaterialOptions(
          allViewTitle: "All",
          actionBarColor:
              '#${Theme.of(context).primaryColor.value.toRadixString(16)}',
          statusBarColor:
              '#${Theme.of(context).primaryColorDark.value.toRadixString(16)}',
          selectCircleStrokeColor: "#ffffff",
          selectionLimitReachedText: "You can't select any more.",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    if (resultAssetList != null) {
      List<ByteData> resultList = [];
      for (int i = 0; i < resultAssetList.length; i++) {
        var tmp = await resultAssetList[i].getByteData();
        resultList.add(tmp);
      }
      setState(() {
        _images = [..._images, ...resultList];
      });
      if (error == null) _error = 'No Error Dectected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          //Center(child: Text('Error: $_error')),
          RaisedButton.icon(
            label: const Text("Add images"),
            icon: const Icon(Icons.image),
            onPressed: loadAssets,
          ),
          Container(
            height: min(
                300, (_images.length.toDouble() / 3).ceil().toDouble() * 130),
            child: _buildGridView(),
          )
        ],
      ),
    );
  }
}
