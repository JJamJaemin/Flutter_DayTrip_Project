import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/model_db/postmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SpaceInfo {
  final String imagePath;
  final String title;
  final String location;
  final String tag;

  SpaceInfo({
    required this.imagePath,
    required this.title,
    required this.location,
    required this.tag,
  });
}

class WriteDayLog extends StatefulWidget {

  WriteDayLog({super.key});

  @override
  State<WriteDayLog> createState() => _WriteDayLogState();
}

class _WriteDayLogState extends State<WriteDayLog> {

  List<SpaceInfo>? spaceInfoList;
  File? selectedGalleryImage;
  String? hashTagButton;
  TextEditingController _textEditingController = TextEditingController();
  bool check1 = false;
  bool check2 = false;
  String? selectedTitle;
  String? spaceTag;
  String? spaceLocation;

  late FocusNode _textFocusNode;

  @override
  void initState() {
    super.initState();
    _textFocusNode = FocusNode(); // FocusNode 초기화
    fetchSpaceModels();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _textFocusNode.dispose(); // FocusNode 해제
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textFocusNode.addListener(() {
      if (!_textFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }

  // 해시태그 버튼
  void selectHashTagButton(String buttonText) {
    setState(() {
      if (hashTagButton == buttonText) {
        hashTagButton = ''; // 이미 선택된 버튼을 다시 누르면 선택 해제
      } else {
        hashTagButton = buttonText; // 새로운 버튼을 선택
      }
    });
  }


  Future<String?> uploadCompressedImageToFirebaseStorage(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      Uint8List uint8List = Uint8List.fromList(imageBytes); // List<int>를 Uint8List로 변환

      Uint8List compressedImageBytes = await FlutterImageCompress.compressWithList(
        uint8List,
        minHeight: 1920, // 압축 후 이미지의 최소 높이
        minWidth: 1080, // 압축 후 이미지의 최소 너비
        quality: 80, // 이미지 품질
      );

      File compressedImageFile = File('${imageFile.path}_compressed.jpg');
      await compressedImageFile.writeAsBytes(compressedImageBytes);

      final Reference storageReference = FirebaseStorage.instance.ref().child('images')
          .child(DateTime.now().millisecondsSinceEpoch.toString());
      await storageReference.putFile(compressedImageFile);
      final String downloadUrl = await storageReference.getDownloadURL();

      // 압축된 이미지 업로드 후 압축된 파일 삭제
      await compressedImageFile.delete();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> createPost() async {
    final String? imageUrl = await uploadCompressedImageToFirebaseStorage(selectedGalleryImage!);
    final user = FirebaseAuth.instance.currentUser!;
    final uuid = Uuid();


    if (imageUrl != null) {
      final String formattedDateString = DateFormat('yyyy년 MM월 dd일').format(selectedDate);
      final DateTime parsedDate = DateFormat('yyyy년 MM월 dd일').parse(formattedDateString);
      final String writtenTime = DateFormat('yyyy/MM/dd - HH:mm:ss').format(DateTime.now());

      final post = PostModel(
        pid:uuid.v4(),
        uid:user.uid,
        postContent:_textEditingController.text,
        image: imageUrl,
        spaceName:selectedTitle!,
        date:parsedDate,
        tag:spaceTag.toString(),
        recomTag:hashTagButton.toString(),
        locationName: spaceLocation.toString(),
        writtenTime: writtenTime,
      );

      final userCollectionRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userCollectionRef
          .collection('post')
          .doc(post.pid)
          .set(post.toJson());
    } else {
      // 이미지 업로드 실패 처리
    }
  }

  Future<void> fetchSpaceModels() async {
    final userRef = FirebaseFirestore.instance.collection('users');

    QuerySnapshot<Map<String, dynamic>> userSnapshot = await userRef.get();

    List<SpaceInfo> fetchedSpaceModels = []; // SpaceModel 객체를 담을 리스트

    for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
      QuerySnapshot<Map<String, dynamic>> spaceSnapshot =
      await userDoc.reference.collection('space').get();

      spaceSnapshot.docs.forEach((spaceDoc) {
        Map<String, dynamic> data = spaceDoc.data();
        SpaceInfo spaceModel = SpaceInfo(
          imagePath: data['image'] ?? '',
          location: data['locationName'] ?? '',
          title: data['spaceName'] ?? '',
          tag: data['tag'] ??  '',
        );
        fetchedSpaceModels.add(spaceModel);
      });
    }

    setState(() {
      spaceInfoList = fetchedSpaceModels;
    });
  }

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    print("지금 title ${selectedTitle}");
    print("지금 해시태그 ${hashTagButton}");
    return Scaffold(
      appBar: AppBar(
        title: Text("데이로그 작성"),
        backgroundColor: Colors.black,
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _getImageFromGallery(); // 갤러리에서 이미지 가져오기
                  },
                  child: Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: selectedGalleryImage != null
                        ? Image.file(selectedGalleryImage!, fit: BoxFit.cover)
                        : Center(child: Text("    사진을\n추가하세요.")),
                  ),
                ),

                Container(
                  color: Colors.transparent,
                  height: 100,

                  child: TextFormField(
                    focusNode: _textFocusNode,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: '여러분이 해당 장소에서 함께한 내용을 작성해 주세요!!',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                Container(
                  height: 10, // 선의 높이
                  color: Colors.grey[300], // 선의 색상
                ),

                GestureDetector(
                  onTap: () {
                    _showModalBottomSheet(context);
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("공간 추가"),
                        if(selectedTitle !=null)
                          Row(
                            children: [
                              Icon(
                                Icons.place,
                              ),
                              Text("${selectedTitle}"),
                              Icon(
                                Icons.keyboard_arrow_right_outlined,
                              )
                            ],
                          ),
                        if(selectedTitle ==null)
                          Icon(
                            Icons.keyboard_arrow_right_outlined,
                          ),
                      ],
                    ),
                  ),
                ),

                Container(
                  height: 1, // 선의 높이
                  color: Colors.grey[300], // 선의 색상
                ),

                GestureDetector(
                  onTap: () {
                    _selectDate();
                  },
                  child: Container(
                    // 이거 넣어야 터치 이벤트가 된다.. 어이가없따 흥
                    color: Colors.transparent,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("방문한 날짜"),
                        Row(
                          children: [
                            Icon(
                                Icons.calendar_today
                            ),
                            SizedBox(width: 4,),
                            Text(DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                              style: TextStyle(
                                fontSize: 14,
                              ),),
                            Icon(
                              Icons.keyboard_arrow_right_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  height: 1, // 선의 높이
                  color: Colors.grey[300], // 선의 색상
                ),

                Container(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildButton('공부'),
                      SizedBox(width: 10),
                      buildButton('팀플'),
                      SizedBox(width: 10),
                      buildButton('운동'),
                      SizedBox(width: 10),
                      buildButton('산책'),
                      SizedBox(width: 10),
                      buildButton('휴식'),
                      SizedBox(width: 10),
                    ],
                  ),
                ),

                Container(
                  height: 1,
                  color: Colors.grey[300],
                ),

                Container(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("전체 공개"),
                          SizedBox(height: 5,),
                          Text("콘텐츠가 데이트립 마케팅 채널에 소개될 수 있습니다.", style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),),
                        ],
                      ),

                      IconButton(
                        // 이벤트 없이 진행할 버튼임
                        onPressed: () {
                          setState(() {
                            check1 = !check1;
                          });
                        },
                        icon: Icon(
                          Icons.check_box,
                          color: check1 ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 1,
                  color: Colors.grey[300],
                ),

                Container(
                  height: 90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("유료 광고 포함"),
                          SizedBox(height: 5,),
                          Text("제3자로부터 어떤 형태로든 콘텐츠를 만드는 대가를 ", style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),),
                          SizedBox(height: 5,),
                          Text("받았다면 표기해야 합니다.", style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),)
                        ],
                      ),

