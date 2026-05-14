import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gd6_a_2294/entity/employee.dart';
//import 'package:gd6_a_2294/firebase_options.dart';
import 'package:gd6_a_2294/input_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Firebase'),
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
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('EMPLOYEE'),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InputPage(
                    title: "INPUT EMPLOYEE",
                    name: null,
                    email: null,
                    id: null,
                  ),
                ),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<Employee>>(
        stream: getEmployee(), // Memanggil stream yang sudah kamu buat
        builder: (context, snapshot) {
          // 1. Jika ada error saat mengambil data
          if (snapshot.hasError) {
            return Center(
                child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          // 2. Jika data sedang dimuat (waiting)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(), // Menampilkan loading spinner
            );
          }

          // 3. Jika data berhasil diambil
          if (snapshot.hasData) {
            final employees = snapshot.data!;

            // Jika koleksi employee kosong
            if (employees.isEmpty) {
              return const Center(child: Text('Belum ada data employee.'));
            }

            // Jika ada data, tampilkan dalam bentuk ListView
            return ListView(
              children: employees
                  .map((employee) => buildEmployee(employee))
                  .toList(),
            );
          }

          // Fallback statis jika state tidak menentu
          return const Center(child: Text('Tidak ada data'));
        },
      ),
    );
  }

  Widget buildEmployee(Employee employee) => Slidable(
        child: ListTile(
            title: Text(employee.name),
            subtitle: Text(employee.email)),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputPage(
                      title: 'INPUT EMPLOYEE',
                      name: employee.name,
                      email: employee.email,
                      id: employee.id,
                    ),
                  ),
                );
              },
              label: 'Update',
              icon: Icons.update,
              backgroundColor: Colors.blue,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                final docEmployee =
                    db.collection('employee').doc(employee.id);

                docEmployee.delete();
              },
              label: 'Delete',
              icon: Icons.delete,
              backgroundColor: Colors.red,
            ),
          ],
        ),
      );

  Stream<List<Employee>> getEmployee() => db
      .collection('employee')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Employee.fromJson(doc.data()))
            .toList(),
      );
}