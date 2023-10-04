import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/layout/social_app/cubit/cubit.dart';
import 'package:social_app/layout/social_app/cubit/states.dart';
import 'package:social_app/models/social_app/message_model.dart';
import 'package:social_app/models/social_app/social_user_model.dart';
import 'package:social_app/shared/styles/colors.dart';
import 'package:social_app/shared/styles/icon_broken.dart';

class ChatDetailsScreen extends StatelessWidget {
  SocialUserModel userModel;

  ChatDetailsScreen({
    super.key,
    required this.userModel,
  });

  var messageController = TextEditingController();

  bool isArabic(String? textMessage) {
    if (textMessage!.isEmpty) {
      return false;
    }
    if (textMessage[0].codeUnits[0] >= 0x0600 &&
        textMessage[0].codeUnits[0] <= 0x06E0) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        SocialCubit.get(context).getMessages(receiverId: userModel.uId!);

        return BlocConsumer<SocialCubit, SocialStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                titleSpacing: 0.0,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.0,
                      backgroundImage: NetworkImage(userModel.image!),
                    ),
                    const SizedBox(width: 15.0),
                    Text(userModel.name!),
                  ],
                ),
              ),
              body: ConditionalBuilder(
                condition: SocialCubit.get(context).messages.isNotEmpty,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            var message =
                                SocialCubit.get(context).messages[index];

                            if (SocialCubit.get(context).userModel.uId ==
                                message.senderId) {
                              return buildMyMessage(message);
                            }

                            return buildMessage(message);
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 15.0),
                          itemCount: SocialCubit.get(context).messages.length,
                        ),
                      ),
                      buildButtonSend(context),
                    ],
                  ),
                ),
                fallback: (context) => Column(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          'There are no messages yet\n start chatting now',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    buildButtonSend(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildMessage(MessageModel model) => Align(
        alignment: AlignmentDirectional.topStart,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(10.0),
                    topStart: Radius.circular(10.0),
                    topEnd: Radius.circular(10.0),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Column(
                  children: [
                    Align(
                        alignment: isArabic(model.text!)
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: Text(model.text!)),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Text(model.dateTime!,
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(userModel.image!),
            ),
          ],
        ),
      );

  Widget buildMyMessage(MessageModel model) => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(userModel.image!),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: defaultColor.withOpacity(.2),
                  borderRadius: const BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(10.0),
                    topStart: Radius.circular(10.0),
                    topEnd: Radius.circular(10.0),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Column(
                  children: [
                    Align(
                        alignment: isArabic(model.text!)
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: Text(model.text!)),
                    Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Text(model.dateTime!,
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildButtonSend(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(
          15.0,
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Row(
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'message must not be empty';
                    }
                    return null;
                  },
                  controller: messageController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'type your message here ...',
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 50.0,
            color: defaultColor,
            child: MaterialButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  SocialCubit.get(context).sendMessage(
                    receiverId: userModel.uId!,
                    dateTime: DateTime.now().toString(),
                    text: messageController.text,
                  );
                  messageController.text = '';
                }
              },
              minWidth: 1.0,
              child: const Icon(
                IconBroken.Send,
                size: 16.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
