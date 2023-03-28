import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();

  static const route = '/contacts';
}

class _ContactsState extends State<Contacts> {
  TextEditingController _controllerPeople = TextEditingController();
  TextEditingController _controllerName = TextEditingController();
  // List<String> people = [];
  final CollectionReference<Map<String, dynamic>> _customersDoc =
      FirebaseFirestore.instance.collection('Customers');
  bool isLoading = false;

  Widget _phoneTile(Map<String, dynamic> customer) {
    print(customer);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Text(
                        customer['Name'],
                        textScaleFactor: 1,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                      ),
                      child: Text(
                        customer['Phone'],
                        textScaleFactor: 1,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await _customersDoc.doc(customer['id']).delete();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Contacts'),
        ),
        body: FirestoreQueryBuilder<Map<String, dynamic>>(
          query: _customersDoc,
          builder: (context, snapshot, _) {
            if (snapshot.isFetching || isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            }
            return Column(
              children: [
                SizedBox(
                  height: 170,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: const Icon(Icons.people),
                      title: Column(
                        children: [
                          TextField(
                            controller: _controllerName,
                            decoration:
                                const InputDecoration(labelText: 'Full Name'),
                            keyboardType: TextInputType.name,
                            onChanged: (String value) => setState(() {}),
                          ),
                          TextField(
                            controller: _controllerPeople,
                            decoration: const InputDecoration(
                                labelText: 'Add Phone Number'),
                            keyboardType: TextInputType.number,
                            onChanged: (String value) => setState(() {}),
                          ),
                        ],
                      ),
                      trailing: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _controllerPeople.text.isEmpty ||
                                      _controllerPeople.text.isEmpty
                                  ? null
                                  : () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      var res = await _customersDoc.add({
                                        'Name': _controllerName.text.toString(),
                                        'Phone':
                                            _controllerPeople.text.toString(),
                                      });
                                      print(res.id);
                                      await _customersDoc.doc(res.id).set({
                                        'Name': _controllerName.text.toString(),
                                        'Phone':
                                            _controllerPeople.text.toString(),
                                        'id': res.id,
                                      });
                                      _controllerPeople.clear();
                                      _controllerName.clear();
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }),
                    ),
                  ),
                ),
                const Divider(
                  height: 10,
                  thickness: 2,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Contact List',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.blue,
                    ),
                  ),
                ),
                if (snapshot.docs.isEmpty)
                  const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('No contacts added'),
                    ),
                  )
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children: List<Widget>.generate(snapshot.docs.length,
                            (int index) {
                          return _phoneTile(snapshot.docs[index].data());
                        }),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
