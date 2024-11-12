import 'package:collector_app/components/botom_navigation_bar.dart';
import 'package:collector_app/components/change_theme.dart';
import 'package:collector_app/components/my_input.dart';
import 'package:collector_app/components/product_card.dart';
import 'package:collector_app/components/styled_button.dart';
import 'package:collector_app/services/api.dart';
import 'package:collector_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  final isBottomNav;
  final isAppArrow;

  const ProfilePage({
    required this.userId,
    this.isBottomNav = true,
    this.isAppArrow = false,
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEdit = false;
  final box = Hive.box('userInfo');
  final likes_box = Hive.box('likes');

  String userId = "0";
  Map<String, dynamic> user_data = {};
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String? selectedGender = 'item1';

  List<dynamic> regions = [];
  int selectedRegionIndex = -1;
  int selectedDistrictIndex = 0;

  Map<String, dynamic> productDetails = {};
  List<dynamic> productList = [];
  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  void _fetchData() async {
    final res = await ConnectServer.getUser(widget.userId);
    final reg = await ConnectServer.getRegions();
    final prod = await ConnectServer.searchProducts(
        owner_id: widget.userId, is_active: "true");
    setState(() {
      userId = box.get('auth')['id'].toString();
    });
    setState(() {
      productList = prod;
    });

    var dis = '';
    var disr = '';
    if (res['district']['title'] != null) {
      dis = res['district']['title'];
      if (res['district']['region'] != null) {
        disr = res['district']['region'];
      }
    }
    setState(() {
      productDetails = {
        'Пол:': res['gender'] == "М" ? "Мужской" : "Женский",
        'Место нахождения:': "${dis}, ${disr}",
        'Описание:': res['description'],
      };
    });
    setState(() {
      regions = reg;
      user_data = res;
      nameController.text = user_data['name'] ?? '';
      emailController.text = user_data['email'] ?? '';
      descriptionController.text = user_data['description'] ?? '';
      phoneNumberController.text = user_data['phone_number'] ?? '';
      selectedGender = user_data['gender'] == 'М' ? 'item1' : 'item2';
    });
  }

  void _showRegionModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: regions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(regions[index]['title']),
                    onTap: () {
                      setState(() {
                        selectedRegionIndex = index;
                        selectedDistrictIndex = 0;
                      });
                      Navigator.pop(context);
                      if (regions[selectedRegionIndex]['title'] != "Все") {
                        _showDistrictModal();
                      } else {}
                    },
                  );
                },
              ),
              SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _showDistrictModal() {
    if (regions.isEmpty || selectedRegionIndex >= regions.length) return;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: regions[selectedRegionIndex]['districts'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(regions[selectedRegionIndex]['districts'][index]
                        ['title']),
                    onTap: () {
                      setState(() {
                        selectedDistrictIndex = index;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  bool validatePhoneNumber(String phone) {
    final RegExp phoneRegExp = RegExp(r'^\+375\d{9}$');
    return phoneRegExp.hasMatch(phone);
  }

  void _saveUserData() async {
    if (!validatePhoneNumber(phoneNumberController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Введите правильный белорусский номер телефона')),
      );
      return;
    }

    var user_id = await box.get('auth');
    FormData formData = FormData.fromMap({
      'name': nameController.text,
      'email': emailController.text,
      'description': descriptionController.text,
      'phone_number': phoneNumberController.text,
      'gender': selectedGender == 'item1' ? 'М' : 'Ж',
      if (_imageFile != null)
        'photo': await MultipartFile.fromFile(_imageFile!.path,
            filename: _imageFile!.path.split('/').last),
    });

    try {
      Map<String, dynamic> response =
          await ConnectServer.patchUser(user_id['id'], formData);
      Map<String, dynamic> res = await ConnectServer.getUser(userId);
      await box.put('auth', res);
      setState(() {
        user_data['name'] = nameController.text;
        user_data['email'] = emailController.text;
        user_data['phone_number'] = phoneNumberController.text;
        user_data['description'] = descriptionController.text;
        user_data['gender'] = selectedGender == 'item1' ? 'М' : 'Ж';
        if (_imageFile != null) {
          user_data['photo'] = response['photo'];
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          content: Text('Данные успешно сохранены'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении данных')),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      isEdit = !isEdit;
    });
  }

  // Separated widget for editable view
  Widget _buildEditableView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        _buildProfileImage(true),
        const SizedBox(height: 10),
        MyInput(controller: nameController, labelText: 'Имя'),
        const SizedBox(height: 10),
        MyInput(controller: emailController, labelText: 'Email'),
        const SizedBox(height: 10),
        MyInput(controller: phoneNumberController, labelText: 'Номер'),
        const SizedBox(height: 10),
        DropdownButtonFormField(
          onChanged: (value) {
            setState(() {
              selectedGender = value as String?;
            });
          },
          decoration: _buildDropdownDecoration(),
          value: selectedGender,
          items: _buildGenderDropdownItems(),
        ),
        const SizedBox(height: 10),
        MyInput(
            controller: descriptionController,
            labelText: 'Описание',
            maxLines: 2),
        const SizedBox(height: 10),
        StyledButton(
          label: selectedRegionIndex != -1
              ? "${regions[selectedRegionIndex]['title']}, ${regions[selectedRegionIndex]['districts'][selectedDistrictIndex]['title']}"
              : 'Выбрать регион',
          onPressed: _showRegionModal,
        ),
      ],
    );
  }

  // Separated widget for read-only view
  Widget _buildReadonlyView() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImage(false),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(user_data['name'],
                      style: _buildTextStyle(26, FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(user_data['email'],
                      style: _buildTextStyle(18, FontWeight.w500)),
                  const SizedBox(height: 10),
                  Text(user_data['phone_number'],
                      style: _buildTextStyle(18, FontWeight.normal)),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          ChangeTheme(),
          Divider(
            height: 2,
            endIndent: 10,
            indent: 10,
          ),
          const SizedBox(height: 10),
          ...productDetails.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                  ),
                  Flexible(
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 10),
          Divider(
            height: 2,
            endIndent: 10,
            indent: 10,
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              if (productList.isNotEmpty)
                for (var product in productList)
                  ProductCard(
                    cardData: product,
                  )
              else
                Container(
                  height: 300,
                  child: Center(
                    child: Text('Ничего не удалось найти :('),
                  ),
                ), // Пустой контейнер, если productList пуст
            ],
          )
        ],
      ),
    );
  }

  // Common widget for displaying profile image
  Widget _buildProfileImage(bool editable) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 70,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : NetworkImage(user_data['photo']) as ImageProvider,
            backgroundColor: Colors.white,
          ),
        ),
        if (editable)
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
              onTap: _pickImage,
            ),
          ),
      ],
    );
  }

  // Build gender dropdown items
  List<DropdownMenuItem<String>> _buildGenderDropdownItems() {
    return [
      DropdownMenuItem(value: 'item1', child: Text('Мужской')),
      DropdownMenuItem(value: 'item2', child: Text('Женский')),
    ];
  }

  // Build decoration for dropdown
  InputDecoration _buildDropdownDecoration() {
    return InputDecoration(
      labelText: 'Гендер',
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // Build text style
  TextStyle _buildTextStyle(double fontSize, FontWeight fontWeight) {
    return TextStyle(fontSize: fontSize, fontWeight: fontWeight);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Вы точно хотите выйти?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Отмена",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                box.delete('auth');
                likes_box.delete('likes');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthGate()),
                );
              },
              child: Text(
                "Выход",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.isAppArrow ? true : false,
        title: Text('Профиль'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: user_data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: isEdit ? _buildEditableView() : _buildReadonlyView(),
              ),
            ),
      floatingActionButton: userId == widget.userId
          ? FloatingActionButton(
              onPressed: () {
                if (isEdit) {
                  _saveUserData();
                }
                _toggleEdit();
              },
              child: Icon(
                isEdit ? Icons.save : Icons.edit,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            )
          : Container(),
      bottomNavigationBar: widget.isBottomNav == true
          ? BotomNavigationBar(selectedIndex: 3)
          : null,
    );
  }
}
