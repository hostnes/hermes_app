import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<dynamic> productList;

  const HomeSuccess({
    required this.productList,
  });
}

class HomeFailure extends HomeState {
  final String error;

  HomeFailure({required this.error});
}

class HomeRegionsSuccess extends HomeState {
  final List<dynamic> regionList;

  const HomeRegionsSuccess({
    required this.regionList,
  });
}

class HomeCategoriesSuccess extends HomeState {
  final List<dynamic> categoriesList;

  const HomeCategoriesSuccess({
    required this.categoriesList,
  });
}
