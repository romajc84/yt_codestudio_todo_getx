import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class NoteController extends GetxController {
  var notes = [].obs;

  void add(Note n) {
    notes.add(n);
  }

  @override
  void onInit() {
    List? storedNotes = GetStorage().read<List>('notes');
    if (storedNotes != null) {
      notes = storedNotes.map((e) => Note.fromJson(e)).toList().obs;
    }
    ever(notes, (_) {
      GetStorage().write('notes', notes.toList());
    });
    super.onInit();
  }
}

class Note {
  String title;
  Note({required this.title});

  factory Note.fromJson(Map<String, dynamic> json) =>
      Note(title: json['title']);

  Map<String, dynamic> toJson() => {'title': title};
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Todo App'),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: NoteList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(MyNote());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NoteController nc = Get.put(NoteController());
    return Obx(
      () => ListView.builder(
        itemCount: nc.notes.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text(
              nc.notes[index].title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            leading: Text(
              (index + 1).toString() + '.',
              style: TextStyle(fontSize: 15),
            ),
            trailing: Wrap(
              children: [
                IconButton(
                  onPressed: () => Get.to(MyNote(index: index)),
                  icon: Icon(Icons.create),
                ),
                IconButton(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Delete Note',
                      middleText: nc.notes[index].title,
                      onCancel: () => Get.back(),
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        nc.notes.removeAt(index);
                        Get.back();
                      },
                    );
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyNote extends StatelessWidget {
  final int? index;

  MyNote({this.index});

  @override
  Widget build(BuildContext context) {
    final NoteController nc = Get.find();
    String text = (index == null ? ' ' : nc.notes.elementAt(index!).title);
    TextEditingController tEC = TextEditingController(text: text);

    return Scaffold(
      appBar: AppBar(
        title: index == null ? Text('Create a New Note ') : Text('Update Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Container(
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: tEC,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Create a new note!',
                    labelText: 'My Note',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black87,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 5,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (index == null) {
                        nc.notes.add(Note(title: tEC.text));
                      } else {
                        var updatenote = nc.notes.elementAt(index!);
                        updatenote.title = tEC.text;
                        nc.notes[index!] = updatenote;
                      }
                      Get.back();
                    },
                    child: index == null ? Text('Add') : Text('Update'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
