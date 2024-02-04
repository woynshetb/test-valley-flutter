import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:timeago/timeago.dart' as timeago;

class GroupChatItem extends StatelessWidget {
  final BaseMessage baseMessage;
  const GroupChatItem({super.key, required this.baseMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                child: CircleAvatar(
                  radius: 16,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(18),
                      ),
                      color: Color(
                        0xff1A1A1A,
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            baseMessage.sender!.nickname,
                            style: TextStyle(
                                color: Color(0xffADADAD), fontSize: 14),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(
                                0xff46F9F5,
                              ),
                              gradient: baseMessage.sender!.isActive!
                                  ? null
                                  : LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [
                                        Color(
                                          0xff101010,
                                        ),
                                        Color(0xff2F2F2F)
                                      ],
                                    ),
                            ),
                          )
                        ],
                      ),
                      Text(
                        baseMessage.message,
                        style:
                            TextStyle(color: Color(0xffFFFFFF), fontSize: 16),
                      ),
                    ],
                  )),
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              timeAgo(baseMessage.createdAt),
              style: TextStyle(fontSize: 12, color: Color(0xff9C9CA3)),
            ),
          )
        ],
      ),
    );
  }

  String timeAgo(createdAt) {
    timeago.setLocaleMessages('ko', timeago.KoMessages());
    DateTime sentAt = DateTime.fromMillisecondsSinceEpoch(createdAt);
    DateTime now = DateTime.now();
    Duration difference = now.difference(sentAt);
    String timeAgo = timeago.format(now.subtract(difference), locale: 'ko');
    return timeAgo;
  }
}
