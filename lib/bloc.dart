import 'package:flutter/material.dart'; // Import library untuk pembuatan aplikasi Flutter
import 'dart:async'; // Import library untuk asynchronous programming
import 'dart:convert'; // Import library untuk JSON serialization/deserialization
import 'package:http/http.dart'
    as http; // Import library untuk melakukan HTTP requests
import 'package:flutter_bloc/flutter_bloc.dart'; // Import library untuk Flutter Bloc

void main() =>
    runApp(MyApp()); // Method utama yang dijalankan saat aplikasi dimulai

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASEAN Universities', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema aplikasi
      ),
      home: BlocProvider(
        create: (context) =>
            UniversityBloc(), // Membuat instance dari UniversityBloc dan melewatkan ke dalam BlocProvider
        child:
            UniversityList(), // Menempatkan UniversityList di dalam BlocProvider
      ),
    );
  }
}

class UniversityEvent {
  final String country; // Event untuk mengubah negara yang dipilih

  UniversityEvent(this.country); // Konstruktor event dengan parameter negara
}

class UniversityState {
  final String selectedCountry; // State yang menyimpan negara yang dipilih

  UniversityState(
      this.selectedCountry); // Konstruktor state dengan parameter negara
}

class UniversityBloc extends Bloc<UniversityEvent, UniversityState> {
  UniversityBloc()
      : super(UniversityState(
            'Indonesia')); // Constructor untuk UniversityBloc, state awalnya adalah Indonesia

  @override
  Stream<UniversityState> mapEventToState(UniversityEvent event) async* {
    yield UniversityState(
        event.country); // Memetakan event menjadi state yang baru
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ASEAN Universities'), // Judul app bar
      ),
      body: Column(
        children: [
          BlocBuilder<UniversityBloc, UniversityState>(
            builder: (context, state) {
              return DropdownButton<String>(
                value: state
                    .selectedCountry, // Nilai dropdown berdasarkan negara yang dipilih
                items: <String>[
                  'Indonesia',
                  'Singapore',
                  'Malaysia',
                  'Thailand',
                  'Vietnam'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // Text untuk setiap item dropdown
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<UniversityBloc>().add(UniversityEvent(
                        newValue)); // Memanggil event UniversityEvent(newValue) saat nilai dropdown berubah
                  }
                },
              );
            },
          ),
          Expanded(
            child:
                UniversityListView(), // Menampilkan UniversityListView di dalam kolom yang dapat memperluas ukuran
          ),
        ],
      ),
    );
  }
}

class UniversityListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UniversityBloc, UniversityState>(
      builder: (context, state) {
        return FutureBuilder<List<dynamic>>(
          future: fetchData(state
              .selectedCountry), // Mengambil data universitas berdasarkan negara yang dipilih
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child:
                    CircularProgressIndicator(), // Menampilkan indikator loading jika data sedang dimuat
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                    'Error fetching data'), // Menampilkan pesan error jika terjadi kesalahan saat mengambil data
              );
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length, // Jumlah item dalam daftar
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title:
                        Text(snapshot.data![index]['name']), // Nama universitas
                    subtitle: Text(
                        'Website: ${snapshot.data![index]['web_pages'][0]}'), // Website universitas
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                    'No data available'), // Menampilkan pesan jika tidak ada data yang tersedia
              );
            }
          },
        );
      },
    );
  }

  Future<List<dynamic>> fetchData(String country) async {
    var result = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country')); // Mengambil data universitas dari API
    return json.decode(result.body); // Mengembalikan hasil parsing JSON
  }
}
