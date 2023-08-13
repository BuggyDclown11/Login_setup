// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';

// import '../../../../common_widgets/cards/recommended_card.dart';
// import '../../../../constants/colors.dart';
// import '../../models/place_modal.dart';
// import 'package:http/http.dart' as http;
// import 'package:login_setup/src/features/authentication/screens/dummy_dash/dash.dart';


// class DetailScreen extends StatefulWidget {
//   final PlaceInfo placeInfo;
//   const DetailScreen({Key? key, required this.placeInfo}) : super(key: key);

//   @override
//   State<DetailScreen> createState() => _DetailScreenState();
// }

// class _DetailScreenState extends State<DetailScreen> {
//   List<bool> starStatus = [false, false, false, false, false];
//   TextEditingController _commentController = TextEditingController();

//   final String apiUrl1 = "http://192.168.1.65/api/insert_TempleRatings.php";
//   final String Url = "http://192.168.1.65/api/insert_fav.php";

//   late int templeid;
//   late String Username;
//   late String title;
//   final int uid = 931335757;
//   late String currentuser;
//   late String comment;
//   late double rating;
//   bool isFavorite = false;
//   List<PlaceInfo> recommendations = [];

//   void fetchRecommendations() async {
//     // if (title == 'temple') {
//     var url = 'http://192.168.1.65:5000/predict';
//     var body = jsonEncode({'user_id': currentuser});

//     var response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: body,
//     );

//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);
//       print('Recommendations data: $data');

//       List<int> recommendationIds = List<int>.from(data);
//       print('Number of recommendations: ${recommendationIds.length}');

//       List<PlaceInfo> recommendedTemples = [];

//       // Initialize the PlacesService class
//       PlacesService placesService = PlacesService();

//       // Fetch all temples from the API
//       List<PlaceInfo> temples = await placesService.getTemples();

//       for (int id in recommendationIds) {
//         PlaceInfo temple =
//             temples.firstWhere((temples) => temples.id == (id + 1));
//         if (temple != null) {
//           recommendedTemples.add(temple);
//         }
//       }

//       setState(() {
//         recommendations = recommendedTemples;
//       });
//     } else {
//       print('Request failed with status: ${response.statusCode}.');
//     }
    
//   }

//   Future<void> checkFavoriteStatus() async {

//     final String uid = currentuser;


//     final response = await http
//         .post(Uri.parse("http://192.168.1.65/api/show_favTemple.php"), body: {
//       'templeid': templeid.toString(),
//       'uid': uid.toString(),
//     });

//     if (response.statusCode == 200) {
//       // Check if the response indicates that the place is in favorites
//       final bool isFavorite = response.body == '1';
//       setState(() {
//         this.isFavorite = isFavorite;
//         print('yes');
//       });
//     } else {
//       // Failed to retrieve favorite status
//       print('Failed to check favorite status.${response.statusCode}');
//     }
//   }

//   void _insertRating(double rating) async {
//     print('ratinf');
//     print(comment);
//     final String uiid = currentuser;
//     final response = await http.post(
//         Uri.parse("http://192.168.1.65/api/insert_rating.php?title=$title"),
//         body: {
//           'rating': rating.toString(),
//           'templeid': templeid.toString(),
//           'uid': uiid.toString(),
//           'comment': comment,
//         });

//     if (response.statusCode == 200) {
//       // Successful insertion
//       print('Rating inserted successfully!');
//     } else {
//       // Failed insertion
//       print('Failed to insert rating.${response.statusCode}');
//     }
//   }

//   void _insertFavourite() async {
//     print('this');
//     final String uiid = currentuser;
//     final response = await http.post(
//         Uri.parse("http://192.168.1.65/api/insert_fav.php?title=$title"),
//         body: {
//           'uid': uiid.toString(),
//           'templeid': templeid.toString(),
//         });
//     if (response.statusCode == 200) {
//       // Successful insertion
//       print('favtemple inserted successfully!');
//       setState(() {
//         isFavorite = true; // Update the favorite status after insertion
//       });
//     } else {
//       // Failed insertionR
//       print('Failed to insert Favtemple.${response.statusCode}');
//     }
//   }

//   void _removeFavourite() async {
//     final String uid = currentuser;

