import 'dart:io';

import 'package:collector_app/services/admin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminCreate extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String modelName;

  const AdminCreate({
    super.key,
    required this.itemData,
    required this.modelName
  });

  @override
  State<AdminCreate> createState() => _AdminCreateState();
}

class _AdminCreateState extends State<AdminCreate> {
  final isEdit = true;
  late Map<String, dynamic> _editedData;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _editedData = Map<String, dynamic>.from(widget.itemData);

    widget.itemData.forEach((key, value) {
      if (value is String) {
        controllers[key] = TextEditingController(text: '');
      }
    });
  }

  Widget _buildField(String key, dynamic value, ColorScheme colorScheme) {
    if (key == 'photo') {
      return _buildPhotoSection(
          'http://127.0.0.1:8002/media/users/none_logo_qpkD1NW.png',
          colorScheme);
    } else if (controllers.containsKey(key)) {
      return _buildEditableTextSection(key, controllers[key]!, colorScheme);
    } else {
      return _buildTextSection(key, '', colorScheme);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

    void _saveItemData() async {
    controllers.forEach((key, controller) {
      _editedData[key] = controller.text;
    });

    FormData formData = FormData();

    _editedData.forEach((key, value) {
      if (key != 'id') {
        if (key != 'photo') {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      }
    });

    if (_imageFile != null) {
      formData.files.add(MapEntry(
        'photo',
        await MultipartFile.fromFile(_imageFile!.path, filename: 'image.jpg'),
      ));
    }

    final func = adminActions('post', widget.modelName);
    func(formData);


    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            color: colorScheme.tertiary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: _editedData.entries.map((entry) {
                  if (entry.value is String) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField(entry.key, entry.value, colorScheme),
                        Divider(
                          thickness: 1,
                          color: colorScheme.inversePrimary.withOpacity(0.5),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 0),
                  GestureDetector(
                    onTap: _saveItemData,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          )),
                      child: Row(
                        children: [
                          Text(isEdit ? 'Сохранить' : 'Изменить'),
                          SizedBox(width: 10),
                          Icon(isEdit ? Icons.save : Icons.edit),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(String url, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHOTO',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _imageFile != null
              ? Image.file(
                  _imageFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  url,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: colorScheme.primary.withOpacity(0.2),
                      child: Center(
                        child: Text(
                          'Failed to load image',
                          style: TextStyle(color: colorScheme.inversePrimary),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 10),
        if (isEdit)
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Изменить фото'),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEditableTextSection(
      String key, TextEditingController controller, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          key.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        isEdit
            ? TextFormField(
                controller: controller,
                minLines: 1,
                decoration: InputDecoration(
                  labelText: 'Edit $key',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            : Text(
                controller.text,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.inversePrimary,
                ),
              ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextSection(String key, dynamic value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          key.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.inversePrimary,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
