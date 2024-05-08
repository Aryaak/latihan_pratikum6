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
            UniversityCubit(), // Membuat instance dari UniversityCubit dan melewatkan ke dalam BlocProvider
        child:
            UniversityList(), // Menempatkan UniversityList di dalam BlocProvider
      ),
    );
  }
}

class UniversityCubit extends Cubit<String> {
  UniversityCubit()
      : super(
            'Indonesia'); // Constructor untuk UniversityCubit, state awalnya adalah 'Indonesia'

  void changeCountry(String newCountry) {
    emit(newCountry); // Emit event untuk mengubah negara yang dipilih
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
          BlocBuilder<UniversityCubit, String>(
            builder: (context, selectedCountry) {
              return DropdownButton<String>(
                value:
                    selectedCountry, // Nilai dropdown berdasarkan negara yang dipilih
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
                    context.read<UniversityCubit>().changeCountry(
                        newValue); // Memanggil method changeCountry dari UniversityCubit saat nilai dropdown berubah
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
    return BlocBuilder<UniversityCubit, String>(
      builder: (context, selectedCountry) {
        return FutureBuilder<List<dynamic>>(
          future: fetchData(
              selectedCountry), // Mengambil data universitas berdasarkan negara yang dipilih
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