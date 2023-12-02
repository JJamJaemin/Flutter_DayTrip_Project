import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IntroduceAndLogout extends StatelessWidget {

  IntroduceAndLogout({super.key});

  void signUserOut(){
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          ProfileTile(),

          SizedBox(height: 10,),

          Row(
            children: [
              // 내 계정 프로필
              Flexible(
                flex: 3,
                child: Container(
                  color: Colors.transparent,
                  // height: 20,
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: '탭하고 소개 글을 입력해 보세요.',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      signUserOut();
                    },
                    child: Text('로그아웃'),
                    style: TextButton.styleFrom(
                      primary: Colors.black,
                      backgroundColor: Colors.transparent,
                      splashFactory: InkSplash.splashFactory,
                      minimumSize: Size(80, 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  const ProfileTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Row(
        children: [
          // 카드 이미지
          Flexible(
            flex: 1,
            child: CardImage(),
          ),

          SizedBox(width: 15,),

          // 이름, 친구수
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileName(),
                SizedBox(height: 10,),
                // 다른 정보 추가 가능
              ],
            ),
          ),
        ],
      ),

    );
  }
}

class CardImage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;
  CardImage({super.key});

  @override
  Widget build(BuildContext context) {
    print("user ${user.photoURL}");
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50)
      ),
      child: Container(
        child: Image.network("${user.photoURL}", width: 80, height: 80, fit: BoxFit.cover,),
        // child: Image.asset('asset/apple.jpg', fit: BoxFit.cover, width: 80, height: 80,)
      ),
    );
  }
}

class ProfileName extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  ProfileName({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ${user.displayName}
        Text("${user.displayName}", style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),),
        SizedBox(height: 5,),
        Text("작성한 게시물 수: ??"),
      ],
    );
  }
}