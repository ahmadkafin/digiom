import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../screens/user_add.dart';
import '../providers/users.dart';
import '../widgets/drawers.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key}) : super(key: key);
  static const routeName = '/user-management';

  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  bool _isLoading = false;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<Users>(context, listen: false).fetchAllUser();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<Users>(context).dataUsers;
    RefreshController _refreshController =
        RefreshController(initialRefresh: true);

    void _onRefresh() async {
      await Future.delayed(Duration(milliseconds: 1000));
      Provider.of<Users>(context, listen: false).fetchAllUser();
      _refreshController.refreshCompleted();
      setState(() {
        _isLoading = false;
      });
    }

    void _onLoading() async {
      await Future.delayed(Duration(milliseconds: 1000));
      var newData = Provider.of<Users>(context, listen: false).dataUsers;
      setState(() {
        user = newData;
        _isLoading = false;
      });
      _refreshController.loadComplete();
    }

    return Scaffold(
      key: _drawerKey,
      appBar: AppBar(
        title: const Text(
          "User Management",
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
              Navigator.of(context).pushNamed(UserAdd.routeName).then(
                (value) async {
                  if (value != null) {
                    await Future.delayed(Duration(milliseconds: 1000));
                    Provider.of<Users>(context, listen: false).fetchAllUser();
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
        padding: EdgeInsets.only(left: 2, right: 2),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          controller: _refreshController,
          onLoading: _onLoading,
          onRefresh: _onRefresh,
          child: _isLoading
              ? const Center(
                  child: Text(""),
                )
              : ListView.builder(
                  itemBuilder: (ctx, index) {
                    return Dismissible(
                      key: Key(user[index].id),
                      direction: DismissDirection.endToStart,
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
                      confirmDismiss: (direction) {
                        return showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Konfirmasi hapus'),
                            content: Text(
                              'Menghapus user ${user[index].userNames}, akan menyebabkan user ini tidak akan bisa mengakses aplikasi digiom lagi.',
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
                                    Provider.of<Users>(context, listen: false)
                                        .deleteUser(user[index].id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Berhasil menghapus Dashboard ${user[index].userNames}",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  } catch (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Tidak bisa menghapus Dashboard ${user[index].userNames}",
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
                      child: ListTile(
                        leading: CircleAvatar(
                          child:
                              Text("${_abbreviation(user[index].userNames)}"),
                          backgroundColor: Colors.black87,
                        ),
                        title: Text(
                          user[index].userNames,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          "${user[index].userId} : ${user[index].id}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              UserAdd.routeName,
                              arguments: user[index].id,
                            );
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: user.length,
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
