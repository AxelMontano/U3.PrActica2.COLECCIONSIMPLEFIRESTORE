import 'package:cloud_firestore/cloud_firestore.dart';

var baseRemota = FirebaseFirestore.instance;

class DB {
  static Future insertar(Map<String, dynamic> pelicula) async {
    return await baseRemota.collection("CINE").add(pelicula);
  }

  static Future<List> mostrarTodos() async {
    List temporal = [];
    var query = await baseRemota.collection("CINE").get();

    query.docs.forEach((element) {
      Map<String, dynamic> data = element.data();
      data.addAll({
        'id': element.id
      });
      temporal.add(data);
    });
    return temporal;
  }

  static Future eliminar(String id) async {
    return await baseRemota.collection("CINE").doc(id).delete();
  }

  static Future actualizar(Map<String, dynamic> pelicula) async {
    String id = pelicula['id'];
    pelicula.remove(id);
    return await baseRemota.collection("CINE").doc(id).update(pelicula);
  }
}