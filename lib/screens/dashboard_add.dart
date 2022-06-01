import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard.dart';
import '../providers/dashboards.dart';

class DashboardAdd extends StatefulWidget {
  const DashboardAdd({Key? key}) : super(key: key);
  static const routeName = '/dashboard-add';

  @override
  State<DashboardAdd> createState() => _DashboardAddState();
}

class _DashboardAddState extends State<DashboardAdd> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String dropDownValue = "--Select Type--";
  String holder = "";
  var _isInit = true;
  var _isLoading = false;

  var _payloadData =
      Dashboard(id: '', Nama_dashboard: '', Link_dashboard: '', Type: '');
  var _initValues = {'nama_dashboard': '', 'link_dashboard': '', 'type': ''};

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final dashboardId = ModalRoute.of(context)!.settings.arguments ?? '';
      if (dashboardId != '') {
        _payloadData = Provider.of<Dashboards>(context, listen: false)
            .findDashboard(dashboardId.toString());
        _initValues = {
          'nama_dashboard': _payloadData.Nama_dashboard,
          'link_dashboard': _payloadData.Link_dashboard,
          'type': _payloadData.Type
        };
        dropDownValue = _initValues['type'] ?? '';
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
        await Provider.of<Dashboards>(context, listen: false)
            .updateDashboard(_payloadData.id, _payloadData);
        print(_payloadData.Nama_dashboard);
      } catch (error) {
        print(error);
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
        await Provider.of<Dashboards>(context, listen: false)
            .addDashboard(_payloadData);
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
              ? "Berhasil mengubah dashboard"
              : "Berhasil menambahkan dashboard",
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
              : "Edit Dashboard ${_payloadData.Nama_dashboard}",
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
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: Color.fromRGBO(84, 130, 53, 1),
      ),
      body: _isLoading
          ? Center(
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
                        initialValue: _initValues['nama_dashboard'],
                        decoration: const InputDecoration(
                          labelText: "Nama Dashboard",
                          icon: Icon(Icons.dashboard),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Kolom nama dashboard harus di isi!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _payloadData = Dashboard(
                            id: _payloadData.id,
                            Nama_dashboard: value!,
                            Link_dashboard: _payloadData.Link_dashboard,
                            Type: _payloadData.Type == ''
                                ? dropDownValue
                                : _payloadData.Type,
                          );
                        },
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        initialValue: _initValues['link_dashboard'],
                        decoration: const InputDecoration(
                          labelText: "Link Dashboard",
                          icon: Icon(Icons.link),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Kolom link dashboard harus di isi!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _payloadData = Dashboard(
                            id: _payloadData.id,
                            Nama_dashboard: _payloadData.Nama_dashboard,
                            Link_dashboard: value!,
                            Type: _payloadData.Type == ''
                                ? dropDownValue
                                : _payloadData.Type,
                          );
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.color_lens,
                            color: Colors.grey,
                          ),
                          Container(
                            width: deviceSize.width * 0.85,
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
                                    '--Select Type--',
                                    'dark',
                                    'light'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      enabled: value == '--Select Type--'
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(84, 130, 53, 1),
        onPressed: () {
          _payloadData = Dashboard(
            id: _payloadData.id,
            Nama_dashboard: _payloadData.Nama_dashboard,
            Link_dashboard: _payloadData.Link_dashboard,
            Type: dropDownValue,
          );
          _submit();
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