                      IconButton(
                        // 이벤트 없이 진행할 버튼임
                        onPressed: () {
                          setState(() {
                            check2 = !check2;
                          });
                        },
                        icon: Icon(
                          Icons.check_box,
                          color: check2 ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30,),

                InkWell(
                  onTap: () {
                    print(selectedTitle);
                    print(hashTagButton);
                    print(selectedGalleryImage);
                    print(_textEditingController.text);

                    if (selectedTitle == null || hashTagButton == null || selectedGalleryImage == null) {

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('경고'),
                            content: Text('빈 칸을 모두 채워주세요.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('닫기'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // 데이로그 업로드 하는 부분
                      // 재민이가 수정하면 이후에 해당 위젯 추가하면 됩니당.
                      Navigator.pop(context);
                      createPost();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          Future.delayed(Duration(seconds: 2), () {
                            Navigator.of(context).pop();
                          });

                          return AlertDialog(
                            title: Text('데이로그 업로드가 완료되었습니다.'),
                            content: Text('다른사람의 게시물과 내가 작성한 게시물은 네번째 페이지에서 확인하세요! 내 게시물은 다섯번째 페이지에 있습니다.'),
                          );
                        },
                      );
                    }
                  },
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        '데이로그 업로드',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200.0,
          color: Colors.black,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: selectedDate,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                selectedDate = newDate;
              });
            },
          ),
        );
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _showModalBottomSheet(BuildContext context){

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: spaceInfoList?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  if (spaceInfoList != null && spaceInfoList!.isNotEmpty) {
                    setState(() {
                      selectedTitle = spaceInfoList![index].title;
                      spaceTag = spaceInfoList![index].tag;
                      spaceLocation = spaceInfoList![index].location;
                    });
                    Navigator.pop(context, spaceInfoList![index].title);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Image.network(
                          spaceInfoList?[index].imagePath ?? '',
                          width: 50,
                          height: 50,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spaceInfoList?[index].title ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              spaceInfoList?[index].location ?? '',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedGalleryImage = File(pickedFile.path);
      });
    }
  }


  Widget buildButton(String buttonText) {
    return TextButton(
      onPressed: () {
        selectHashTagButton(buttonText);
      },
      child: Text(
        buttonText,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: hashTagButton == buttonText
            ? MaterialStateProperty.all<Color>(Colors.orange)
            : MaterialStateProperty.all<Color>(Colors.transparent),
        side: MaterialStateProperty.all(BorderSide(
          color: Colors.white,
          width: 1.0,
        )),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
      ),
    );
  }
}
