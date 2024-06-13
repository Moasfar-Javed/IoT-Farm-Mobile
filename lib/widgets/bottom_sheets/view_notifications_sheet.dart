import 'package:farm/main.dart';
import 'package:farm/models/api/notification/list/notification_list_response.dart';
import 'package:farm/models/api/notification/notification.dart';
import 'package:farm/services/user_service.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewNotificationsSheet extends StatefulWidget {
  const ViewNotificationsSheet({super.key});

  @override
  State<ViewNotificationsSheet> createState() => _ViewNotificationsSheetState();
}

class _ViewNotificationsSheetState extends State<ViewNotificationsSheet> {
  bool _isLoading = true;
  List<NotificationDetail> notifications = [];
  UserService userService = UserService();
  @override
  void initState() {
    _getNotificationList();
    super.initState();
  }

  _getNotificationList() async {
    userService.getNotificationList().then((value) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (value.error == null) {
        NotificationListResponse response = value.snapshot;
        if (response.success ?? false) {
          notifications = response.data?.notifications ?? [];
        } else {
          ToastUtil.showToast(response.message ?? "");
          print(response.message);
        }
      } else {
        ToastUtil.showToast(value.error ?? "");
        print(value.error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).viewInsets.bottom == 0
                ? MediaQuery.of(context).size.height * 0.9
                : MediaQuery.of(context).size.height * 0.9,
          ),
          child: Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                color: ColorStyle.backgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Notifications",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ColorStyle.primaryColor),
                          ),
                        ),
                        Ink(
                          decoration: const ShapeDecoration(
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            color: ColorStyle.secondaryPrimaryColor,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Scrollbar(
                              thumbVisibility: true,
                              child: ListView.builder(
                                itemCount: notifications.length,
                                itemBuilder: (context, index) =>
                                    _buildNotificationWidget(index),
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildNotificationWidget(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        color: ColorStyle.whiteColor,
        border: Border(
          bottom: BorderSide(
            color: ColorStyle.lightPrimaryColor,
          ),
        ),
        //borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                notifications[index].payload?.action == "open_logs"
                    ? Icons.update
                    : Icons.water,
                color: ColorStyle.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  notifications[index].payload?.title ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ColorStyle.textColor),
                ),
              ),
              Text(
                DateFormat('dd MMMM, yy - hh:mm a')
                    .format(toLocalTime(notifications[index].sentOn!)),
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.secondaryPrimaryColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notifications[index].payload?.message ?? "",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: ColorStyle.textColor),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
