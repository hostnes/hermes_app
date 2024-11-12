import 'package:bloc/bloc.dart';
import '../../services/api.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<GetProductsEvent>(
      (GetProductsEvent event, Emitter<HomeState> emit) async {
        emit(HomeLoading());
        try {
          final res = await ConnectServer.getProducts();
          emit(HomeSuccess(productList: res));
        } catch (e) {
          print(e);
          emit(HomeFailure(error: 'Ошибка авторизации'));
        }
      },
    );
    on<SearchProductsEvent>(
      (SearchProductsEvent event, Emitter<HomeState> emit) async {
        emit(HomeLoading());
        try {
          final res = await ConnectServer.searchProducts(
            title: event.title,
            condition: event.condition,
            sub_category: event.subCategory,
            price_min: event.priceMin,
            price_max: event.priceMax,
            region: event.region,
            district: event.district,
            owner_id: event.ownerId,
            sort_by: event.sortBy,
            is_active: event.is_active,
          );
          print(res);
          emit(HomeSuccess(productList: res));
        } catch (e) {
          print(e);
          emit(HomeFailure(error: 'Ошибка при загрузке продуктов'));
        }
      },
    );
    on<GetCategoriesEvent>(
      (GetCategoriesEvent event, Emitter<HomeState> emit) async {
        final res = await ConnectServer.getCategories();
        emit(HomeCategoriesSuccess(categoriesList: res));
      },
    );
    on<GetRegionsEvent>(
      (GetRegionsEvent event, Emitter<HomeState> emit) async {
        final res = await ConnectServer.getRegions();
        emit(HomeRegionsSuccess(regionList: res));
      },
    );
  }
}
