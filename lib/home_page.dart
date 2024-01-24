import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_master/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firestore
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController textController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  //open dialog box to add note
  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              // text user input
              content: TextField(
                controller: textController,
              ),
              actions: [
                // button to save
                ElevatedButton(
                  onPressed: () {
                    // add new note
                    if (docID == null) {
                      fireStoreService.addNote(textController.text);
                    }
                    // update an existing note
                    else {
                      fireStoreService.updateNote(docID, textController.text);
                    }

                    // clear the text controller
                    textController.clear();
                    // close the box
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(user.email!, style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.grey,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: Icon(Icons.arrow_back)),
            ),
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
        backgroundColor: Colors.grey,
        hoverColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.getNotesStream(),
        builder: (context, snapshot) {
          //if have data get all the docs

          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // display as a list

            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //get each individual doc
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                //get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // display as a list tile

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(noteText, style: TextStyle(fontSize: 25)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // update button
                        IconButton(
                          onPressed: () => openNoteBox(docID: docID),
                          icon: const Icon(Icons.settings),
                        ),

                        // delete button
                        IconButton(
                          onPressed: () => fireStoreService.deleteNote(docID),
                          icon: const Icon(Icons.delete),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }

          // if there is no data return nothing
          else {
            return const Text("No notes ..");
          }
        },
      ),
    );
  }
}
