import 'package:crud/sql_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Belajar CRUD dengan SQFLITE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //controller
  TextEditingController judulC = TextEditingController();
  TextEditingController deskripsiC = TextEditingController();

  //ambil data dari database
  List<Map<String, dynamic>> buku = [];

  bool isLoading = true;
  void refreshBuku() async {
    final data = await SQLHelper.getItems();
    setState(() {
      buku = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshBuku();
    // ignore: avoid_print
    print('banyaknya buku ${buku.length}');
  }

  void tambahItem() async {
    await SQLHelper.tambahBuku(judulC.text, deskripsiC.text);
    refreshBuku();
  }

  void updateItem(int id) async {
    await SQLHelper.updateBuku(id, judulC.text, deskripsiC.text);
    refreshBuku();
  }

  void deleteItem(int id) async {
    await SQLHelper.deleteBuku(id);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buku Berhasil Dihapus'),
      ),
    );
    refreshBuku();
  }

  void tampilForm(int? id) async {
    if (id != null) {
      final keluarBuku = buku.firstWhere((element) => element['id'] == id);
      judulC.text = keluarBuku['judul'];
      deskripsiC.text = keluarBuku['deskripsi'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: judulC,
              decoration: const InputDecoration(hintText: 'Judul'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: deskripsiC,
              decoration: const InputDecoration(hintText: 'Deskripsi'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  tambahItem();
                }
                if (id != null) {
                  updateItem(id);
                }

                judulC.text = '';
                deskripsiC.text = '';
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Tambah Buku' : 'Update Buku'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    print(buku);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: buku.length,
          itemBuilder: (context, index) => Card(
            color: Colors.deepPurple[200],
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 15.0),
                child: Text(buku[index]['judul']),
              ),
              titleTextStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              subtitle: Text(
                buku[index]['deskripsi'],
              ),
              subtitleTextStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => tampilForm(buku[index]['id']),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => deleteItem(buku[index]['id']),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => tampilForm(null),
      ),
    );
  }
}
