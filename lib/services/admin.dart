import 'package:collector_app/services/api.dart';

dynamic getProducts() async {
  final res = await ConnectServer.searchProducts();
  return res;
}

void patchProduct(productId, body) async {
  await ConnectServer.patchProduct(productId.toString(), body);
}

void deleteProduct(productId) async {
  ConnectServer.deleteProduct(productId.toString());
}

void deleteUser(productId) async {
  ConnectServer.deleteUser(productId.toString());
}

void postProduct(body) async {
  ConnectServer.createProduct(body);
}

dynamic getUsers() async {
  final res = await ConnectServer.getUsers();
  return res;
}

void patchUser(productId, body) async {
  await ConnectServer.patchUser(productId.toString(), body);
}

void postUser(body) async {
  ConnectServer.register(email: body);
}

Function adminActions(method, model) {
  if (model == 'Products') {
    if (method == 'get') return getProducts;
    if (method == 'delete') return deleteProduct;
    if (method == 'patch') return patchProduct;
    if (method == 'post') return postProduct;
  }
  if (model == 'Users') {
    if (method == 'get') return getUsers;
    if (method == 'delete') return deleteUser;
    if (method == 'patch') return patchUser;
    if (method == 'post') return postUser;
  }

  return () {};
}
