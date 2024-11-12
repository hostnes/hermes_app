import 'package:collector_app/components/botom_navigation_bar.dart';
import 'package:collector_app/components/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> filtersList = [
    'Состояние',
    'Сортировка',
    'Цена',
    'Регион',
    'Категория',
  ];
  final List<String> conditionOptions = [
    '-',
    'Новое',
    'Б/У',
  ];
  final List<Map<String, String>> sortOptions = [
    {
      'title': '-',
      'bac': '',
    },
    {
      'title': 'По дате возростание',
      'bac': 'date',
    },
    {
      'title': 'По дате убывание',
      'bac': '-date',
    },
    {
      'title': 'По цене возростание',
      'bac': 'cost',
    },
    {
      'title': 'По цене убывание',
      'bac': '-cost',
    },
  ];
  List<dynamic> productList = [];
  bool isLoading = false;
  String errorMessage = '';
  int selectedCondition = 0;
  int selectedSort = 0;
  List<dynamic> regions = [];
  List<dynamic> categories = [];

  int selectedRegionIndex = 0;
  int selectedDistrictIndex = 0;

  int selectedCategoryIndex = 0;
  int selectedSubCategoryIndex = -1;
  RangeValues selectedPriceRange = RangeValues(0, 10000);
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isFocus = false;
  final _homeBlock = HomeBloc();

  void _updateProducts(List<dynamic> products) {
    setState(() {
      productList = products;
      isLoading = false;
      errorMessage = '';
    });
  }

  void _showError(String error) {
    setState(() {
      productList = [];
      isLoading = false;
      errorMessage = error;
    });
  }

  void _searchProducts() {
    _homeBlock.add(SearchProductsEvent(
        title: _searchController.text,
        condition: conditionOptions[selectedCondition] != '-'
            ? conditionOptions[selectedCondition] == "Б/У"
                ? "Б"
                : "Н"
            : '',
        subCategory: selectedSubCategoryIndex != -1
            ? categories[selectedCategoryIndex]['sub_categories']
                    [selectedSubCategoryIndex]['id']
                .toString()
            : '',
        priceMin: selectedPriceRange.start.toString() != '0.0'
            ? selectedPriceRange.start.toString()
            : '',
        priceMax: selectedPriceRange.end.toString() != '10000.0'
            ? selectedPriceRange.end.toString()
            : '',
        region: selectedRegionIndex != 0
            ? regions[selectedRegionIndex]['id'].toString()
            : '',
        district: selectedDistrictIndex != 0
            ? regions[selectedRegionIndex]['districts'][selectedDistrictIndex]
                    ['id']
                .toString()
            : '',
        ownerId: '',
        sortBy: selectedSort == 0
            ? ''
            : sortOptions[selectedSort]['bac'].toString(),
        is_active: 'true'));
  }

  @override
  void initState() {
    _homeBlock.add(SearchProductsEvent());
    _homeBlock.add(GetCategoriesEvent());
    _homeBlock.add(GetRegionsEvent());

    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isFocus = _focusNode.hasFocus;
      });
    });
  }

  void _showConditionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: conditionOptions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(conditionOptions[index]),
                    onTap: () {
                      setState(() {
                        selectedCondition = index;
                      });
                      _searchProducts();

                      Navigator.pop(context);
                    },
                  );
                },
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        );
      },
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: sortOptions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(sortOptions[index]['title'].toString()),
                    onTap: () {
                      setState(() {
                        selectedSort = index;
                      });
                      _searchProducts();

                      Navigator.pop(context);
                    },
                  );
                },
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        );
      },
    );
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
                      } else {
                        _searchProducts();
                      }
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
        List distrList = [];
        distrList = regions[selectedRegionIndex]['districts'];
        if (distrList[0]['title'] != "Все") {
          distrList.insert(
            0,
            {
              "title": "Все",
            },
          );
        }
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
                      _searchProducts();
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
                        } else {
                          _searchProducts();
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
                        _searchProducts();
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

  void _showPriceRangeModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Выберите диапазон цен'),
                RangeSlider(
                  values: selectedPriceRange,
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  labels: RangeLabels(
                    selectedPriceRange.start.round().toString(),
                    selectedPriceRange.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    setModalState(() {
                      selectedPriceRange = values;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setModalState(() {
                          selectedPriceRange = RangeValues(0, 10000);
                        });
                        _searchProducts();
                      },
                      child: Container(
                        height: 40,
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: Text(
                          'Сбросить',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPriceRange = selectedPriceRange;
                        });
                        _searchProducts();
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 40,
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: Text(
                          'Применить',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          toolbarHeight: 110,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          automaticallyImplyLeading: false,
          title: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      child: TextField(
                        focusNode: _focusNode,
                        cursorColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        controller: _searchController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          labelText: 'Поиск',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  if (isFocus)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          _searchProducts();
                          FocusScope.of(context).unfocus();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          width: 80,
                          height: 45,
                          child: Center(
                            child: Text(
                              'Найти',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtersList.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (index == 0) {
                              _showConditionModal();
                            } else if (index == 1) {
                              _showSortModal();
                            } else if (index == 2) {
                              _showPriceRangeModal();
                            } else if (index == 3) {
                              if (regions != []) {
                                _showRegionModal();
                              }
                            } else if (index == 4) {
                              if (categories != []) {
                                _showCategoryModal();
                              }
                            }
                          },
                          child: Container(
                            height: 38,
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            child: Text(
                              index == 0
                                  ? selectedCondition != 0
                                      ? filtersList[index] +
                                          ": " +
                                          conditionOptions[selectedCondition]
                                      : filtersList[index]
                                  : index == 1
                                      ? selectedSort != 0
                                          ? filtersList[index] +
                                              ": " +
                                              sortOptions[index]['title']
                                                  .toString()
                                          : filtersList[index]
                                      : index == 2
                                          ? selectedPriceRange ==
                                                  const RangeValues(0, 10000)
                                              ? filtersList[index]
                                              : filtersList[index] +
                                                  ': ' +
                                                  selectedPriceRange.start
                                                      .toString() +
                                                  ' - ' +
                                                  selectedPriceRange.end
                                                      .toString()
                                          : index == 3
                                              ? selectedDistrictIndex != 0
                                                  ? filtersList[index] +
                                                      ": " +
                                                      regions[selectedRegionIndex]
                                                          ['title'] +
                                                      ", " +
                                                      regions[selectedRegionIndex]
                                                                  ['districts'][
                                                              selectedDistrictIndex]
                                                          ['title']
                                                  : selectedRegionIndex != 0
                                                      ? filtersList[index] +
                                                          ": " +
                                                          regions[selectedRegionIndex]
                                                              ['title']
                                                      : filtersList[index]
                                              : index ==
                                                      4 // Display selected region/district
                                                  ? selectedSubCategoryIndex !=
                                                          -1
                                                      ? filtersList[index] +
                                                          ": " +
                                                          categories[selectedCategoryIndex]
                                                                      ['sub_categories']
                                                                  [
                                                                  selectedSubCategoryIndex]
                                                              ['title']
                                                      : filtersList[index]
                                                  : '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (index < filtersList.length - 1) SizedBox(width: 30),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      body: BlocListener<HomeBloc, HomeState>(
        bloc: _homeBlock,
        listener: (context, state) {
          if (state is HomeSuccess) {
            _updateProducts(state.productList);
          } else if (state is HomeLoading) {
            setState(() => isLoading = true);
          } else if (state is HomeFailure) {
            _showError(state.error);
          }
          if (state is HomeCategoriesSuccess) {
            state.categoriesList.insert(
              0,
              {"title": "Все", "sub_categories": []},
            );
            setState(() {
              categories = state.categoriesList;
            });
          }
          if (state is HomeRegionsSuccess) {
            state.regionList.insert(
              0,
              {"title": "Все", "districts": []},
            );
            setState(() {
              regions = state.regionList;
            });
          }
        },
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : productList.isNotEmpty
                    ? ListView.builder(
                        itemCount: productList.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            cardData: productList[index],
                          );
                        },
                      )
                    : Center(
                        child: Text('Ничего не удалось найти :('),
                      ),
      ),
      bottomNavigationBar: BotomNavigationBar(selectedIndex: 0),
    );
  }
}
