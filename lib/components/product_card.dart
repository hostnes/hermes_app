import 'package:collector_app/pages/preview_card_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
class ProductCard extends StatefulWidget {
  final Map<String, dynamic> cardData;

  const ProductCard({
    required this.cardData,
    super.key,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  var box = Hive.box('likes');
  
  // Checks if the item is liked
  bool get isLiked => box.containsKey(widget.cardData['id'].toString());

  // Toggles the like status
  void toggleLike() {
    setState(() {
      if (isLiked) {
        box.delete(widget.cardData['id'].toString());
      } else {
        box.put(widget.cardData['id'].toString(), true);
      }
    });
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => PreviewCardPage(
              cardData: widget.cardData,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Stack(
        children: [
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: toggleLike,
              child: Container(
                width: 50,
                height: 50,
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                  color: isLiked ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    width: 150,
                    height: 150,
                    child: Image.network(
                      widget.cardData['images'][0]['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cardData['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${widget.cardData['cost']} р.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${widget.cardData['owner_details']['district']['region']}, ${widget.cardData['owner_details']['district']['title']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        formatDate(widget.cardData['date']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
