import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class GetProductsEvent extends HomeEvent {}

class SearchProductsEvent extends HomeEvent {
  final String title;
  final String condition;
  final String subCategory;
  final String priceMin;
  final String priceMax;
  final String region;
  final String district;
  final String ownerId;
  final String sortBy;
  final String is_active;

  SearchProductsEvent({
    this.title = '',
    this.condition = '',
    this.subCategory = '',
    this.priceMin = '',
    this.priceMax = '',
    this.region = '',
    this.district = '',
    this.ownerId = '',
    this.sortBy = '',
    this.is_active = '',
  });
}

class GetCategoriesEvent extends HomeEvent {}

class GetRegionsEvent extends HomeEvent {}
