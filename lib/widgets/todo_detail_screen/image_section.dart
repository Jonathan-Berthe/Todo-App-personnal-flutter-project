import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';

import '../../providers/todo_list.dart';

// TODO: Snippet photoView

class ImageSection extends StatefulWidget {
  final String todoId;

  ImageSection({
    Key key,
    this.todoId,
  }) : super(key: key);

  @override
  _ImageSectionState createState() => _ImageSectionState();
}

class _ImageSectionState extends State<ImageSection> {
  bool _isLoading = false;

  List<Widget> _images = [];
  List<String> _imagesPath = [];

  Future<List<ByteData>> _loadImages(List<String> imagesPath) async {
    return (await Provider.of<TodoList>(context, listen: false)
        .imagesPathToByte(imagesPath));
  }

  void _loadImageWidget(List<String> imagesPath) {
    setState(() {
      _isLoading = true;
    });

    _imagesPath = [...imagesPath];

    _loadImages(_imagesPath).then((value) {
      List<Image> _imagesWidg = value
          .map((e) => Image.memory(
                e.buffer.asUint8List(),
                fit: BoxFit.cover,
              ))
          .toList();

      // TODO: dans synthese: précharger des images avec precacheImage pour éviter chargement
      _imagesWidg.forEach((element) {
        precacheImage(element.image, context);
      });

      _images = _imagesWidg.asMap().entries.map((e) {
        // e.key => index, e.value => value (Image)
        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) {
                return ImageDialog(
                  images: _imagesWidg,
                  initIndex: e.key,
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image(
              image: e.value.image,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
              key: ValueKey('image' + widget.todoId + e.key.toString()),
            ),
          ),
        );
      }).toList();

      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget _loadingBox() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        child: Center(child: CircularProgressIndicator()),
        height: 120,
        width: 120,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> imagesPath =
        Provider.of<TodoList>(context).findById(widget.todoId).imagesPath;
    // We maj the widget if the paths change
    if (!listEquals(_imagesPath, imagesPath)) _loadImageWidget(imagesPath);

    return Container(
      width: double.infinity,
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          return !_isLoading ? _images[i] : _loadingBox();
        },
        itemCount: _images.length,
      ),
    );
  }
}

class ImageDialog extends StatefulWidget {
  final List<Image> images;
  final int initIndex;
  

  ImageDialog({Key key, @required this.images, @required this.initIndex})
      : super(key: key);

  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  int _selectIndex;
  List<Image> _images;
  PhotoViewScaleStateController _scaleController = PhotoViewScaleStateController();

  @override
  void initState() {
    _selectIndex = widget.initIndex;
    _images = widget.images;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scaleController.dispose();
  }

  void _previous() {
    if (_selectIndex == 0) return;
    _scaleController.reset();
    // User swiped Left
    setState(() {
      _selectIndex--;
    });
  }

  void _next() {
    if (_selectIndex == widget.images.length - 1) return;
    _scaleController.reset();
    setState(() {
      _selectIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity > 0) {
            // User swiped Left
            _previous();
          } else if (details.primaryVelocity < 0) {
            // User swiped Right
            _next();
          }
        },
        child: Stack(
          children: <Widget>[
            ClipRect(
              child: PhotoView(
                imageProvider: _images[_selectIndex].image,
                scaleStateController: _scaleController,
                minScale: PhotoViewComputedScale.contained,
              ),
            ),
            Row(
              children: <Widget>[
                if (_selectIndex > 0)
                  IconButton(
                      icon: Icon(MdiIcons.arrowLeftDropCircle,
                          size: 30, color: Colors.grey),
                      onPressed: _previous),
                Expanded(child: SizedBox()),
                if (_selectIndex < widget.images.length - 1)
                  IconButton(
                      icon: Icon(MdiIcons.arrowRightDropCircle,
                          size: 30, color: Colors.grey),
                      onPressed: _next),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
