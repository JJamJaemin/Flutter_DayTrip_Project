import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllPostInfo {
  final String spaceName;
  final String image;
  final String pid;
  final String uid;
  final String tag;
  final String recomTag;
  final String date;
  final String postContent;
  bool isLiked;

  AllPostInfo({
    required this.spaceName,
    required this.image,
    required this.pid,
    required this.uid,
    required this.tag,
    required this.recomTag,
    required this.date,
    required this.postContent,
    required this.isLiked,
  });
}

class AllPostList extends StatefulWidget {
  AllPostList({Key? key}) : super(key: key);

  @override
  State<AllPostList> createState() => _AllPostListState();
}

class _AllPostListState extends State<AllPostList> {
  late List<AllPostInfo> allPostInfoList;

  @override
  void initState() {
    super.initState();
    allPostInfoList = [];
    fetchAllPostModel();
  }

  Future<void> toggleLike(String pid) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

      int index = allPostInfoList.indexWhere((post) => post.pid == pid);
      if (index != -1) {
        bool isLiked = allPostInfoList[index].isLiked;

        try {
          QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
              .collectionGroup('post')
              .where('pid', isEqualTo: pid)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            DocumentSnapshot<Map<String, dynamic>> postDoc = querySnapshot.docs.first;
            DocumentReference postDocRef = postDoc.reference;

            if (!isLiked) {
              await postDocRef.update({
                'likes': FieldValue.arrayUnion([uid]),
              });
              setState(() {
                allPostInfoList[index].isLiked = true;
              });
              print("Liked post successfully");
            } else {
              await postDocRef.update({
                'likes': FieldValue.arrayRemove([uid]),
              });
              setState(() {
                allPostInfoList[index].isLiked = false;
              });
              print("Unliked post successfully");
            }
          }
          setState(() {
            allPostInfoList[index].isLiked = !isLiked;
          });
        } catch (error) {
          print('Error toggling like: $error');
        }
      }
    }
  }

  Future<void> fetchAllPostModel() async {
    if (mounted) {
      try {
        QuerySnapshot<Map<String, dynamic>> usersQuerySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> userDoc in usersQuerySnapshot.docs) {
          QuerySnapshot<Map<String, dynamic>> postQuerySnapshot =
          await userDoc.reference.collection('post').get();

          List<AllPostInfo> updatedAllPostInfoList = postQuerySnapshot.docs.map((postDoc) {
            Map<String, dynamic> data = postDoc.data();
            String spaceName = data.containsKey('spaceName') ? data['spaceName'] : '';
            String image = data.containsKey('image') ? data['image'] : '';
            String pid = data.containsKey('pid') ? data['pid'] : '';
            String uid = data.containsKey('uid') ? data['uid'] : '';
            String tag = data.containsKey('tag') ? data['tag'] : '';
            String recomTag = data.containsKey('recomTag') ? data['recomTag'] : '';
            String date = data.containsKey('date') ? data['date'] : '';
            String postContent = data.containsKey('postContent') ? data['postContent'] : '';

            return AllPostInfo(
              spaceName: spaceName,
              image: image,
              pid: pid,
              uid: uid,
              tag: tag,
              recomTag: recomTag,
              date: date,
              postContent: postContent,
              isLiked: false,
            );
          }).toList();

          setState(() {
            allPostInfoList.addAll(updatedAllPostInfoList);
          });
        }
      } catch (error) {
        print('Error fetching posts: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "게시물 둘러보기",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 6.0,
            runSpacing: 8.0,
            children: allPostInfoList.asMap().entries.map((entry) {
              AllPostInfo postInfo = entry.value;
              return Stack(
                children: [
                  SizedBox(
                    width: 133,
                    height: 200,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            postInfo.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              postInfo.spaceName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: IconButton(
                      icon: postInfo.isLiked
                          ? Icon(Icons.favorite, color: Colors.red)
                          : Icon(Icons.favorite_border, color: Colors.red),
                      onPressed: () {
                        toggleLike(postInfo.pid);
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
