import 'package:flutter/material.dart'; // Import library flutter untuk UI
import 'dart:async'; // Import library dart:async untuk async programming
import 'dart:convert'; // Import library dart:convert untuk encoding dan decoding JSON
import 'package:http/http.dart'
    as http; // Import library http untuk membuat HTTP requests
import 'package:provider/provider.dart'; // Import Provider untuk state management

void main() => runApp(MyApp()); // Main function yang memulai aplikasi Flutter

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASEAN Universities', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Warna tema utama
      ),
      home: ChangeNotifierProvider(
        create: (context) =>
            UniversityProvider(), // Membuat provider untuk state management
        child:
            UniversityList(), // Menampilkan halaman UniversityList sebagai home
      ),
    );
  }
}

class UniversityProvider with ChangeNotifier {
  String selectedCountry = 'Indonesia'; // Negara default yang dipilih

  void changeCountry(String? newCountry) {
    selectedCountry = newCountry!; // Mengubah negara yang dipilih
    notifyListeners(); // Memberi tahu listener tentang perubahan pada state
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var universityProvider = Provider.of<UniversityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('ASEAN Universities'), // Judul AppBar
      ),
      body: Column(
        // Memuat combobox dan listview di dalam Column
        children: [
          // DropdownButton untuk memilih negara ASEAN
          DropdownButton<String>(
            value:
                universityProvider.selectedCountry, // Nilai negara yang dipilih
            items: <String>[
              'Indonesia',
              'Singapore',
              'Malaysia',
              'Thailand',
              'Vietnam'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value), // Menampilkan nama negara pada dropdown
              );
            }).toList(),
            onChanged: (String? newValue) {
              universityProvider.changeCountry(
                  newValue); // Mengubah negara ASEAN yang dipilih
            },
          ),
          Expanded(
            // Menggunakan Expanded untuk memungkinkan listview menempati sisa ruang yang tersedia
            child:
                UniversityListView(), // Menempatkan UniversityListView di bawah combobox
          ),
        ],
      ),
    );
  }
}

class UniversityListView extends StatefulWidget {
  @override
  _UniversityListViewState createState() => _UniversityListViewState();
}

class _UniversityListViewState extends State<UniversityListView> {
  List<dynamic> universities = []; // List untuk menyimpan data universitas

  Future<void> fetchData(String country) async {
    var result = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country')); // Melakukan HTTP GET request untuk mendapatkan data universitas berdasarkan negara
    setState(() {
      universities = json.decode(
          result.body); // Mendecode respons JSON ke dalam list universitas
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(
        'Indonesia'); // Mengambil data universitas Indonesia saat initState dipanggil
  }

  @override
  Widget build(BuildContext context) {
    var universityProvider = Provider.of<UniversityProvider>(context);

    if (universityProvider.selectedCountry != null &&
        universityProvider.selectedCountry != '') {
      fetchData(universityProvider
          .selectedCountry); // Mengambil data universitas berdasarkan negara yang dipilih
    }

    return ListView.builder(
      itemCount: universities.length, // Jumlah item dalam list universitas
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title:
              Text(universities[index]['name']), // Menampilkan nama universitas
          subtitle: Text(
              'Website: ${universities[index]['web_pages'][0]}'), // Menampilkan website universitas
        );
      },
    );
  }
}
