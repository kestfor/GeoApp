import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../style/colors.dart';

class EventsGrid extends StatelessWidget {
  final List<String> imageUrls;

  const EventsGrid({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.length > 6) {
      imageUrls.removeRange(6, imageUrls.length);
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      // Основная колонка: Заголовок + Сетка
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок Events
          Text('Events', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Сетка изображений
          GridView.builder(
            // Отключаем скролл, чтобы GridView не конфликтовал со скроллом экрана
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: imageUrls.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 столбца
              mainAxisSpacing: 8, // отступ между строками
              crossAxisSpacing: 8, // отступ между столбцами
              childAspectRatio: 1, // делать элементы квадратными
            ),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Icon(Icons.broken_image_sharp),
                  placeholder: (context, _) => Icon(Icons.image),
                  imageUrl: imageUrls[index],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
