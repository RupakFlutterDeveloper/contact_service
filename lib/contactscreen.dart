import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  String _searchQuery = '';
  bool _isPermissionGranted = true; // Mocked permission status

  @override
  void initState() {
    super.initState();
    // Simulating permission request
    requestContactPermission();
  }

  Future<void> requestContactPermission() async {
    // Replace this with actual permission request if needed
    if (_isPermissionGranted) {
      print("Permission granted");
      try {
        List<Contact> contacts =
            await FlutterContacts.getContacts(withProperties: true);

        _contacts = contacts.where((contact) {
          return contact.phones.any((phone) => phone.number.length >= 10);
        }).toList();

        _filteredContacts = List.from(_contacts);
        setState(() {});
      } catch (e) {
        print("Error fetching contacts: $e");
      }
    } else {
      print("Permission not granted");
      // Handle the case when permission is not granted
    }
  }

  void _filterContacts(String query) {
    if (query.isNotEmpty) {
      _filteredContacts = _contacts.where((contact) {
        return contact.displayName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      _filteredContacts = List.from(_contacts);
    }

    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterContacts,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                var contact = _filteredContacts[index];
                List<String> validPhones = contact.phones
                    .where((phone) => phone.number.length >= 10)
                    .map((phone) => phone.number)
                    .toList();

                return ListTile(
                  leading: contact.photo != null
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(contact.photo!),
                        )
                      : CircleAvatar(child: Icon(Icons.person)),
                  title: Text(contact.displayName),
                  subtitle: validPhones.isNotEmpty
                      ? Text(validPhones.join(", "))
                      : Text('No valid phone number'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
