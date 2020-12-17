import 'package:flutter/material.dart';
import '../../models/place.dart';

class PlaceSection extends StatelessWidget {
  final PlaceLocation place;

  const PlaceSection({Key key, this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        Row(
          children: <Widget>[
            const SizedBox(
              width: 5,
            ),
            const Icon(Icons.place, size: 18),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Container(
                //constraints: BoxConstraints(maxWidth: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    if (place.name != null && place.name != '')
                      Text(
                        place.name,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (place.address != null &&
                        place.address != '')
                      Text(
                        place.address,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (place.latitude != null &&
                        place.longitude != null)
                      Text(
                        "(${place.latitude.toStringAsFixed(4)},${place.longitude.toStringAsFixed(4)})",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
