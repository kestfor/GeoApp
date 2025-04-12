import 'dart:math';

import 'package:mobile_app/types/events/comments.dart';
import 'package:mobile_app/types/events/events.dart';
import 'package:mobile_app/types/media/media.dart';

import '../types/user/user.dart';

final mockUser = User(
  username: "alice",
  id: 1,
  lastName: "Brown",
  firstName: "Alice",
  bio:
      "I am software engineer with a strong background in mobile app development. With expertise in Flutter and a keen eye for clean, intuitive design, I love crafting seamless user experiences. ",
  pictureUrl:
      "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGVyc29ufGVufDB8fDB8fHww",
);

final friendsMocks = [
  User(
    username: "julia",
    id: 5,
    lastName: "Foren",
    firstName: "Julia",
    pictureUrl:
        "https://img.freepik.com/free-photo/lifestyle-people-emotions-casual-concept-confident-nice-smiling-asian-woman-cross-arms-chest-confident-ready-help-listening-coworkers-taking-part-conversation_1258-59335.jpg",
  ),
  User(
    username: "bob",
    id: 3,
    lastName: "Smith",
    firstName: "Bob",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg",
  ),
  User(
    username: "charlie",
    id: 4,
    lastName: "Johnson",
    firstName: "Charlie",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
  ),
  User(
    username: "julia",
    id: 5,
    lastName: "Foren",
    firstName: "Julia",
    pictureUrl:
        "https://img.freepik.com/free-photo/lifestyle-people-emotions-casual-concept-confident-nice-smiling-asian-woman-cross-arms-chest-confident-ready-help-listening-coworkers-taking-part-conversation_1258-59335.jpg",
  ),
  User(
    username: "bob",
    id: 3,
    lastName: "Smith",
    firstName: "Bob",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg",
  ),
  User(
    username: "charlie",
    id: 4,
    lastName: "Johnson",
    firstName: "Charlie",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
  ),
  User(
    username: "julia",
    id: 5,
    lastName: "Foren",
    firstName: "Julia",
    pictureUrl:
        "https://img.freepik.com/free-photo/lifestyle-people-emotions-casual-concept-confident-nice-smiling-asian-woman-cross-arms-chest-confident-ready-help-listening-coworkers-taking-part-conversation_1258-59335.jpg",
  ),
  User(
    username: "bob",
    id: 3,
    lastName: "Smith",
    firstName: "Bob",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg",
  ),
  User(
    username: "charlie",
    id: 4,
    lastName: "Johnson",
    firstName: "Charlie",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
  ),
  User(
    username: "julia",
    id: 5,
    lastName: "Foren",
    firstName: "Julia",
    pictureUrl:
        "https://img.freepik.com/free-photo/lifestyle-people-emotions-casual-concept-confident-nice-smiling-asian-woman-cross-arms-chest-confident-ready-help-listening-coworkers-taking-part-conversation_1258-59335.jpg",
  ),
  User(
    username: "bob",
    id: 3,
    lastName: "Smith",
    firstName: "Bob",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg",
  ),
  User(
    username: "charlie",
    id: 4,
    lastName: "Johnson",
    firstName: "Charlie",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
  ),
  User(
    username: "julia",
    id: 5,
    lastName: "Foren",
    firstName: "Julia",
    pictureUrl:
        "https://img.freepik.com/free-photo/lifestyle-people-emotions-casual-concept-confident-nice-smiling-asian-woman-cross-arms-chest-confident-ready-help-listening-coworkers-taking-part-conversation_1258-59335.jpg",
  ),
  User(
    username: "bob",
    id: 3,
    lastName: "Smith",
    firstName: "Bob",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg",
  ),
  User(
    username: "charlie",
    id: 4,
    lastName: "Johnson",
    firstName: "Charlie",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
  ),
  User(
    username: "julia",
    id: 5,
    lastName: "Foren",
    firstName: "Julia",
    pictureUrl:
        "https://img.freepik.com/free-photo/lifestyle-people-emotions-casual-concept-confident-nice-smiling-asian-woman-cross-arms-chest-confident-ready-help-listening-coworkers-taking-part-conversation_1258-59335.jpg",
  ),
  User(
    username: "bob",
    id: 3,
    lastName: "Smith",
    firstName: "Bob",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg",
  ),
  User(
    username: "charlie",
    id: 4,
    lastName: "Johnson",
    firstName: "Charlie",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
  ),
  User(
    username: "julia",
    id: 5,
    lastName: "Foren",
    firstName: "Julia",
    pictureUrl:
        "https://img.freepik.com/free-photo/lifestyle-people-emotions-casual-concept-confident-nice-smiling-asian-woman-cross-arms-chest-confident-ready-help-listening-coworkers-taking-part-conversation_1258-59335.jpg",
  ),
  User(
    username: "bob",
    id: 3,
    lastName: "Smith",
    firstName: "Bob",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg",
  ),
  User(
    username: "charlie",
    id: 4,
    lastName: "Johnson",
    firstName: "Charlie",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
  ),
  User(
    username: "julia",
    id: 5,
    lastName: "Foren",
    firstName: "Julia",
    pictureUrl:
        "https://img.freepik.com/free-photo/lifestyle-people-emotions-casual-concept-confident-nice-smiling-asian-woman-cross-arms-chest-confident-ready-help-listening-coworkers-taking-part-conversation_1258-59335.jpg",
  ),
  User(
    username: "bob",
    id: 3,
    lastName: "Smith",
    firstName: "Bob",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg",
  ),
  User(
    username: "charlie",
    id: 4,
    lastName: "Johnson",
    firstName: "Charlie",
    pictureUrl: "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
  ),
];

