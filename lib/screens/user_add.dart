import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../providers/users.dart';

class UserAdd extends StatefulWidget {
  const UserAdd({Key? key}) : super(key: key);
  static const routeName = '/user-add';
  @override
  _UserAddState createState() => _UserAddState();
}

class _UserAddState extends State<UserAdd> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  String dropDownValue = "--Select Roles--";
  String holder = "";
  var _isInit = true;
  var _isLoading = false;

  var _payloadData = User(
      id: '',
      userId: '',
      userNames: '',
      userSatuanKerja: '',
      status: false,
      roles: '');
  var _initValues = {
    'userId': '',
    'userNames': '',
    'userSatuanKerja': '',
    'status': false,
    'roles': ''
  };

  bool? _status;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      final userId = ModalRoute.of(context)!.settings.arguments ?? '';
      if (userId != '') {
        _payloadData = Provider.of<Users>(context, listen: false)
            .findUser(userId.toString());
        _initValues = {
          'userId': _payloadData.userId,
          'userNames': _payloadData.userNames,
          'userSatuanKerja': _payloadData.userSatuanKerja,
          'status': _payloadData.status,
          'roles': _payloadData.roles,
        };
        dropDownValue = _payloadData.roles;
        _status = _payloadData.status;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_payloadData.id != '') {
      try {
        await Provider.of<Users>(context, listen: false)
            .updateUser(_payloadData.id, _payloadData);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error occured"),
            content: Text("Terjadi Kesalahan pada server"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Ok"),
              )
            ],
          ),
        );
      }
    } else {
      try {
        await Provider.of<Users>(context, listen: false).addUser(_payloadData);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error occured"),
            content: Text("Terjadi Kesalahan pada server"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Ok"),
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _payloadData.id != ''
              ? "Berhasil mengubah user"
              : "Berhasil menambahkan user",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String getDropDownItem() {
    setState(() {
      holder = dropDownValue;
    });
    return holder;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _payloadData.id == ''
              ? "Add Dashboard"
              : "Edit Dashboard ${_payloadData.userNames}",
          style: const TextStyle(
            fontSize: 14,
            overflow: TextOverflow.fade,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color.fromRGBO(84, 130, 53, 1),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        initialValue: _initValues['userId'].toString(),
                        decoration: const InputDecoration(
                          labelText: "Username LDAP",
                          icon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Kolom username LDAP harus di isi';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _payloadData = User(
                            id: _payloadData.id,
                            userId: value!,
                            userNames: _payloadData.userNames,
                            userSatuanKerja: _payloadData.userSatuanKerja,
                            status: _payloadData.status,
                            roles: _payloadData.roles == ''
                                ? dropDownValue
                                : _payloadData.roles,
                          );
                        },
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        initialValue: _initValues['userNames'].toString(),
                        decoration: const InputDecoration(
                          labelText: "Nama User",
                          icon: Icon(Icons.card_membership),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Kolom nama user harus di isi';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _payloadData = User(
                            id: _payloadData.id,
                            userId: _payloadData.userId,
                            userNames: value!,
                            userSatuanKerja: _payloadData.userSatuanKerja,
                            status: _payloadData.status,
                            roles: _payloadData.roles == ''
                                ? dropDownValue
                                : _payloadData.roles,
                          );
                        },
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        initialValue: _initValues['userSatuanKerja'].toString(),
                        decoration: const InputDecoration(
                          labelText: "Satuan Kerja",
                          icon: Icon(Icons.work),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Kolom satuan kerja harus di isi';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _payloadData = User(
                            id: _payloadData.id,
                            userId: _payloadData.userId,
                            userNames: _payloadData.userNames,
                            userSatuanKerja: value!,
                            status: _payloadData.status,
                            roles: _payloadData.roles == ''
                                ? dropDownValue
                                : _payloadData.roles,
                          );
                        },
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 4),
                                child: Text("Status"),
                              ),
                              Switch(
                                value: _status ?? false,
                                onChanged: (value) {
                                  setState(() {
                                    _status = value;
                                    print(value);
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 4),
                                child: Text("Roles"),
                              ),
                              Container(
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    alignedDropdown: true,
                                    child: DropdownButton<String>(
                                      value: dropDownValue,
                                      icon: const Icon(
                                        Icons.arrow_drop_down_circle,
                                      ),
                                      elevation: 16,
                                      onChanged: (String? value) {
                                        setState(() {
                                          dropDownValue = value!;
                                        });
                                      },
                                      items: <String>[
                                        '--Select Roles--',
                                        'admin',
                                        'User'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          enabled: value == '--Select Roles--'
                                              ? false
                                              : true,
                                          child: Text(
                                            value,
                                            textAlign: TextAlign.start,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(84, 130, 53, 1),
        child: const Icon(Icons.save),
        onPressed: () {
          _payloadData = User(
            id: _payloadData.id,
            userId: _payloadData.userId,
            userNames: _payloadData.userNames,
            userSatuanKerja: _payloadData.userSatuanKerja,
            status: _status ?? false,
            roles: dropDownValue,
          );
          _submit();
        },
      ),
    );
  }
}
