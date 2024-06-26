import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:final_project/model_db/space.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:final_project/Screen/map_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';


class AddNewExhibition extends StatefulWidget {
  const AddNewExhibition({super.key});

  @override
  State<AddNewExhibition> createState() => _AddNewExhibitionState();
}

class _AddNewExhibitionState extends State<AddNewExhibition> {

  late GoogleMapController mapController;
  File? selectedGalleryImage;
  String? hashTagButton;
  String? spacexy;
  LatLng? newSpaceLocation;
  DateTime selectedDate = DateTime.now();
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController1 = TextEditingController();
  Set<Marker> _markers = {};

  void _onMapTapped(LatLng location) async {
    setState(() {
      newSpaceLocation = location;
      spacexy = newSpaceLocation.toString();

      _markers.clear();

      _markers.add(
        Marker(
          markerId: MarkerId('newSpace'),
          position: location,
          infoWindow: InfoWindow(
            title: '추가 할 공간의 위치',
            snippet: '위도: ${location.latitude}, 경도: ${location.longitude}',
          ),
        ),
      );
    });
  }

  // 해시태그 버튼
  void selectHashTagButton(String buttonText) {
    setState(() {
      if (hashTagButton == buttonText) {
        hashTagButton = ''; // 이미 선택된 버튼을 다시 누르면 선택 해제
      } else {
        hashTagButton = buttonText; // 새로운 버튼을 선택
        print('Selected button text: ${hashTagButton}');
      }
    });
  }

  void dispose() {
    // 페이지가 dispose될 때 컨트롤러 삭제
    _textEditingController.dispose();
    _textEditingController1.dispose();
    super.dispose();
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

  Future<void> createSpace() async {
    final String? imageUrl = await uploadCompressedImageToFirebaseStorage(selectedGalleryImage!);

    if (imageUrl != null) {
      final String formattedDateString = DateFormat('yyyy년 MM월 dd일').format(selectedDate);
      final DateTime parsedDate = DateFormat('yyyy년 MM월 dd일').parse(formattedDateString);
      final String address = await _getAddressFromLatLng(newSpaceLocation!);
      print('주소:${address}');

      final space = SpaceModel.full(
        spaceName: _textEditingController.text,
        location: newSpaceLocation.toString(),
        tag: '문화',
        image: imageUrl,
        locationName: address,
        exhibiTag: hashTagButton.toString(),
        exhibiDate: parsedDate,
        exhibiName: _textEditingController1.text,
      );

      final user = FirebaseAuth.instance.currentUser!;
      final userCollectionRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userCollectionRef.collection('space')
          .doc(space.spaceName)
          .set(space.toJson());
      // print('장소 이름: ${space.spaceName}');
      // print('위치: ${space.location}');
      // print('태그: ${space.tag}');
      // print('이미지 URL: ${space.image}');
      // print('주소: ${space.locationName}');

    } else {
      // 이미지 업로드 실패 처리
    }
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    final apiKey = 'AIzaSyD1ubnmfNlwjq9hDqMpfinM5P4Rr585FaU';
    final endpoint = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${newSpaceLocation?.latitude},${newSpaceLocation?.longitude}&key=$apiKey &language=ko');

    final response = await http.get(endpoint);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['status'] == 'OK') {
        return decoded['results'][0]['formatted_address'];
      }
    }
    return 'Address not found';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("새로운 전시∙행사 추가 "),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
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
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: selectedGalleryImage != null
                          ? Image.file(selectedGalleryImage!, fit: BoxFit.cover)
                          : Center(child: Text("    사진을\n추가하세요.")),
                    ),
                  ),
                  SizedBox(height: 10,),

                  Container(
                    width: double.infinity,
                    height: 270,
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        setState(() {
                          mapController = controller;
                          controller.setMapStyle(darkMapStyle);
                        });
                      },
                      onTap: _onMapTapped,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(36.83407, 127.1793),
                        zoom: 15.0,
                      ),
                      markers: _markers,
                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                      ].toSet(),

                    ),
                  ),

                  SizedBox(height: 20,),


                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black26, //Colors.grey[300],
                    ),

                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("위도: ${newSpaceLocation?.latitude ?? ''}"),
                          SizedBox(height: 5,),
                          Text("경도: ${newSpaceLocation?.longitude ?? ''}"),

                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),

                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black26,
                    ),

                    child: Padding(
                      padding: const EdgeInsets.only(left: 20,),
                      child: TextFormField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          hintText: '장소 이름을 입력하세요.',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),

                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black26,
                    ),

                    child: Padding(
                      padding: const EdgeInsets.only(left: 20,),
                      child: TextFormField(
                        controller: _textEditingController1,
                        decoration: InputDecoration(
                          hintText: '전시 행사 이름을 입력하세요.',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10,),

                  Container(
                    height: 1, // 선의 높이
                    color: Colors.grey[300], // 선의 색상
                  ),

                  Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildButton('전시'),
                        SizedBox(width: 10),
                        buildButton('팝업'),
                        SizedBox(width: 10),
                        buildButton('공연'),
                        SizedBox(width: 10),
                        buildButton('축제'),
                        SizedBox(width: 10),
                      ],
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("시작 날짜: "),
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

                  SizedBox(height: 10,),

                  InkWell(
                    onTap: () {
                      if(_textEditingController.text == null || _textEditingController1.text==null || spacexy == null || selectedGalleryImage == null || hashTagButton == null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('경고'),
                              content: Text('빈 칸을 모두 채워주세요.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the alert dialog
                                  },
                                  child: Text('확인'),
                                ),
                              ],
                            );
                          },
                        );
                      }else {
                        String enteredText = _textEditingController.text;
                        print('입력된 텍스트: $enteredText');
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              Future.delayed(Duration(seconds: 1), () {
                                Navigator.of(context).pop();
                              });

                              return AlertDialog(
                                title: Text('행사가 추가되었습니다'),
                                content: Text('한 줄 평 작성할 때 확인 가능합니다.'),
                              );
                            }
                        );
                        createSpace();
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
                          '공간 추가',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
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
          color: hashTagButton == buttonText ? Colors.white : Colors.white,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: hashTagButton == buttonText
            ? MaterialStateProperty.all<Color>(Colors.orange)
            : MaterialStateProperty.all<Color>(Colors.transparent),
        side: MaterialStateProperty.all(BorderSide(color: Colors.white, width: 1.0,)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
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
                final String formattedDateString = DateFormat('yyyy년 MM월 dd일').format(selectedDate);
                final DateTime parsedDate = DateFormat('yyyy년 MM월 dd일').parse(formattedDateString);
                print('데이트타임: ${parsedDate}');
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
}