final mockEventsGrid = [
  "https://www.mensjournal.com/.image/t_share/MTk2MTM3MzIwNzEwMjg0ODA1/alex-honnold-jimmy-chin.jpg",
  "https://media.istockphoto.com/id/1096035138/photo/beautiful-young-couple-relaxing-after-hiking-and-taking-a-break.jpg?s=612x612&w=0&k=20&c=iwNan7K7gbiIl2unv-9EuE5Yej-h_l1OrLNMel0husU=",
  "https://www.camelbackresort.com/wp-content/uploads/2023/06/4000-zip-rider-2-scaled-1.jpg",
  "https://res.cloudinary.com/worldpackers/image/upload/c_fill,f_jpg,h_600,q_auto,w_900/v1/guides/article_cover/ejgcq0acumqaosd7kl26?_a=BACADKGT",
  "https://assets.simpleviewinc.com/simpleview/image/upload/c_fill,h_474,q_75,w_640/v1/clients/newyorkstate/GreenLkSP_109_1__4b4e7ebb-9d7d-455b-87f3-f3cad1396381.jpg",
  "https://www.youthadventuretrust.org.uk/wp-content/uploads/2019/10/FR-2-1024x624.jpg",
  "https://burst.shopifycdn.com/photos/man-hiking-in-mountains.jpg?width=1000&format=pjpg&exif=0&iptc=0",
];

final pureEventsMock = [
  PureEvent(
    membersId: [1, 2],
    id: 1,
    name: "Hiking in the mountains",
    point: Point(lat: 42.7128, lon: -72.0060),
    coverUrl: "https://www.mensjournal.com/.image/t_share/MTk2MTM3MzIwNzEwMjg0ODA1/alex-honnold-jimmy-chin.jpg",
    authorId: 2,
  ),

  PureEvent(
    membersId: [1, 2],
    id: 2,
    name: "Camping under the stars",
    point: Point(lat: 45.7128, lon: -70.0060),
    coverUrl:
        "https://media.istockphoto.com/id/1096035138/photo/beautiful-young-couple-relaxing-after-hiking-and-taking-a-break.jpg?s=612x612&w=0&k=20&c=iwNan7K7gbiIl2unv-9EuE5Yej-h_l1OrLNMel0husU=",
    authorId: 2,
  ),

  PureEvent(
    membersId: [1, 2],
    id: 6,
    name: "Mountain biking trails",
    point: Point(lat: 47.7128, lon: -74.0060),
    coverUrl: "https://burst.shopifycdn.com/photos/man-hiking-in-mountains.jpg?width=1000&format=pjpg&exif=0&iptc=0",
    authorId: 2,
  ),

  PureEvent(
    membersId: [1, 2],
    id: 3,
    name: "Ziplining through the trees",
    point: Point(lat: 41.7128, lon: -78.0060),
    coverUrl: "https://www.camelbackresort.com/wp-content/uploads/2023/06/4000-zip-rider-2-scaled-1.jpg",
    authorId: 2,
  ),

  PureEvent(
    membersId: [1, 2],
    id: 4,
    name: "Rock climbing adventure",
    point: Point(lat: 39.7128, lon: -74.0060),
    coverUrl:
        "https://res.cloudinary.com/worldpackers/image/upload/c_fill,f_jpg,h_600,q_auto,w_900/v1/guides/article_cover/ejgcq0acumqaosd7kl26?_a=BACADKGT",
    authorId: 2,
  ),

  PureEvent(
    membersId: [1, 2],
    id: 5,
    name: "Kayaking in the lake",
    point: Point(lat: 47.7128, lon: -74.0060),
    coverUrl: "https://www.youthadventuretrust.org.uk/wp-content/uploads/2019/10/FR-2-1024x624.jpg",
    authorId: 2,
  ),
];

