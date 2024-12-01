import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  //This will get the collection of note
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');

  //Create:
  //This will create a new visitor on the database
  Future<void> addNote({
    required String nombre,
    required String identificacion,
    required String motivoVisita,
    required String quienVisita,
    required String horaEntrada,
    required String horaSalida,
    required String medioTransporte,
    required String acompanantes,
  }) {
    return notes.add({
      'nombre': nombre,
      'identificacion': identificacion,
      'motivoVisita': motivoVisita,
      'quienVisita': quienVisita,
      'horaEntrada': horaEntrada,
      'horaSalida': horaSalida,
      'medioTransporte': medioTransporte,
      'acompanantes': acompanantes,
      'timestamp': Timestamp.now(),
    });
  }
  
  //Read:
  //This will get the visitor details we create from the database
  Stream<QuerySnapshot> getNotesStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  //Update
  //This will update the visitors we create givin a document id.
  Future<void> updateNote(String docID, Map<String, dynamic> updatedData) {
    return notes.doc(docID).update(updatedData);
  }


  //Delete
  //This will delete the visitors we create given a document id.
  Future<void> deleteNote(String docID){
    return notes.doc(docID).delete();
  }
}