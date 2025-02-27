import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hexa_delivery/bloc/board_bloc.dart';
import 'package:hexa_delivery/model/dto.dart';
import 'package:hexa_delivery/pages/login_page.dart';
import 'package:hexa_delivery/settings.dart';
import 'package:hexa_delivery/utils/user_info_cache.dart';
import 'package:hexa_delivery/widgets/order_desc_card.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({super.key});
  // final List<OrderDTO> orders;

  @override
  State<MyOrderPage> createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  final ScrollController _scrollController = ScrollController();
  BoardBloc boardPageBloc = BoardBloc();
  Timer? _debounce;

  @override
  void initState() {
    boardPageBloc.fetchNextPage(uid: int.parse(userInfoInMemory.uid!));
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= kScrollThreshold &&
          !(_debounce?.isActive ?? false)) {
        _debounce = Timer(kFetchThreshold, () {
          boardPageBloc.fetchNextPage(uid: int.parse(userInfoInMemory.uid!));
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 주문"),
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          }, // 뒤로가기
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25),
              child: Text(
                '현재 모임',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: boardPageBloc.getOrderStream,
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? (snapshot.data!.isEmpty ?? false)
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "모임 참가 내역이 없습니다.",
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: buildCancelContainer(
                                      snapshot.data![index]),
                                );
                              },
                            )
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                              child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF6332)),
                          )),
                        );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25),
              child: Text(
                '로그아웃',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  userInfoInMemory.clear();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false);
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                label: const Text(
                  "로그아웃",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }

  Widget buildCancelContainer(OrderDescDTO order) {
    return Row(
      children: [
        Expanded(child: OrderDescCard(order)),
        GestureDetector(
          onTap: () {
            boardPageBloc.deleteOrder(order.oid);
          },
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Color.fromRGBO(255, 224, 224, 1),
            ),
            margin: const EdgeInsets.only(right: 1),
            width: 80,
            height: 80,
            alignment: Alignment.center,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 255, 31, 31),
                ),
                SizedBox(height: 5),
                Text(
                  "나가기",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 31, 31),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