//     final response = await http.post(
//       Uri.parse("http://192.168.1.65/api/remove_fav.php"),
//       body: {
//         'templeid': templeid.toString(),
//         'uid': uid,
//       },
//     );

//     if (response.statusCode == 200) {
//       // Successful removal
//       setState(() {
//         isFavorite = false; // Update the favorite status after removal
//       });
//       print('fav temple removed successfully!');
//     } else {
//       // Failed removal
//       print('Failed to remove Favtemple.${response.statusCode}');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     templeid = widget.placeInfo.id!;
//     currentuser = FirebaseAuth.instance.currentUser!.uid;
//     title = widget.placeInfo.title!;
//     checkFavoriteStatus();
//     fetchRecommendations();
//   }
  
//   Widget build(BuildContext context) {
//     final theme = context.theme;
//     return Scaffold(
//       body: SafeArea(
//         child: ListView(
//           children: [
//             SizedBox(
//               height: 330.h,
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: SvgPicture.asset(
//                       Constants.container,
//                       fit: BoxFit.fill,
//                       color: theme.cardColor,
//                     ),
//                   ),
//                   Positioned(
//                     top: 24.h,
//                     left: 24.w,
//                     right: 24.w,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CustomIconButton(
//                           onPressed: () => Get.back(),
//                           icon: SvgPicture.asset(
//                             Constants.backArrowIcon,
//                             fit: BoxFit.none,
//                             color: theme.appBarTheme.iconTheme?.color,
//                           ),
//                         ),
//                         CustomIconButton(
//                           onPressed: () {},
//                           icon: SvgPicture.asset(
//                             Constants.searchIcon,
//                             fit: BoxFit.none,
//                             color: theme.appBarTheme.iconTheme?.color,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     top: 80.h,
//                     left: 0,
//                     right: 0,
//                     child: Image.asset(
//                       controller.product.image,
//                       width: 250.w,
//                       height: 225.h,
//                     ).animate().fade().scale(
//                       duration: 800.ms,
//                       curve: Curves.fastOutSlowIn,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             30.verticalSpace,
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w),
//               child: Row(
//                 children: [
//                   Text(
//                     controller.product.name,
//                     style: theme.textTheme.headline2,
//                   ).animate().fade().slideX(
//                     duration: 300.ms,
//                     begin: -1,
//                     curve: Curves.easeInSine,
//                   ),
//                   const Spacer(),
//                   ProductCountItem(product: controller.product).animate().fade(
//                     duration: 200.ms
//                   ),
//                 ],
//               ),
//             ),
//             8.verticalSpace,
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w),
//               child: Text(
//                 '1kg, ${controller.product.price}\$',
//                 style: theme.textTheme.headline3?.copyWith(
//                   color: theme.primaryColor,
//                 ),
//               ).animate().fade().slideX(
//                 duration: 300.ms,
//                 begin: -1,
//                 curve: Curves.easeInSine,
//               ),
//             ),
//             8.verticalSpace,
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w),
//               child: Text(
//                 controller.product.description,
//                 style: theme.textTheme.bodyText1,
//               ).animate().fade().slideX(
//                 duration: 300.ms,
//                 begin: -1,
//                 curve: Curves.easeInSine,
//               ),
//             ),
//             20.verticalSpace,
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w),
//               child: GridView(
//                 shrinkWrap: true,
//                 primary: false,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16.w,
//                   mainAxisSpacing: 16.h,
//                   mainAxisExtent: 80.h,
//                 ),
//                 children: DummyHelper.cards.map((card) => CustomCard(
//                   title: card['title']!,
//                   subtitle: card['subtitle']!,
//                   icon: card['icon']!,
//                 )).toList().animate().fade().slideY(
//                   duration: 300.ms,
//                   begin: 1,
//                   curve: Curves.easeInSine,
//                 ),
//               ),
//             ),
//             30.verticalSpace,
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w),
//               child: CustomButton(
//                 text: 'Add to cart',
//                 onPressed: () => controller.onAddToCartPressed(),
//                 fontSize: 16.sp,
//                 radius: 50.r,
//                 verticalPadding: 16.h,
//                 hasShadow: false,
//               ).animate().fade().slideY(
//                 duration: 300.ms,
//                 begin: 1,
//                 curve: Curves.easeInSine,
//               ),
//             ),
//             30.verticalSpace,
//           ],
//         ),
//       ),
//     );
//   }}