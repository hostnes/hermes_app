import 'dart:io';
import 'package:collector_app/services/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';

class CreateProduct extends StatefulWidget {
  const CreateProduct({super.key});

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  String errorCat = '';
  final box = Hive.box('userInfo');
  List<dynamic> categories = [];
  int selectedCategoryIndex = 0;
  int selectedSubCategoryIndex = -1;

  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  double cost = 0.0;
  DateTime? selectedDate;
  String condition = 'Новое';
  List<XFile> images = [];

  final ImagePicker _picker = ImagePicker();
  final _homeBlock = HomeBloc();

  Future<void> _pickImages() async {
    final List<XFile>? pickedImages =
        await _picker.pickMultiImage(imageQuality: 50);
    if (pickedImages != null) {
      setState(() {
        if (pickedImages.length > 8) {
          images = pickedImages.sublist(0, 8);
        } else {
          images = pickedImages;
        }
      });
    }
  }

  @override
  void initState() {
    _homeBlock.add(GetCategoriesEvent());
    super.initState();
  }

  void _showCategoryModal() {
    setState(() {
      selectedSubCategoryIndex = -1;
    });
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(categories[index]['title']),
                      onTap: () {
                        setState(() {
                          selectedCategoryIndex = index;
                        });
                        Navigator.pop(context);
                        if (categories[selectedCategoryIndex]['title'] !=
                            "Все") {
                          _showSubCategoryModal();
                        }
                      },
                    );
                  },
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSubCategoryModal() {
    if (categories.isEmpty || selectedCategoryIndex >= categories.length)
      return;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        List subCategoriesList = [];
        subCategoriesList = categories[selectedCategoryIndex]['sub_categories'];
        return Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: subCategoriesList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(subCategoriesList[index]['title']),
                      onTap: () {
                        setState(() {
                          selectedSubCategoryIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitForm() async {
    if (selectedSubCategoryIndex == -1) {
      setState(() {
        errorCat = 'Выберите категорию';
      });
    } else if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final productData = {
        'title': title,
        'description': description,
        'cost': cost.toString(),
        'condition': condition == "Новое" ? "Н" : "Б",
        'owner': box.get('auth')['id'].toString(),
        'sub_category': categories[selectedCategoryIndex]['sub_categories']
                [selectedSubCategoryIndex]['id']
            .toString(),
      };

      try {
        // Send data to create the product
        final productResponse = await ConnectServer.createProduct(productData);

        if (productResponse['id'] != null) {
          // Product created successfully
          print('Product created: ${productResponse['id']}');

          // Now upload images
          await _uploadImages(productResponse['id'], images);
        } else {
          // Handle error (e.g., show an error message)
          print('Failed to create product: ${productResponse.toString()}');
        }
      } catch (e) {
        // Handle exception (e.g., show error message)
        print('Error occurred: $e');
      }
      Navigator.pop(context, true);
    }
    if (selectedSubCategoryIndex != -1) {
      setState(() {
        errorCat = '';
      });
    }
  }

  Future<void> _uploadImages(int productId, List<XFile> images) async {
    final formData = FormData();

    for (var image in images.take(8)) {
      // Add images to the form data
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(image.path, filename: image.name),
        ),
      );
    }

    try {
      // Send data to upload images
      final imageResponse =
          await ConnectServer.uploadProductImages(productId, formData);
      if (imageResponse['success']) {
        // Images uploaded successfully
        print('Images uploaded successfully for product: $productId');
      } else {
        // Handle error (e.g., show an error message)
        print('Failed to upload images: ${imageResponse.toString()}');
      }
    } catch (e) {
      // Handle exception (e.g., show error message)
      print('Error occurred while uploading images: $e');
    }
  }

  Widget _styledButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledInputField({
    required String labelText,
    required FormFieldSetter<String> onSaved,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
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
      ),
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание продукта'),
      ),
      body: BlocListener<HomeBloc, HomeState>(
        bloc: _homeBlock,
        listener: (context, state) {
          if (state is HomeCategoriesSuccess) {
            state.categoriesList.insert(
              0,
              {"title": "Все", "sub_categories": []},
            );
            setState(() {
              categories = state.categoriesList;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _styledInputField(
                    labelText: 'Название продукта',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите название';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      title = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  _styledInputField(
                    labelText: 'Описание',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите описание';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      description = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  _styledInputField(
                    labelText: 'Цена',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите цену';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      cost = double.parse(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: condition,
                    decoration: const InputDecoration(
                      labelText: 'Состояние',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Новое', 'Б/У'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        condition = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {},
                    child: _styledButton(
                      selectedSubCategoryIndex != -1
                          ? categories[selectedCategoryIndex]['sub_categories']
                              [selectedSubCategoryIndex]['title']
                          : 'Выбрать категорию',
                      _showCategoryModal,
                    ),
                  ),
                  Text(
                    errorCat,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Фотографии (максимум 8)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _styledButton('Выбрать фотографии', _pickImages),
                  const SizedBox(height: 8),
                  images.isNotEmpty
                      ? Wrap(
                          spacing: 8.0,
                          children: images
                              .map(
                                (image) => Image.file(
                                  File(image.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                              .toList(),
                        )
                      : const Text('Не выбрано ни одной фотографии'),
                  const SizedBox(height: 16),
                  _styledButton('Создать продукт', _submitForm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
