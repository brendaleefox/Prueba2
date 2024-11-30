import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_flutter/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  // Text Controllers
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController identificacionController = TextEditingController();
  final TextEditingController motivoVisitaController = TextEditingController();
  final TextEditingController quienVisitaController = TextEditingController();
  final TextEditingController medioTransporteController = TextEditingController();
  final TextEditingController horaEntradaController = TextEditingController();
  final TextEditingController horaSalidaController = TextEditingController();
  final TextEditingController acompanantesController = TextEditingController();

  // Open the note dialog
  void openNoteBox(String? docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre del visitante:')),
              TextField(controller: identificacionController, decoration: const InputDecoration(labelText: 'Identificación del visitante:')),
              TextField(controller: motivoVisitaController, decoration: const InputDecoration(labelText: 'Motivo de la visita:')),
              TextField(controller: quienVisitaController, decoration: const InputDecoration(labelText: 'A quién visita:')),
              TextField(controller: horaEntradaController, decoration: const InputDecoration(labelText: 'Hora de entrada:')),
              TextField(controller: horaSalidaController, decoration: const InputDecoration(labelText: 'Hora de salida:')),
              TextField(controller: medioTransporteController, decoration: const InputDecoration(labelText: 'Medio de transporte:')),
              TextField(controller: acompanantesController, decoration: const InputDecoration(labelText: 'Acompañantes:')),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (nombreController.text.isNotEmpty &&
                  identificacionController.text.isNotEmpty &&
                  motivoVisitaController.text.isNotEmpty && 
                  quienVisitaController.text.isEmpty && 
                  horaEntradaController.text.isNotEmpty && 
                  horaSalidaController.text.isEmpty && 
                  medioTransporteController.text.isEmpty &&
                  acompanantesController.text.isEmpty) {
                final data = {
                  'nombre': nombreController.text,
                  'identificacion': identificacionController.text,
                  'motivoVisita': motivoVisitaController.text,
                  'quienVisita': quienVisitaController.text,
                  'horaEntrada': horaEntradaController.text,
                  'horaSalida': horaSalidaController.text,
                  'medioTransporte': medioTransporteController.text,
                  'acompanantes': acompanantesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                };

                // If the docId is null we create a new note
                if (docID == null) {
                  firestoreService.addNote(
                    nombre: data['nombre'] as String,
                    identificacion: data['identificacion'] as String,
                    motivoVisita: data['motivoVisita'] as String,
                    quienVisita: data['quienVisita']as String,
                    horaEntrada: data['horaEntrada'] as String,
                    horaSalida: data['horaSalida'] as String,
                    medioTransporte: data['medioTransporte'] as String,
                    acompanantes: (data['acompanantes'] as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        [],
                  );
                } else {
                  // Else, update an existing note
                  firestoreService.updateNote(docID, data);
                }

                // Clear the text controllers
                nombreController.clear();
                identificacionController.clear();
                motivoVisitaController.clear();
                quienVisitaController.clear();
                horaEntradaController.clear();
                horaSalidaController.clear();
                medioTransporteController.clear();
                acompanantesController.clear();

                // Close the dialog
                Navigator.pop(context);
              } else {
                // Display error message if data is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('La informacion esta incompleta, llene todos los campos para continuar.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[900],
              foregroundColor: Colors.white,
            ),
            child: Text("Agregar Visitante"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Prueba Corta 2: Crud en Firebase",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[900],
        onPressed: () => openNoteBox(null),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                final doc = noteList[index];
                final data = doc.data() as Map<String, dynamic>;

                return ListTile(
                  title: Text("Visitante: ${data['nombre']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //Update a visitor
                      IconButton(
                        onPressed: () => openNoteBox(doc.id),
                        icon: Icon(
                          Icons.settings,
                          color: Colors.green[900],
                        ),
                      ),
                      //Delete a visitor
                      IconButton(
                        onPressed: () => firestoreService.deleteNote(doc.id),
                        icon: const Icon(Icons.delete),
                        color: Colors.green[900],
                      ),
                      //Read a Visitor
                      IconButton(
                        onPressed: () {
                         
                        },
                        icon: Icon(
                          Icons.info,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No hay visitantes."));
          }
        },
      ),
    );
  }
}
