import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home/src/widgets/carousel_slider.dart';
import 'package:home/src/models/home_menu_args.dart';
import 'package:utils/src/models/models.dart';
import 'package:utils/src/blocs/configuration/configuration_bloc.dart';
import 'package:utils/src/repository/configuration_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(200),
        child: CarouselSliderCustom(),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: BlocBuilder<ConfigurationBloc, ConfigurationState>(
          builder: (context, state) {
            List<dynamic> homeMenu = state.config['homeMenu'] != null
                ? List.from(state.config['homeMenu'])
                : [];

            switch (state.status) {
              case configStatus.failure:
                return const Center(child: Text('Failed to get menu config!'));
              case configStatus.success:
                return GridView.count(
                  padding: const EdgeInsets.all(10),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    for (var i = 0; i < homeMenu.length; i++)
                      if (homeMenu[i]['enable'])
                        IconButton(
                          icon: Column(
                            children: [
                              SizedBox(
                                child: Image.asset("assets/images/school.png"),
                                width: 60,
                                height: 60,
                              ),
                              const Padding(padding: EdgeInsets.only(top: 15)),
                              Text(homeMenu[i]['name'],
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          onPressed: () => Navigator.of(context).pushNamed(
                            homeMenu[i]['route'],
                            arguments: HomeMenuArgs(
                              homeMenu[i]['name'] + "'s List",
                              homeMenu[i]['tagId'],
                            ),
                          ),
                        )
                  ],
                );
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
