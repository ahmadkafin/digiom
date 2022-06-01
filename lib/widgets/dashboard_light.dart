import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';

import '../providers/dashboards.dart';

import '../screens/dashboard_view.dart';

class DashboardLight extends StatefulWidget {
  const DashboardLight({Key? key}) : super(key: key);

  @override
  _DashboardLightState createState() => _DashboardLightState();
}

class _DashboardLightState extends State<DashboardLight> {
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<Dashboards>(context, listen: false).fetchDashboard("light");
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
      Provider.of<Dashboards>(context, listen: false).fetchDashboard("light");
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

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: _isLoading
          ? Center(
              child: Text(""),
            )
          : OrientationBuilder(
              builder: (context, orientation) => GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
                  childAspectRatio: 4 / 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: dashboard.length,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(DashboardView.routeName,
                                  arguments: dashboard[index].id)
                              .then(
                            (value) async {
                              if (value != null) {
                                await Future.delayed(
                                  Duration(milliseconds: 1000),
                                );
                                Provider.of<Dashboards>(context, listen: false)
                                    .fetchDashboard("light");
                                _refreshController.refreshCompleted();
                              }
                            },
                          );
                        },
                        child: GridTile(
                          child: Image.asset(
                            'img/icons/${index + 1}.png',
                            color: Color.fromRGBO(84, 130, 53, 1),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
