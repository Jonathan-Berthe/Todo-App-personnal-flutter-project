import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/category_list.dart';

class CategorySection extends StatelessWidget {
  final String catId;

  const CategorySection({Key key, this.catId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> parents =
        Provider.of<CategoryList>(context, listen: false).findListOfParents(
      catId,
    );

    final concatStr = StringBuffer(parents.length > 1 ? '${parents[0]}' : '');

    for (int i = 1; i < parents.length - 1; i++) {
      concatStr.write(' / ${parents[i]}');
    }

    final String text = concatStr.toString();

    concatStr.clear();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 17,
        ),
        const Text(
          'Category path: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                if (text != '')
                  TextSpan(
                    text: text + ' / ',
                  ),
                TextSpan(
                  text: '${parents?.last}',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
