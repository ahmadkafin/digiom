import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../providers/dashboards.dart';
import '../widgets/drawers.dart';

import 'dashboard_add.dart';

class DashboardManagement extends StatefulWidget {
  const DashboardManagement({Key? key}) : super(key: key);
  static const routeName = '/dashboard-page';

  @override
  State<DashboardManagement> createState() => _DashboardManagementState();
}

class _DashboardManagementState extends State<DashboardManagement> {
  bool _isLoading = false;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<Dashboards>(context, listen: false).fetchAllDashboard();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var dashboard = Provider.of<Dashboards>(context).dataDashboard;
    RefreshController _refreshController =
        RefreshController(initialRefresh: true);

    void _onRefresh() async {
      await Future.delayed(Duration(milliseconds: 1000));
      Provider.of<Dashboards>(context, listen: false).fetchAllDashboard();
      _refreshController.refreshCompleted();
      setState(() {
        _isLoading = false;
      });
    }

    void _onLoading() async {
      await Future.delayed(Duration(milliseconds: 1000));
      var newData =
          Provider.of<Dashboards>(context, listen: false).dataDashboard;
      setState(() {
        dashboard = newData;
        _isLoading = false;
      });
      _refreshController.loadComplete();
    }

    return Scaffold(
      key: _drawerKey,
      appBar: AppBar(
        title: const Text(
          "Dashboard Management",
          style: TextStyle(
            fontSize: 20,
            overflow: TextOverflow.visible,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(84, 130, 53, 1),
        leading: IconButton(
          onPressed: () {
            return _drawerKey.currentState!.openDrawer();
          },
          icon: Image.asset('img/digiom_white.png'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(DashboardAdd.routeName).then(
                (value) async {
                  if (value != null) {
                    await Future.delayed(Duration(milliseconds: 1000));
                    Provider.of<Dashboards>(context, listen: false)
                        .fetchAllDashboard();
                    _refreshController.refreshCompleted();
                  }
                },
              );
            },
            icon: const Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
        ],
      ),
      drawer: Drawers(
        isMode: false,
        isVisible: false,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 2, right: 2),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: _isLoading
              ? const Center(
                  child: Text(""),
                )
              : ListView.builder(
                  itemBuilder: (ctx, index) {
                    return Dismissible(
                      key: Key(dashboard[index].id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) {
                        return showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Confirmation'),
                            content: Text(
                              'Apakah yakin akan mengapus dashboard ${dashboard[index].Nama_dashboard}?',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('No'),
                                onPressed: () {
                                  Navigator.of(ctx).pop(false);
                                },
                              ),
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () {
                                  try {
                                    Provider.of<Dashboards>(context,
                                            listen: false)
                                        .deleteDashboard(dashboard[index].id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Berhasil menghapus Dashboard ${dashboard[index].Nama_dashboard}",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  } catch (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Tidak bisa menghapus Dashboard ${dashboard[index].Nama_dashboard}",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  }
                                  Navigator.of(ctx).pop(true);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      background: Container(
                        color: Theme.of(context).errorColor,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 40,
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                              "${_abbreviation(dashboard[index].Nama_dashboard)}"),
                          backgroundColor: dashboard[index].Type == "dark"
                              ? Colors.black87
                              : const Color.fromRGBO(84, 130, 53, 1),
                        ),
                        title: Text(
                          dashboard[index].Nama_dashboard,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          "Type : ${dashboard[index].Type}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                DashboardAdd.routeName,
                                arguments: dashboard[index].id);
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: dashboard.length,
                ),
        ),
      ),
    );
  }

  _abbreviation(String name) {
    return name
        .replaceAll(" ", "")
        .split(RegExp(r"[/\s/g]"))
        .map((e) => e.length > 1 ? e[0] : e)
        .map((letter) => letter.toUpperCase())
        .where((element) => element.contains(RegExp(r"[A-Z]")))
        .reduce((value, element) => value + element);
  }
}
