import 'package:cloud_firestore/cloud_firestore.dart';
import 'servicioremotos.dart';
import 'package:flutter/material.dart';

class AppFirebase extends StatefulWidget {
  const AppFirebase({Key? key});

  @override
  State<AppFirebase> createState() => _AppFirebaseState();
}

class _AppFirebaseState extends State<AppFirebase> {
  String mensaje = "";
  int _index = 0;
  var actualizarVar;

  final nombre = TextEditingController();
  final duracion = TextEditingController();
  final numSala = TextEditingController();
  final horaFuncion = TextEditingController();
  final generoController = TextEditingController();

  final nombreA = TextEditingController();
  final duracionA = TextEditingController();
  final numSalaA = TextEditingController();
  final horaFuncionA = TextEditingController();
  final generoControllerA = TextEditingController();

  // Función para validar si una cadena es un número entero
  bool esEntero(String value) {
    try {
      int.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cinememex"),
        centerTitle: true,
        backgroundColor: Colors.redAccent, // Color de la barra de navegación
      ),
      body: Stack(
        children: [
          dinamico(),
          if (mensaje.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green, // Color del mensaje de éxito
                child: Text(
                  mensaje,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _index = 1;
            actualizarVar = null;
            mensaje = "";
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.redAccent, // Color del botón de añadir
      )
          : null,
    );
  }

  Widget dinamico() {
    if (_index == 1) {
      return capturar();
    }
    if (_index == 2) {
      return actualizar();
    }
    return cargarData();
  }

  Widget cargarData() {
    return FutureBuilder(
      future: DB.mostrarTodos(),
      builder: (context, listaJSON) {
        if (listaJSON.hasData) {
          return ListView.builder(
            itemCount: listaJSON.data?.length,
            itemBuilder: (context, indice) {
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    "${listaJSON.data?[indice]['nombrePelicula']}",
                    style: TextStyle(color: Colors.redAccent), // Color del nombre de la película
                  ),
                  subtitle: Text(
                    "Género: ${listaJSON.data?[indice]['generoPelicula']}\n"
                        "Duración: ${listaJSON.data?[indice]['duracion']} minutos\n"
                        "Sala: ${listaJSON.data?[indice]['numSala']}\n"
                        "Hora de Función: ${listaJSON.data?[indice]['horaFuncion']}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _index = 2;
                            actualizarVar = listaJSON.data?[indice];
                            mensaje = ""; // Limpiar mensajes anteriores al editar
                          });
                        },
                        icon: const Icon(Icons.edit),
                        color: Colors.orangeAccent, // Color del icono de editar
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (builder) {
                              return AlertDialog(
                                title: const Text("Confirmar"),
                                content: const Text("¿Estás seguro de que deseas eliminar?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      DB.eliminar(listaJSON.data?[indice]['id']).then((value) {
                                        setState(() {
                                          mensaje = "Se borró la película correctamente";
                                        });
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text("SÍ"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("NO"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete),
                        color: Colors.redAccent, // Color del icono de eliminar
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget actualizar() {
    nombreA.text = actualizarVar?['nombrePelicula'];
    duracionA.text = (actualizarVar?['duracion']).toString();
    numSalaA.text = (actualizarVar?['numSala']).toString();
    horaFuncionA.text = actualizarVar?['horaFuncion'];
    generoControllerA.text = actualizarVar?['generoPelicula'];

    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        TextField(
          controller: nombreA,
          decoration: const InputDecoration(
            labelText: "Nombre de la Película",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: generoControllerA,
          decoration: const InputDecoration(
            labelText: "Género",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: duracionA,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Duración",
          ),
        ),
        if (!esEntero(duracionA.text))
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              "Por favor, ingrese un número entero para la duración.",
              style: TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 10),
        TextField(
          controller: numSalaA,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Número de Sala",
          ),
        ),
        if (!esEntero(numSalaA.text))
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              "Por favor, ingrese un número entero para el número de sala.",
              style: TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            // Mostrar el selector de tiempo al hacer clic en el campo de texto
            TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (selectedTime != null) {
              // Actualizar el campo de texto con la hora seleccionada
              horaFuncionA.text = selectedTime.format(context);
            }
          },
          child: IgnorePointer(
            child: TextField(
              controller: horaFuncionA,
              decoration: const InputDecoration(
                labelText: "Hora de Función",
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                if (esEntero(duracionA.text) && esEntero(numSalaA.text)) {
                  var JSonTemporal = {
                    'id': actualizarVar?['id'],
                    'nombrePelicula': nombreA.text,
                    'generoPelicula': generoControllerA.text,
                    'duracion': int.parse(duracionA.text),
                    'numSala': int.parse(numSalaA.text),
                    'horaFuncion': horaFuncionA.text,
                  };

                  DB.actualizar(JSonTemporal).then((value) {
                    setState(() {
                      mensaje = "Se actualizó la película correctamente";
                      nombreA.clear();
                      duracionA.clear();
                      numSalaA.clear();
                      horaFuncionA.clear();
                      generoControllerA.clear();
                      _index = 0;
                    });
                  });
                } else {
                  setState(() {
                    mensaje =
                    "Por favor, corrija los errores antes de actualizar.";
                  });
                }
              },
              child: const Text("Actualizar"),
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent, // Color del botón de actualizar
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _index = 0;
                });
              },
              child: const Text("Cancelar"),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey, // Color del botón de cancelar
              ),
            ),
          ],
        ),
        if (mensaje.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              mensaje,
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget capturar() {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        TextField(
          controller: nombre,
          decoration: const InputDecoration(
            labelText: "Nombre de la Película",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: generoController,
          decoration: const InputDecoration(
            labelText: "Género",
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: duracion,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Duración",
          ),
        ),
        if (!esEntero(duracion.text))
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              "Por favor, ingrese un número entero para la duración.",
              style: TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 10),
        TextField(
          controller: numSala,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Número de Sala",
          ),
        ),
        if (!esEntero(numSala.text))
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              "Por favor, ingrese un número entero para el número de sala.",
              style: TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            // Mostrar el selector de tiempo al hacer clic en el campo de texto
            TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (selectedTime != null) {
              // Actualizar el campo de texto con la hora seleccionada
              horaFuncion.text = selectedTime.format(context);
            }
          },
          child: IgnorePointer(
            child: TextField(
              controller: horaFuncion,
              decoration: const InputDecoration(
                labelText: "Hora de Función",
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                if (esEntero(duracion.text) && esEntero(numSala.text)) {
                  var JSonTemporal = {
                    'nombrePelicula': nombre.text,
                    'generoPelicula': generoController.text,
                    'duracion': int.parse(duracion.text),
                    'numSala': int.parse(numSala.text),
                    'horaFuncion': horaFuncion.text,
                  };

                  DB.insertar(JSonTemporal).then((value) {
                    setState(() {
                      mensaje =
                      "Se insertó la película '${nombre.text}' correctamente";
                      nombre.clear();
                      generoController.clear();
                      duracion.clear();
                      numSala.clear();
                      horaFuncion.clear();
                      _index = 0;
                    });
                  });
                } else {
                  setState(() {
                    mensaje =
                    "Por favor, corrija los errores antes de insertar.";
                  });
                }
              },
              child: const Text("Insertar"),
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent, // Color del botón de insertar
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _index = 0;
                });
              },
              child: const Text("Cancelar"),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey, // Color del botón de cancelar
              ),
            ),
          ],
        ),
        if (mensaje.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              mensaje,
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
}