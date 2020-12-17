import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'place_service.dart';
import 'adress_search.dart';

class AutoCompleteWidget extends StatefulWidget {
  final Function selectLocation;
  final String initAddress;
  const AutoCompleteWidget({Key key, this.selectLocation, this.initAddress})
      : super(key: key);

  @override
  _AutoCompleteWidgetState createState() => _AutoCompleteWidgetState();
}

class _AutoCompleteWidgetState extends State<AutoCompleteWidget> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initAddress != null) {
      _controller.text = widget.initAddress;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          TextField(
            showCursor: true,
            textInputAction: TextInputAction.done,

            controller: _controller,
            onTap: () async {
              // placeholder for our places search later
              // generate a new token here
              final sessionToken = Uuid().v4();
              final Suggestion result = await showSearch(
                context: context,
                delegate: AddressSearch(sessionToken),
              );

              // This will change the text displayed in the TextField
              if (result != null) {
                final place = await PlaceApiProvider(sessionToken)
                    .getPlaceDetailFromId(result.placeId);
                setState(() {
                  _controller.text = place.address;
                  widget.selectLocation(place.lat, place.lng, fromOut: true);
                });
              }
            },
            // with some styling
            decoration: InputDecoration(
              icon: Container(
                margin: EdgeInsets.only(left: 20),
                width: 10,
                height: 10,
                child: Icon(
                  Icons.home,
                  color: Colors.black,
                ),
              ),
              labelText: 'Picked in the map or enter the name of the place',
              hintText: "Enter the name of the place",
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
