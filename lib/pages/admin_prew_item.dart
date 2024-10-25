import 'dart:io';
import 'package:collector_app/services/admin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminPrewItem extends StatefulWidget {
  final String modelName;
  final Map<String, dynamic> itemData;
  final bool adminEdit;
  final bool adminDelete;
  final bool adminAdd;

  const AdminPrewItem({
    required this.modelName,
    required this.itemData,
    required this.adminEdit,
    required this.adminDelete,
    required this.adminAdd,
  });

  @override
  State<AdminPrewItem> createState() => _AdminPrewItemState();
}

class _AdminPrewItemState extends State<AdminPrewItem> {
  bool isEdit = false;
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
        controllers[key] = TextEditingController(text: value);
      }
    });
  }

  @override
  void dispose() {
    controllers.forEach((_, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      isEdit = !isEdit;
    });
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

    final func = adminActions('patch', widget.modelName);
    func(widget.itemData['id'], formData);

    setState(() {
      isEdit = false;
    });

    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _deleteItem() {
    final func = adminActions('delete', widget.modelName);
    func(widget.itemData['id']);
    Navigator.pop(context, widget.itemData);
  }

  Widget _buildField(String key, dynamic value, ColorScheme colorScheme) {
    if (key == 'photo') {
      return _buildPhotoSection(value, colorScheme);
    } else if (controllers.containsKey(key)) {
      return _buildEditableTextSection(key, controllers[key]!, colorScheme);
    } else {
      return _buildTextSection(key, value, colorScheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Item Preview'),
        backgroundColor: colorScheme.tertiary,
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
                if (widget.adminEdit)
                  GestureDetector(
                    onTap: isEdit ? _saveItemData : _toggleEdit,
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
                if (widget.adminDelete)
                  GestureDetector(
                    onTap: _deleteItem,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          )),
                      child: Row(
                        children: [
                          Text('Удалить'),
                          SizedBox(width: 10),
                          Icon(Icons.delete),
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
                maxLines: 3,
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
