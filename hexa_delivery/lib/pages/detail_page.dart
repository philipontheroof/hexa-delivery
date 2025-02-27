import 'package:flutter/material.dart';
import 'package:hexa_delivery/model/dto.dart';
import 'package:hexa_delivery/pages/chat_page.dart';
import 'package:hexa_delivery/resources/login_resource.dart';
import 'package:hexa_delivery/resources/order_resource.dart';
import 'package:hexa_delivery/widgets/buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final int oid;

  const DetailPage(this.oid, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  OrderDTO? order;
  String? userName;

  @override
  void initState() {
    OrderResource.getOrderDetail(widget.oid).then((orderFetched) {
      setState(() {
        order = orderFetched;
      });
    });
    LoginResource.getUserName().then((fetchedUserName) {
      setState(() {
        userName = fetchedUserName;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          order?.name ?? "로딩 중",
        ),
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: order == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTitleString('가게 이름'),
                  buildValueString(order!.name),
                  buildTitleString('주문 시간'),
                  buildValueString(
                      "${order!.expTime.hour}시 ${order!.expTime.minute}분 주문"),
                  buildTitleString('픽업 장소'),
                  buildValueString(order!.meetingLocation),
                  buildTitleString('현재 인원'),
                  // buildValueString('${order!.numOfMembers}명'),
                  buildLinkedButton(() async {
                    await launchUrl(Uri.parse(order!.groupLink));
                  }),
                ],
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: order != null && userName != null
          ? VerificationButton(
              text: "채팅방으로 이동",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(
                            order: order!,
                            userName: userName!,
                          )),
                );
              },
            )
          : null,
    );
  }
}

Widget buildLinkedButton(Function onPressed) {
  return Container(
    height: 55,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF39C0C0),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      onPressed: () => onPressed,
      child: Center(
          child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Center(child: Image.asset("assets/images/baemin.png")),
          ),
          const Flexible(
            flex: 4,
            child: Center(
              child: Text(
                "배민에서 메뉴 담기",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      )),
    ),
  );
}

Widget buildTitleString(String content) {
  return Container(
    margin: const EdgeInsets.only(left: 20, top: 15),
    child: Text(
      content,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget buildValueString(String content) {
  return Container(
    margin: const EdgeInsets.only(left: 20, top: 10),
    child: Text(content,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w800,
        )),
  );
}
