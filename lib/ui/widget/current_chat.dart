
// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/core/message/base_message.dart';

class CurrentUserChat extends StatelessWidget {
  BaseMessage baseMessage;
  CurrentUserChat({super.key, required this.baseMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(4),
                  topLeft: Radius.circular(18),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(18),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(
                      0xffFF006B,
                    ),
                    Color(0xffFF4593)
                  ],
                )),
            child: Text(
              baseMessage.message,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ],
      ),
    );
  }
}
