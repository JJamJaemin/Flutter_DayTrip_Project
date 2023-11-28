import 'dart:io';
import 'package:final_project/ThirdComponent/upload_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SpaceInfo {
  final String imagePath;
  final String title;
  final String location;

  SpaceInfo({
    required this.imagePath,
    required this.title,
    required this.location,
  });
}

class WriteDayLog extends StatefulWidget {

  WriteDayLog({super.key});

  @override
  State<WriteDayLog> createState() => _WriteDayLogState();
}

class _WriteDayLogState extends State<WriteDayLog> {


  File? selectedGalleryImage;
  String? hashTagButton;

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    // 위젯이 dispose 될 때 FocusNode를 해제합니다.
    _focusNode.dispose();
    super.dispose();
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


  bool check1 = false;
  bool check2 = false;
  String? selectedTitle;

  final List<SpaceInfo> spaceInfoList = [
    SpaceInfo(
      imagePath: 'asset/google.png',
      title: '신세계 백화점',
      location: '충청남도 천안시 동남구 신부동',
    ),
    SpaceInfo(
      imagePath: 'asset/kakao.png',
      title: '동춘옥',
      location: '충청남도 천안시 동남구 멍청이',
    ),
    SpaceInfo(
      imagePath: 'asset/github.png',
      title: '이슬목장',
      location: '충청남도 천안시 동남구 이슬목장',
    ),
    SpaceInfo(
      imagePath: 'asset/google.png',
      title: '신세계 백화점',
      location: '충청남도 천안시 동남구 신부동',
    ),
    SpaceInfo(
      imagePath: 'asset/kakao.png',
      title: '동춘옥',
      location: '충청남도 천안시 동남구 멍청이',
    ),
    SpaceInfo(
      imagePath: 'asset/github.png',
      title: '이슬목장',
      location: '충청남도 천안시 동남구 이슬목장',
    ),
    SpaceInfo(
      imagePath: 'asset/google.png',
      title: '신세계 백화점',
      location: '충청남도 천안시 동남구 신부동',
    ),
    SpaceInfo(
      imagePath: 'asset/kakao.png',
      title: '동춘옥',
      location: '충청남도 천안시 동남구 멍청이',
    ),
    SpaceInfo(
      imagePath: 'asset/github.png',
      title: '이슬목장',
      location: '충청남도 천안시 동남구 이슬목장',
    ),
    SpaceInfo(
      imagePath: 'asset/google.png',
      title: '신세계 백화점',
      location: '충청남도 천안시 동남구 신부동',
    ),
    SpaceInfo(
      imagePath: 'asset/kakao.png',
      title: '동춘옥',
      location: '충청남도 천안시 동남구 멍청이',
    ),
    SpaceInfo(
      imagePath: 'asset/github.png',
      title: '이슬목장',
      location: '충청남도 천안시 동남구 이슬목장',
    ),
    SpaceInfo(
      imagePath: 'asset/google.png',
      title: '신세계 백화점',
      location: '충청남도 천안시 동남구 신부동',
    ),
    SpaceInfo(
      imagePath: 'asset/kakao.png',
      title: '동춘옥',
      location: '충청남도 천안시 동남구 멍청이',
    ),
    SpaceInfo(
      imagePath: 'asset/github.png',
      title: '이슬목장',
      location: '충청남도 천안시 동남구 이슬목장',
    ),
  ];

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
                        buildButton('카페'),
                        SizedBox(width: 10),
                        buildButton('음식점'),
                        SizedBox(width: 10),
                        buildButton('편의점'),
                        SizedBox(width: 10),
                        buildButton('학교건물'),
                        SizedBox(width: 10),
                        buildButton('주차장'),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),

                Container(
                  height: 1, // 선의 높이
                  color: Colors.grey[300], // 선의 색상
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
                  height: 1, // 선의 높이
                  color: Colors.grey[300], // 선의 색상
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
                  onTap: selectedTitle !=null && hashTagButton !=null && selectedGalleryImage !=null  ? () {
                    print(selectedTitle);
                    print(hashTagButton);
                    // 데이로그 업로드 하는 부분
                    // 재민이가 수정하면 이후에 해당 위젯 추가하면 됩니당.
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UploadData()));
                  } : null,
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
          color: Colors.white,
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
            itemCount: spaceInfoList.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedTitle = spaceInfoList[index].title;
                  });

                  Navigator.pop(
                    context,
                    spaceInfoList[index].title,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Image.asset(
                          spaceInfoList[index].imagePath,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              spaceInfoList[index].title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              spaceInfoList[index].location,
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
          color: hashTagButton == buttonText ? Colors.white : Colors.black,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: hashTagButton == buttonText
            ? MaterialStateProperty.all<Color>(Colors.blue) // 선택된 버튼의 배경색
            : MaterialStateProperty.all<Color>(Colors.transparent),
        side: MaterialStateProperty.all(BorderSide(
          color: Colors.black,
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
