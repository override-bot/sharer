// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/router.dart';
import '../../utils/text_size.dart';
import 'download_progress_screen.dart';
import 'upload_progress_screen.dart';

class SharingProgress extends StatefulWidget {
  const SharingProgress({super.key});

  @override
  State<SharingProgress> createState() => _SharingProgressState();
}

class _SharingProgressState extends State<SharingProgress>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ceoWhite,
          leading: IconButton(
              onPressed: () {
                RouteController().pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: ceoBlack,
              )),
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            "Transfers",
            style: TextStyle(
                color: ceoPurple,
                fontSize: TextSize().h1(context),
                fontWeight: FontWeight.w500),
          ),
        ),
        body: Scaffold(
            body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          //color: ceog,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: ceoPurple,
                unselectedLabelStyle: TextStyle(
                    color: ceoBlack, fontSize: TextSize().h3(context)),
                unselectedLabelColor: ceoBlack,
                labelColor: ceoPurple,
                labelStyle: TextStyle(
                    color: ceoPurple, fontSize: TextSize().h3(context)),
                tabs: [
                  Tab(
                    text: "Downloads",
                  ),
                  Tab(
                    text: "Uploads",
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [DownloadsView(), UploadsView()],
                ),
              ),
            ],
          ),
        )));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  setNewIndex(val) {
    setState(() {
      currentIndex = val;
    });
  }
}
