import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: unused_import
import 'package:firebase_database/firebase_database.dart';

void main() async {
  // 1. Flutter motorunu başlat
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Firebase'i başlat
  await Firebase.initializeApp();

  // 3. Uygulamayı çalıştır
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki 'Debug' bandını kaldırır
      title: 'BIM 493 Messaging',
      theme: ThemeData(
        // Ödevdeki gibi mor renk teması
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple), 
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // 1. Metin kutusunu kontrol etmek için bir kumanda
  final TextEditingController _messageController = TextEditingController();

  // 2. Firebase Veritabanı bağlantısı ('messages' adında bir klasör oluşturur)
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('messages');

  // Mesaj gönderme fonksiyonu
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      // Firebase'e yeni bir mesaj ekle
      _dbRef.push().set({
        'text': _messageController.text,
        'timestamp': ServerValue.timestamp, // Sıralama için zaman damgası
      });
      // Kutuyu temizle
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comment List"), // Ödevdeki başlık [cite: 8]
        backgroundColor: Colors.purple[100],
      ),
      body: Column(
        children: [
          // --- BÖLÜM 1: MESAJ YAZMA ALANI (ÜST KISIM) ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Yazı Kutusu
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Enter a comment', // Ödevdeki etiket [cite: 1]
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Gönder Butonu
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text("Send"), // Ödevdeki buton [cite: 9]
                ),
              ],
            ),
          ),

          // --- BÖLÜM 2: MESAJ LİSTESİ (ALT KISIM) ---
          Expanded(
            child: StreamBuilder(
              // Firebase'deki verileri dinle
              stream: _dbRef.onValue,
              builder: (context, snapshot) {
                // Veri var mı kontrol et
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  // Gelen veriyi listeye çevir (Map -> List)
                  final Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
                  final List<Map<dynamic, dynamic>> messages = [];
                  
                  data.forEach((key, value) {
                    messages.add(value);
                  });

                  // Mesajları zamana göre sırala (eskiden yeniye)
                  messages.sort((a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));

                  // Listeyi ekrana çiz
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.comment), // Mesaj ikonu
                        title: Text(messages[index]['text']),
                      );
                    },
                  );
                } else {
                  // Veri yoksa veya yükleniyorsa boş göster
                  return const Center(child: Text("Henüz mesaj yok"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}