extension RX on Random {
  double randomDouble(double min, double max) {
    return (nextDouble() * (max - min) + min);
  }

  int randomInt(int min, int max) {
    return (nextInt(max - min + 1) + min);
  }
}

List<PureEvent> generatePureEvents({limit = 100}) {
  List<PureEvent> res = [];
  final random = Random();
  for (int i = 0; i < limit; i++) {
    final event = PureEvent(
      id: i,
      coverUrl: mockEventsGrid[random.randomInt(0, 6)],
      name: pureEventsMock[random.randomInt(0, 5)].name,
      authorId: i,
      membersId: [i],
      point: Point(lat: random.randomDouble(54, 56), lon: random.randomDouble(82, 84)),
    );
    res.add(event);
  }
  return res;
}

List<PureEvent> generatedMocks = generatePureEvents();

final detailedEventMock = Event(
  id: 1,
  coverUrl: "https://www.mensjournal.com/.image/t_share/MTk2MTM3MzIwNzEwMjg0ODA1/alex-honnold-jimmy-chin.jpg",
  name: "Hiking in the mountains",
  authorId: 1,
  membersId: [1, 2],
  files: mediaMock,
  point: Point(lat: 42.7128, lon: -72.0060),
  description:
      "Join us for an unforgettable hiking adventure in the breathtaking mountains! Experience stunning views, fresh air, and the thrill of exploring nature's beauty. Whether you're a seasoned hiker or a beginner, this event is perfect for everyone. Don't miss out on this opportunity to connect with fellow outdoor enthusiasts and create lasting memories!",
);

final commentsMock = [
  PureComment(
    id: 1,
    authorId: 4,
    text:
        "This event was amazing! The views were breathtaking and the company was fantastic. Can't wait for the next one!",
    createdAt: (DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch / 1000).toInt(),
    updatedAt: (DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch / 1000).toInt(),
  ),
  PureComment(
    id: 2,
    authorId: 5,
    text:
        "I had a great time hiking with everyone! The trail was challenging but worth it. Looking forward to more adventures together!",
    createdAt: (DateTime.now().subtract(Duration(days: 2)).millisecondsSinceEpoch / 1000).toInt(),
    updatedAt: (DateTime.now().subtract(Duration(days: 2)).millisecondsSinceEpoch / 1000).toInt(),
  ),
];

final mediaMock = [
  ImgContent(
    fileId: "1",
    authorId: "1",
    images: [
      ImgData(
        type: "original",
        size: 1,
        metadata: {},
        url: "https://storage.yandexcloud.net/user-content/test_key?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=YCAJEIRbfQAbQ9bnQvUNgYf1k%2F20250410%2Fru-central1%2Fs3%2Faws4_request&X-Amz-Date=20250410T124320Z&X-Amz-Expires=2592000&X-Amz-Signature=5522c557c7f44db7ece0735c954acf8bf78b5d649ff87dc6cf87c5bc5cff3240&X-Amz-SignedHeaders=host",
      ),
    ],
  ),
  VideoContent(
    videoUrl: "https://storage.yandexcloud.net/user-content/IMG_6609.mp4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=YCAJEIRbfQAbQ9bnQvUNgYf1k%2F20250409%2Fru-central1%2Fs3%2Faws4_request&X-Amz-Date=20250409T125704Z&X-Amz-Expires=2592000&X-Amz-Signature=e538bc91bf44aac5db0202efecd0f66c5194f582005ead72c35c77abc803eebb&X-Amz-SignedHeaders=host",
    thumbnailUrl: "https://www.youthadventuretrust.org.uk/wp-content/uploads/2019/10/FR-2-1024x624.jpg",
    fileId: "2",
    authorId: "1",
  ),
  ImgContent(
    fileId: "3",
    authorId: "1",
    images: [
      ImgData(
        type: "original",
        size: 1,
        metadata: {},
        url: "https://www.youthadventuretrust.org.uk/wp-content/uploads/2019/10/FR-2-1024x624.jpg",
      ),
    ],
  ),

];


final allUsers = [mockUser] + friendsMocks;