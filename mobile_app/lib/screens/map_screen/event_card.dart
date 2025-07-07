import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/types/events/events.dart';

class EventCard extends StatelessWidget {
  final PureEvent event;
  final double size;

  const EventCard({super.key, required this.event, this.size = 30});

  Widget imgWithName() {
    final imgSize = size * 0.8;
    final textSize = size - imgSize;
    return SizedBox(
      height: size,
      width: size,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: textSize,
              width: size,
              child: Center(
                child: Text(
                  event.name ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: textSize / 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                errorWidget: (context, _, __) => Icon(Icons.image),
                placeholder: (context, url) => Icon(Icons.broken_image_sharp),
                imageUrl: event.coverUrl,
                fit: BoxFit.cover,
                height: imgSize - 9,
                width: size,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget img() {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          width: size,
          height: size,
          errorWidget: (context, _, __) => Icon(Icons.image),
          placeholder: (context, url) => Icon(Icons.broken_image_sharp),
          imageUrl: event.coverUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(context) {
    return img();
  }
}
