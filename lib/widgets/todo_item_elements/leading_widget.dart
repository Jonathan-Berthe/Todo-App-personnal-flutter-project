import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../helpers/adaptable_text.dart';

class LeadingWidget extends StatelessWidget {
  final Category cat;
  final String prior;

  final int numberOfRecord;
  final int numberOfImages;

  const LeadingWidget({
    Key key,
    this.cat,
    this.prior,
    this.numberOfRecord,
    this.numberOfImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: 110,
      decoration: BoxDecoration(
          color: cat == null ? Colors.white : cat.color,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          border: (cat == null || cat?.color == Colors.white)
              ? Border.all(width: 1, color: Colors.black)
              : null),
      child: Center(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (cat != null && cat.emoji != null && cat.emoji != '')
                    Container(
                      child: Text(
                        cat.emoji,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8,),
                      child: 
                          AdaptableText(
                            cat == null ? 'No cat.' : cat.name,
                            style: TextStyle(
                              fontWeight: cat == null
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontStyle: cat == null
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color: cat?.color == Colors.black
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            //textScaleFactor: cat == null ? 1 : 0.5,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(prior,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                if (numberOfImages > 0)
                  Row(
                    children: <Widget>[
                      Text(
                        numberOfImages.toString(),
                        style: cat?.color == Colors.black
                            ? TextStyle(fontSize: 12, color: Colors.white)
                            : TextStyle(fontSize: 12),
                      ),
                      Icon(
                        Icons.image,
                        size: 12,
                        color: cat?.color == Colors.black ? Colors.white : null,
                      ),
                    ],
                  ),
                if (numberOfRecord > 0)
                  Row(
                    children: <Widget>[
                      Text(
                        numberOfRecord.toString(),
                        style: cat?.color == Colors.black
                            ? TextStyle(fontSize: 12, color: Colors.white)
                            : TextStyle(fontSize: 12),
                      ),
                      Icon(
                        Icons.mic,
                        size: 12,
                        color: cat?.color == Colors.black ? Colors.white : null,
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(width: 10)
          ],
        ),
      ),
    );
  }
}
